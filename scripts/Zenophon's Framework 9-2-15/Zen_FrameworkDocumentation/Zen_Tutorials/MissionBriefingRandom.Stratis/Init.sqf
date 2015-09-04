#include "Zen_FrameworkFunctions\Zen_InitHeader.sqf"
#include "misc.sqf"

// <Your mission name here> by <your name here>
// Version = <the date here>
// Tested with ArmA 3 -- <version number>

// This will fade in from black, edit the number to change the length of the fade
titleText ["Good Luck", "BLACK FADED", 0.6];
// SQF functions cannot continue running after loading a saved game, do not delete this line
enableSaving [false, false];

Player creatediaryRecord["Diary", ["Briefing Tutorial Part Two", "If necessary engage the single squad that patrols near the town.<br/>"]];
Player creatediaryRecord["Diary", ["Briefing Tutorial Part One", "Destroy the Mortar Emplacement<br/>An OPFOR mortar is emplaced in a town and must be destroyed. <br/>"]];

// All clients stop executing here, do not delete this line
if (!isServer) exitWith {};

// Execution stops until the mission begins (past briefing), do not delete this line 
sleep 1.5;

// Enter the mission code here

// Call functon to get random city/village area marker
_randomCity = call f_getrandomcityAreaMarker;

// Generate a random position within the city
_ObjectivePos = [_randomCity] call Zen_FindGroundPosition;

// Create a Mortar objective at generated position
_YourObjective = [_ObjectivePos, (group X11), east, "Mortar", "eliminate"] call Zen_CreateObjective;

// Assign a squad to protect the mortar
_MortarGuard = [_ObjectivePos, east, "militia", [3,4]] call Zen_SpawnInfantry;

// Call three custom functions to create a two dimensional array of 
// markers in and around the center of the town
_cityCenter = getMarkerPos _randomCity;
// Create an array of positions relative to the city center
_positionArray = [_cityCenter,150] call f_getnearbyPositionsNine;
// Convert all the positions into area markers
_markerArray = [_positionArray,150] call f_createMarkersfromArray;
// Filter out all markers that are mostly water
_markerArray = [_markerArray] call f_filtermarkersbyTerrain;

// Select one of the the area markers randomly
_randomArea = [_markerArray] call Zen_ArrayGetRandom;
// Generate a random position within the area marker
_PatrolPosition = [_randomArea] call Zen_FindGroundPosition;

// Spawn a squad and order it to patrol within the area marker
_TownGuard = [_PatrolPosition, east, "infantry", [2,5]] call Zen_SpawnInfantry;
0 = [_TownGuard, _randomArea] spawn Zen_OrderInfantryPatrol;
// For convenience, track EAST squad
0 = [[_TownGuard], "group"] call Zen_TrackInfantry;

// Generate random position for player group
_randomStartingLocation = [(getMarkerPos _randomCity),[300,400],[],1] call Zen_FindGroundPosition;

// Move player squad to new starting position
0 = [group X11,_randomStartingLocation] call Zen_MoveAsSet;

// For convenience, track players
0 = [[group X11], "group"] call Zen_TrackInfantry;

waituntil { sleep 5; [(_yourObjective select 1)] call Zen_AreTasksComplete };

endMission "end1"
