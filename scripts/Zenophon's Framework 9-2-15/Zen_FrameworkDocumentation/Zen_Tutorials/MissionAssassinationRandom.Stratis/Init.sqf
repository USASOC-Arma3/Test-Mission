#include "Zen_FrameworkFunctions\Zen_InitHeader.sqf"
#include "misc.sqf"

// Mission Assassination by <your name here>
// Version = <the date here>
// Tested with ArmA 3 -- <Beta> -- <version number>

// this will fade in from black, edit the number to change the length of the fade
titleText ["Good Luck", "BLACK FADED", 1.5];
// SQF functions cannot continue running after loading a saved game, do not delete this line
enableSaving [false, false];

Player creatediaryRecord["Diary", ["Assassination Tutorial", "Travel from your drop off point and find the ammo box. Kill the warlord on the beach. Travel to resistance safe house.<br/>"]];

// Turn off argument checking
ZEN_DEBUG_ARGUMENTS = false;

// All clients stop executing here, do not delete this line
if (!isServer) exitWith {};

// Execution stops until the mission begins (past briefing), do not delete this line 
sleep 1.5;

// GLOBAL
extractionPosition = [];

// Enter the mission code here
_randomCity = call f_getrandomcityAreaMarker;
//_randomCity setMarkerAlpha 1;	// Debug

// Call custom functions to create a two dimensional array of 
// markers in and around the center of the town
_cityCenter = getMarkerPos _randomCity;
_AREAMARKER_WIDTH = 80;
// Create an array of positions relative to the city center
_positionArray = [6,6,_cityCenter,_AREAMARKER_WIDTH] call f_getnearbyPositionsbyParm;
// Convert all the positions into area markers
_markerArray = [_positionArray,_AREAMARKER_WIDTH] call f_createMarkersfromArray;
// Filter out all positions that are water
_markerArray = [_markerArray,[["water",20]]] call f_filtermarkersbyParm;
// Filter out all positions that are GT 20% urban
_filteredArray = [_markerArray,[["urban",20]]] call f_filtermarkersbyParm;
// Subtract all areas that are LT 20% urban from original array to leave us areas that are GT 20% urban
_filteredArray = _markerArray - _filteredArray;
	
// Select insertion area randomly
_infiltrationMarker = [_filteredArray] call Zen_ArrayGetRandom;
// Find a point on a road
_infiltrationPosition = [_infiltrationMarker,0,0,1,[2,100]] call Zen_FindGroundPosition;

// Insert player character in AI driven car:
_carstartPosition = [_infiltrationPosition,[200,300],[],0,[2,100]] call Zen_FindGroundPosition;
_civilianCar = [_carstartPosition, "c_offroad_01_f", 270] call Zen_SpawnGroundVehicle;
0 = [X11, _civilianCar] call Zen_MoveInVehicle;
0 = [_civilianCar, [_infiltrationPosition], X11, "limited"] spawn Zen_OrderInsertion;
[_infiltrationPosition,"INF","colorRed",[1,1],"mil_start"] call Zen_SpawnMarker;

// Clothe player character as civilian and place in protected status
0 = [X11, "Civilian"] call Zen_GiveLoadoutBlufor;
X11 SetCaptive true;

// Place the ammo box in a nearby building at a randomly chosen position
_ammoboxPosArray = [];
while {count _ammoboxPosArray == 0} do {
	_ammoboxPosition = [_infiltrationMarker,0,0,1] call Zen_FindGroundPosition;
	_ammoboxPosArray = [_ammoboxPosition,8] call Zen_FindBuildingPositions;
};
_ammobox = [(_ammoboxPosArray select 0),WEST] call Zen_SpawnAmmoBox;
// Force the ammobox to be at original position
//_ammobox setposATL (_ammoboxPosArray select 0);	// Alternative
[(_ammoboxPosArray select 0),"Box","colorBlue",[1,1],"mil_start"] call Zen_SpawnMarker;

// Generate a random position within the city
_ObjectivePos = [_randomCity] call Zen_FindGroundPosition;
// Place a Warlord task objective at this random point:
_warlordReference = [_ObjectivePos, X11, east, "Officer","eliminate"] call Zen_CreateObjective;
_warlord = (_warlordReference select 0) select 0;

//Create a squad to patrol
_InnerPos = [_ObjectivePos, [50,100]] call Zen_FindGroundPosition;
_InnerGuard = [_InnerPos, EAST, "infantry", [1,2]] call Zen_SpawnInfantry;
0 = [[_InnerGuard], _ObjectivePos, [50,150]] spawn Zen_OrderInfantryPatrol;
0 = [[_InnerGuard], "group"] call Zen_TrackInfantry;	// Debug

// For convenience, track players
0 = [[group X11], "group"] call Zen_TrackInfantry;

// Start creation of extraction location in background
0 = [_cityCenter] spawn f_createExtractionPosition;
	
waituntil { sleep 2; X11 Distance _ammobox < 2 };

// Outfit player character with random loadout
0 = [X11,["Recon","Rifleman","Marksman"]] call Zen_GiveLoadoutBlufor;
X11 SetCaptive false;

waituntil { sleep 2; !(alive _warlord) };

// Generate safehouse
_safehouseMarker = [_filteredArray] call Zen_ArrayGetRandom;
_contactPosArray = [];
while {count _contactPosArray == 0} do {
	_contactPosition = [_safehouseMarker,0,0,1] call Zen_FindGroundPosition;
	_contactPosArray = [_contactPosition,8] call Zen_FindBuildingPositions;
};

_civilianContact = [(_contactPosArray select 0), ["C_man_1_2_F"]] call Zen_SpawnGroup;
//((units _civilianContact) select 0) setposATL (_contactPosArray select 0);	// Alternative
[(_contactPosArray select 0),"RES","colorBlue",[1,1],"mil_start"] call Zen_SpawnMarker;

waituntil {sleep 2; X11 Distance ((units _civilianContact) select 0) < 2 };

titleText ["That evening...", "BLACK FADED", 0.5];
0 = [["date",30,23,7,6,2035]] spawn Zen_SetWeather;

civPos = [extractionPosition,25,0] call Zen_ExtendPosition;
playerPos = [extractionPosition,20,0] call Zen_ExtendPosition;
0 = [((units _civilianContact) select 0),civPos] call Zen_MoveAsSet;
0 = [X11,playerPos] call Zen_MoveAsSet;

// Wait until extract position is not an empty array. This is unlikely occurence for this mission.
waituntil {sleep 5;count extractionPosition > 0};
// Create helicopter start position relative to LZ
_heliSpawnPos = [extractionPosition,[1000,1500],[],0] call Zen_FindGroundPosition;
// Create Helicopter
_X11Helicopter = [_heliSpawnPos, "b_heli_light_01_f", 60] call Zen_SpawnHelicopter;
// Call for Extraction
0 = [_X11Helicopter, [extractionPosition,_heliSpawnPos],X11,"normal",60] spawn Zen_OrderExtraction;

waituntil {
	sleep 2;
	((X11 distance extractionPosition) > 900)
};

endMission "end1"
