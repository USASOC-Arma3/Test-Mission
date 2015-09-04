#include "Zen_FrameworkFunctions\Zen_InitHeader.sqf"

// <Your mission name here> by <your name here>
// Version = <the date here>
// Tested with ArmA 3 -- <version number>

// This will fade in from black, edit the number to change the length of the fade
titleText ["Good Luck", "BLACK FADED", 0.3];
// SQF functions cannot continue running after loading a saved game, do not delete this line
enableSaving [false, false];

Player creatediaryRecord["Diary", ["Briefing Tutorial Part Two", "If necessary engage the single squad that patrols the southern part of the town.<br/>"]];
Player creatediaryRecord["Diary", ["Briefing Tutorial Part One", "Destroy the Mortar Emplacement<br/>An OPFOR mortar is emplaced in northern part of town and must be destroyed. <br/>"]];

// All clients stop executing here, do not delete this line
if (!isServer) exitWith {};

// Execution stops until the mission begins (past briefing), do not delete this line 
sleep 1.5;

// Enter the mission code here

// Generate a random position within the BriefingMissionMortar area marker
_ObjectivePos = ["BriefingMissionMortar"] call Zen_FindGroundPosition;

// Create a Mortar objective at generated position
_YourObjective = [_ObjectivePos, (group X11), east, "Mortar", "eliminate"] call Zen_CreateObjective;

// Assign a squad to protect the mortar
_MortarGuard = [_ObjectivePos, east, "infantry", [2,3]] call Zen_SpawnInfantry;

// Generate a random position within the BriefingMissionOPFOR area marker
_PatrolPosition = ["BriefingMissionOPFOR"] call Zen_FindGroundPosition;

// Spawn a squad and order it patrol within the area marker
_TownGuard = [_PatrolPosition, east, "SOF", [1,3]] call Zen_SpawnInfantry;

// Generate a new random position and another squad
_PatrolPosition = ["BriefingMissionOPFOR"] call Zen_FindGroundPosition;
_SecondTownGuard = [_PatrolPosition, east, "militia", [1,3]] call Zen_SpawnInfantry;

// Order two squads to patrol
0 = [[_TownGuard, _SecondTownGuard], "BriefingMissionOPFOR"] spawn Zen_OrderInfantryPatrol;

// Spawn a squad and order it patrol in an area around the mortar
_PatrollingGuard = [_ObjectivePos, east, "militia", [2,3]] call Zen_SpawnInfantry;
0 = [_PatrollingGuard, _ObjectivePos, [80,150]] spawn Zen_OrderInfantryPatrol;

waituntil { sleep 5; [(_yourObjective select 1)] call Zen_AreTasksComplete };
endMission "end1"
