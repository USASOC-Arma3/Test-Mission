#include "Zen_FrameworkFunctions\Zen_InitHeader.sqf"
#include "misc.sqf"

// <Your mission name here> by <your name here>
// Version = <the date here>
// Tested with ArmA 3 -- <version number>

// This will fade in from black, edit the number to change the length of the fade
titleText ["Good Luck", "BLACK FADED", 1.9];
// SQF functions cannot continue running after loading a saved game, do not delete this line
enableSaving [false, false];

Player creatediaryRecord["Diary", ["Helicopter Tutorial", "Intercept and destroy a convoy resupplying the radar site.<br/>The radar site may be guarded by one squad.<br/>"]];

// Turn off argument checking
ZEN_DEBUG_ARGUMENTS = false;

// All clients stop executing here, do not delete this line
if (!isServer) exitWith {};

// Execution stops until the mission begins (past briefing), do not delete this line 
sleep 1.5;

// Call function to get random city/village area marker
_randomCity = call f_getrandomcityAreaMarker;
//_randomCity setMarkerAlpha 1;	// Debug

// Generate a random position within the city
_ObjectivePos = [_randomCity] call Zen_FindGroundPosition;

// Call three custom functions to create a two dimensional array of 
// markers in and around the center of the town
_cityCenter = getMarkerPos _randomCity;
_AREAMARKER_WIDTH = 150;
// Create an array of positions relative to the city center
_positionArray = [5,5,_cityCenter,_AREAMARKER_WIDTH] call f_getnearbyPositionsbyParm;
// Convert all the positions into area markers
_markerArray = [_positionArray,_AREAMARKER_WIDTH] call f_createMarkersfromArray;
// Filter out all positions that are urban, near water or forested
_markerArray = [_markerArray,[["urban",70],["forest",30],["water",50]]] call f_filtermarkersbyParm;

// Select helicopter landing area randomly
_landingMarker = [_markerArray] call Zen_ArrayGetRandom;
// Find LZ on level land away from houses, trees, rocks and shrubs
_landingPosition = [_landingMarker,0,0,1,0,0,[1,0,8],0,0,[1,10],[1,[0,0,-1],8]] call Zen_FindGroundPosition;
[_landingPosition,"LZ","colorBlack",[1,1],"mil_start"] call Zen_SpawnMarker;

// Generate the helicopter's spawn position
_heliSpawnPos = [_landingPosition, [1000,1200]] call Zen_FindGroundPosition;
// Spawn the helicopter
_helicopter = [_heliSpawnPos, "b_heli_light_01_f", 80] call Zen_SpawnHelicopter;

// Call for insertion and travel to the landing zone; then return to original spawn position.
0 = [_helicopter, [_landingPosition, _heliSpawnPos], (group player), "normal", 80] spawn Zen_OrderInsertion;

// Move passengers into helicopter
0 = [(group player), _helicopter] call Zen_MoveInVehicle;

// Wait until helicopter has landed to continue mission
waitUntil {
    sleep 2;
    isTouchingGround _helicopter;
};

sleep 60;

// Generate a random spawn position at a moderate distance from the chosen town
_convoySpawnPos = [_ObjectivePos, [1200,1600],[],1,[2,0]] call Zen_FindGroundPosition;
// Create objective
_yourObjective = [_ObjectivePos,(group X11),east,"Convoy","eliminate",_convoySpawnPos] call Zen_CreateObjective;

waituntil { sleep 5; [(_yourObjective select 1)] call Zen_AreTasksComplete };

endMission "end1"

