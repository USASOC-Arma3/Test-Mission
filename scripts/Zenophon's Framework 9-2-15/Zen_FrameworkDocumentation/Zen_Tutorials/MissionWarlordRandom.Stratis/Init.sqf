#include "Zen_FrameworkFunctions\Zen_InitHeader.sqf"
#include "misc.sqf"

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

// Set random heavy fog and random mission start time between 9 pm and 4 am
0 = [["fog", random 0.7], ["date", random 60, 21 + random 7]] spawn Zen_SetWeather;

// Call functon to get random city/village area marker
_randomCity = call f_getrandomcityAreaMarker;
_randomCity setMarkerAlpha 1;	// Debug

// Generate a random position within the city
_ObjectivePos = [_randomCity] call Zen_FindGroundPosition;

// Create a Eliminate Warlord objective at generated position
_yourObjective = [_ObjectivePos, (group X11), east, "Officer","eliminate"] call Zen_CreateObjective;

// Assign a squad to protect the warlord
_MortarGuard = [_ObjectivePos, east, "militia", [3,4]] call Zen_SpawnInfantry;

// Call three custom functions to create a two dimensional array of 
// markers in and around the center of the town
_cityCenter = getMarkerPos _randomCity;
_AREAMARKER_WIDTH = 100;
// Create an array of positions relative to the city center
_positionArray = [4,4,_cityCenter,_AREAMARKER_WIDTH] call f_getnearbyPositionsbyParm;
// Convert all the positions into area markers
_markerArray = [_positionArray,_AREAMARKER_WIDTH] call f_createMarkersfromArray;
// Filter out all positions that are mostly water
_markerArray = [_markerArray] call f_filtermarkersbyTerrain;

// Create four squads that move randomly within the grid
for "_i" from 0 to 3 do {
	_newGroup = [_markerArray] call f_spawnsquadforMarkerArray;
};

// Generate random position for player group
_randomStartingLocation = [(getMarkerPos _randomCity),[400,450],[],1] call Zen_FindGroundPosition;

// Move player squad to new starting position
0 = [group X11,_randomStartingLocation] call Zen_MoveAsSet;

// For convenience, track players
0 = [[group X11], "group"] call Zen_TrackInfantry;

waituntil { sleep 5; [(_yourObjective select 1)] call Zen_AreTasksComplete };

endMission "end1"
