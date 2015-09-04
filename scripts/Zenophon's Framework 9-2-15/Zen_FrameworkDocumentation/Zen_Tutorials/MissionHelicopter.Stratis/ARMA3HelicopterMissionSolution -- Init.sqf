#include "Zen_FrameworkFunctions\Zen_InitHeader.sqf"

// <Your mission name here> by <your name here>
// Version = <the date here>
// Tested with ArmA 3 -- <version number>

// This will fade in from black, edit the number to change the length of the fade
titleText ["Good Luck", "BLACK FADED", 0.3];
// SQF functions cannot continue running after loading a saved game, do not delete this line
enableSaving [false, false];

Player creatediaryRecord["Diary", ["Helicopter Tutorial", "Intercept and destroy a convoy resupplying the radar site.<br/>The radar site may be guarded by one squad.<br/>"]];

// All clients stop executing here, do not delete this line
if (!isServer) exitWith {};

// Execution stops until the mission begins (past briefing), do not delete this line 
sleep 1.5;

// Enter the mission code here

// Generate the helicopter's spawn position at a random distance from the landing zone
_heliSpawnPos = ["BLUFORLandingZone", [1000,1200]] call Zen_FindGroundPosition;

// Spawn a helicopter
_helicopter = [_heliSpawnPos, "b_heli_light_01_f", 80] call Zen_SpawnHelicopter;

// Call for insertion and travel to the landing zone
0 = [_helicopter, ["BLUFORLandingZone", _heliSpawnPos], (group player), "normal", 80] spawn Zen_OrderInsertion;

// Move passengers into helicopter
0 = [(group player), _helicopter] call Zen_MoveInVehicle;

sleep 120;

// Generate a random spawn position
_convoySpawnPos = ["HelicopterMissionOPFOR", [1000,1500],[],1,[2,0]] call Zen_FindGroundPosition;

// Create objective
_yourObjective = ["HelicopterMissionOPFOR",(group X11),east,"Convoy","eliminate",_convoySpawnPos] call Zen_CreateObjective;

waituntil { sleep 5; [(_yourObjective select 1)] call Zen_AreTasksComplete };

endMission "end1"