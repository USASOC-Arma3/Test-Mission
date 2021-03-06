#include "Zen_FrameworkFunctions\Zen_InitHeader.sqf"

// <Your mission name here> by <your name here>
// Version = <the date here>
// Tested with ArmA 3 -- <version number>

// This will fade in from black, to hide jarring actions at mission start, this is optional and you can change the value
titleText ["Good Luck", "BLACK FADED", 0.3];
// SQF functions cannot continue running after loading a saved game, do not delete this line
enableSaving [false, false];

Player creatediaryRecord["Diary", ["Fire Control Tutorial", "Travel North from your landing zone to a hill overlooking Kavala Pier and Lighthouse. Target and destroy a convoy carrying four nuclear weapon arming/fuzing devices.<br/>SCUBA gear and a submarine will be available for extraction at the landing zone.<br/>"]];

// All clients stop executing here, do not delete this line
if (!isServer) exitWith {};

// Inline function to call scripted Fire Support
f_FireSupportonTimer = {
	private ["_scriptedtemplateName"];
	sleep 15;
	_scriptedtemplateName = ["Bo_Mk82_MI08",24,2,2,10,60,25 ] call Zen_CreateFireSupport;
	["OPFORConvoyRestArea", _scriptedtemplateName] spawn Zen_InvokeFireSupport;
};

// Inline function to call initial dialog
f_conversationInitial = {
	speakerOne = _this select 0;
	speakerTwo = _this select 1;
	speakerOne lookAt SpeakerTwo;
	sleep 2;
    speakerOne globalChat "Hello, Chief. Welcome back.";
    sleep 2;
    speakerTwo globalChat "Hello Kostas, great to be back...sorry I can't stay long.";
	sleep 2;
    speakerOne globalChat "And this won't take long. Just head north to the ridge top.";
	sleep 2;
	speakerOne globalChat "You'll see the convoy clearly, even if their lights are now off.";
};

// Speed the opening of this mission by moving code up and faster for loops

// Set marker areas invisible
"FireSupportBeachHead" setMarkerAlpha 0;
"BLUFOR_Extraction" setMarkerAlpha 0;

// Find random position for ammo/loadout box
_ammoboxPos = [Kostas, [1,4]] call Zen_FindGroundPosition;
_signalPos = [_ammoboxPos, [1,4]] call Zen_FindGroundPosition;

// Generate a random spawn position for speedboat
_speedboat_SpawnPos = [X11, [50,100],[],2,[0,0],[265,275]] call Zen_FindGroundPosition;
_speedboat_ExitPos = [X11, [1000,1100],[],2,[0,0],[265,275]] call Zen_FindGroundPosition;

// Generate random initial and final position for Submarine
_ExtractionPos = ["BLUFOR_Extraction",0,[],2] call Zen_FindGroundPosition;
_subEndPos = [_ExtractionPos,[500,800],[],2,[0,0],[265,275]] call Zen_FindGroundPosition;

// Generate random positions for blue chemlights
_bluelightarray = [];
for "_i" from 1 to 4 do {
	_bluelight = [Kostas, [3,6]] call Zen_FindGroundPosition;
	[_bluelightarray, _bluelight] call Zen_ArrayAppend;
};
_redlightarray = [];
for "_i" from 1 to 2 do {
	_redlight = [Agis, [3,6]] call Zen_FindGroundPosition;
	[_redlightarray, _redlight] call Zen_ArrayAppend;
};

// Execution stops until the mission begins (past briefing), do not delete this line 
sleep 1.5;

// Enter the mission code here
0 = [["overcast",0.4],["date", 15, 4, 10, 3, 2035]] spawn Zen_SetWeather;

// Create the boat that will insert X11
_insertion_boat = [_speedboat_SpawnPos, "C_Boat_Civil_01_f"] call Zen_SpawnBoat;
// Move X11 into boat
0 = [X11, _insertion_boat] call Zen_MoveInVehicle;
// Call for insertion of X11
0 = [_insertion_boat, ["FireSupportBeachHead", _speedboat_ExitPos], (group X11), "limited"] spawn Zen_OrderInsertion;
// Face Kostas and Agis towards the boat
Agis lookAt _speedboat_SpawnPos;
Kostas lookAt _speedboat_SpawnPos;

// Spawn ammo/loadout box near partisan contacts
_ammoBox = [_ammoboxPos, "Box_NATO_Wps_F"] call Zen_SpawnVehicle;
// Place chemlight signal at Loadout box
0 = [_signalPos, "chemlight_blue"] call Zen_SpawnVehicle;

{
	0 = [_x, "chemlight_blue"] call Zen_SpawnVehicle;
} foreach _bluelightarray;

// Spawn two red chemlights around Agis and put reference to them in an array
_chemlightArray = [];
{
	_redChemlight = [_x, "chemlight_red"] call Zen_SpawnVehicle;
	_chemlightArray set [count _chemlightArray,_redChemlight];
} foreach _redlightarray;

// Default chem light color
_chemlightColor = "chemlight_yellow";
// Add six chem lights to random existing chemlight and at random distance
for "_i" from 1 to 6 do {
	// Choose a chem light at random
    _randomChemlight = [_chemlightArray] call Zen_ArrayGetRandom;
	_chemlightPos = [_randomChemlight, [4,10]] call Zen_FindGroundPosition;
	// Change the color to green for the 5th and 6th chem lights
	if (_i > 4) then {
		_chemlightColor = "chemlight_green";
	};
	// Spawn the chemlight
	_newChemlight = [_chemlightPos, _chemlightColor] call Zen_SpawnVehicle;
	//player sideChat "Placing " + str(_chemlightColor);
	// Add the chemlight to the array
	_chemlightArray set [count _chemlightArray,_newChemlight];
};

// Loadout options
0 = [_ammoBox,["Diver","AT Specialist"],-1] call Zen_AddLoadoutDialog;

// Firesupport template and add to action menu
_templateName = ["Bo_Mk82_MI08",24,2,2,10,60,25 ] call Zen_CreateFireSupport;
0 = [west,_templateName,"NavalBatteryAlpha",2] call Zen_AddFireSupportAction;

// Create the convoy objective
_yourObjective = ["OPFORConvoyRestArea",(group X11),east,"Convoy","eliminate","OPFORConvoyRestArea"] call Zen_CreateObjective;

// Wait until player exits boat
waitUntil { sleep 2; (!( X11 in _insertion_boat))};

// Call for off-map bombardment
0 = [] spawn f_FireSupportonTimer;

// When close to Kostas call the dialog function
waituntil { sleep 2; X11 Distance Kostas < 5 };
0 = [Kostas, X11] call f_conversationInitial;

waituntil { sleep 5; [(_yourObjective select 1)] call Zen_AreTasksComplete };

// Submarine extraction
_extraction_sub = [_ExtractionPos, "B_SDV_01_F"] call Zen_SpawnBoat;
0 = [_extraction_sub, [_ExtractionPos, _subEndPos], X11, "normal"] spawn Zen_OrderExtraction;
_returnArray = [[_extraction_sub], "group"] call Zen_TrackInfantry;
_returnArray = [[X11], "name"] call Zen_TrackInfantry;

waituntil {sleep 2; ((X11 distance _ExtractionPos) > 500)};

endMission "end1"