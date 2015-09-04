#include "Zen_FrameworkFunctions\Zen_InitHeader.sqf"

// <Your mission name here> by <your name here>
// Version = <the date here>
// Tested with ArmA 3 -- <version number>

// This will fade in from black, edit the number to change the length of the fade
titleText ["Good Luck", "BLACK FADED", 0.3];
// SQF functions cannot continue running after loading a saved game, do not delete this line
enableSaving [false, false];

Player creatediaryRecord["Diary", ["Warlord Tutorial", "An evil warlord must be killed.<br/>A handful of squads protect the warlord. One patrols nearby, the others within a range of 100 to 250 meters.<br/>"]];

// All clients stop executing here, do not delete this line
if (!isServer) exitWith {};

// Execution stops until the mission begins (past briefing), do not delete this line 
sleep 1.5;

// Enter the mission code here

_ObjectivePos = ["WarlordMissionOpfor"] call Zen_FindGroundPosition;

_yourObjective = [_ObjectivePos, (group X11), east, "Officer","eliminate"] call Zen_CreateObjective;

_InnerPos = [_ObjectivePos, [70,150]] call Zen_FindGroundPosition;
_InnerGuard = [_InnerPos, east, "infantry", [2,3]] call Zen_SpawnInfantry;
0 = [[_InnerGuard], _InnerPos, [70,150]] spawn Zen_OrderInfantryPatrol;
_returnArray = [[_InnerGuard], "group"] call Zen_TrackInfantry;

_OuterPos = [_ObjectivePos, [120,170]] call Zen_FindGroundPosition;
_OuterGuard = [_OuterPos, east, "infantry", [2,3]] call Zen_SpawnInfantry;
0 = [[_OuterGuard], _ObjectivePos, [120,170]] spawn Zen_OrderInfantryPatrol;
_returnArray = [[_OuterGuard], "group"] call Zen_TrackInfantry;

_OuterPos = [_ObjectivePos, [170,250]] call Zen_FindGroundPosition;
_OuterGuard = [_OuterPos, east, "infantry", [2,3]] call Zen_SpawnInfantry;
0 = [[_OuterGuard], _ObjectivePos, [170,250]] spawn Zen_OrderInfantryPatrol;
_returnArray = [[_OuterGuard], "group"] call Zen_TrackInfantry;

_OuterPos = [_ObjectivePos, [170,250]] call Zen_FindGroundPosition;
_OuterGuard = [_OuterPos, east, "infantry", [2,3]] call Zen_SpawnInfantry;
0 = [[_OuterGuard], _ObjectivePos, [170,250]] spawn Zen_OrderInfantryPatrol;
_returnArray = [[_OuterGuard], "group"] call Zen_TrackInfantry;

waituntil { sleep 5; [(_yourObjective select 1)] call Zen_AreTasksComplete };

endMission "end1"

