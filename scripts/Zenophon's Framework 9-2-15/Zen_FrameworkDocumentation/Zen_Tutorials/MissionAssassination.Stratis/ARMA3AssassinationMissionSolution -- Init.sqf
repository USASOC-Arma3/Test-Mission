#include "Zen_FrameworkFunctions\Zen_InitHeader.sqf"

// Mission Assassination by <your name here>
// Version = <the date here>
// Tested with ArmA 3 -- <Beta> -- <version number>

// this will fade in from black, edit the number to change the length of the fade
titleText ["Good Luck", "BLACK FADED", 0.3];
// SQF functions cannot continue running after loading a saved game, do not delete this line
enableSaving [false, false];

Player creatediaryRecord["Diary", ["Assassination Tutorial", "Travel West from your drop off point and find the ammo box. Kill the warlord on the beach. Go North East to the extraction point.<br/>"]];

// All clients stop executing here, do not delete this line
if (!isServer) exitWith {};

// Execution stops until the mission begins (past briefing), do not delete this line 
sleep 1.5;

// Enter the mission code here

// Clothe player character as civilian and place in protected status:	
0 = [X11, "Civilian"] call Zen_GiveLoadoutBlufor;
X11 SetCaptive true;

// Insert player character in AI driven car:
_CivilianCarPosition = ["Destination", [200, 250], [], 0, [1,200], [0, 90]] call Zen_FindGroundPosition;
_CivilianCar = [_CivilianCarPosition, "c_offroad_01_f", 270] call Zen_SpawnGroundVehicle;
0 = [X11, _CivilianCar] call Zen_MoveInVehicle;
0 = [_CivilianCar, ["Destination", _CivilianCarPosition], X11, "limited"] spawn Zen_OrderInsertion;

// Generate random position within area marker:
_ObjectivePos = ["WarlordMissionOPFOR"] call Zen_FindGroundPosition;

// Place a Warlord task objective at this random point:
_warlordReference = [_ObjectivePos, X11, east, "Officer","eliminate"] call Zen_CreateObjective;
_warlord = (_warlordReference select 0) select 0;

//Place a guard on patrol NorthEast of the Warlord:
_InnerPos = [_warlord, [40,100]] call Zen_FindGroundPosition;
_InnerGuard = [_InnerPos, EAST, "SOF", [2,3]] call Zen_SpawnInfantry;
0 = [[_InnerGuard], _InnerPos, [70,150]] spawn Zen_OrderInfantryPatrol;

//Create a squad to patrol further out:
_OuterPos = [_warlord, [170,220]] call Zen_FindGroundPosition;
_OuterGuard = [_OuterPos, EAST, "infantry", [2,3]] call Zen_SpawnInfantry;
0 = [[_OuterGuard], _OuterPos, [120,170]] spawn Zen_OrderInfantryPatrol;

waituntil { sleep 2; X11 Distance BLUFORAmmo < 2 };

// Outfit player character as Sniper:
0 = [X11, "Sniper"] call Zen_GiveLoadoutBlufor;
X11 SetCaptive false;

waituntil { sleep 2; !(alive _warlord) };

_ExtractionPos = ["BLUFOR_Extraction"] call Zen_FindGroundPosition;
_heliSpawnPos = [_ExtractionPos, [1000,1500], [], 0, [0,0], [45,90]] call Zen_FindGroundPosition;
_heliEndPos = [_ExtractionPos, [1500,2000], [], 0, [0,0], [45,90]] call Zen_FindGroundPosition;

// Create Helicopter
_X11Helicopter = [_heliSpawnPos, "b_heli_light_01_f", 60] call Zen_SpawnHelicopter;

// Call for Extraction
0 = [_X11Helicopter, [_ExtractionPos, _heliEndPos], X11, "normal" , 60] spawn Zen_OrderExtraction;

waituntil {
	sleep 2;
	((X11 distance _ExtractionPos) > 1200)
};

endMission "end1"
