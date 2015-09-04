// This file is part of Zenophon's ArmA 3 Co-op Mission Framework
// This file is released under Creative Commons Attribution-NonCommercial-NoDerivatives 4.0 International (CC BY-NC-ND 4.0)
// See Legal.txt

#include "Zen_FrameworkFunctions\Zen_InitHeader.sqf"

// Demonstration of Zen_OrderInfantryPatrol Dynamic Center by Zenophon
// Version = Final at 8/22/2013
// Tested with ArmA 3 -- Beta -- 0.76

/*  Markers are similar to objects in that they have properties that change globally and can be seen by any thread that knows the marker's name.  This is different than letting a called function access variables of a higher scope, instead changing the state of an object or marker affects threads that get data from that object or marker.  This demonstration shows how to use markers to change where the framework's infantry patrol function sends the AI without ever terminating the thread.*/

enableSaving [false, false];
if !(isServer) exitWith {};
sleep 2;

// Create an array of the playable blufor soldiers, this way you only need to name one person in the group
_players = units group X11;

// Define the markers on the map that will move
_dynamicMarkers = ["mkDynamicPatrolEast", "mkDynamicPatrolCenter", "mkDynamicPatrolWest"];

// Give each player a random loadout, mark them on the map, and let them repack and give magazines
0 = [_players] call Zen_GiveLoadoutBlufor;
0 = [_players] call Zen_TrackInfantry;
0 = [_players] call Zen_AddGiveMagazine;
0 = [_players] call Zen_AddRepackMagazines;

// Declare array to be set later with all squads that are patrolling
_opforPatrolGroupsArray = [];
{
    // Make the marker invisible
    _x setMarkerAlpha 0;

    // Calculate a random position in the marker
    _opforPatrolSpawnPos = [_x] call Zen_FindGroundPosition;

    // Spawn a 2-3 man Opfor squad in the marker
    _opforPatrolGroup = [_opforPatrolSpawnPos, east, "infantry", [2,3]] call Zen_SpawnInfantry;

    // Give them random loadouts, giving the group name directly works fine
    0 = [_opforPatrolGroup] call Zen_GiveLoadoutOpfor;

    // Make the group patrol in the marker
    0 = [_opforPatrolGroup, _x] spawn Zen_OrderInfantryPatrol;

    // Update the array of all groups
    0 = [_opforPatrolGroupsArray, _opforPatrolGroup] call Zen_ArrayAppend;
} forEach _dynamicMarkers;

// Mark the leaders of the groups, so that we can see them and their destination
0 = [_opforPatrolGroupsArray, "group", true] call Zen_TrackGroups;

// Set the angle and distance the markers move each time, this is 50m South
_distance = 50;

// this angle is compass, be aware that angles returned by Zen_FindDirection are trig
_phi = 180;

// Set how many times to move the markers, 50 here
for "_i" from 1 to 50 do {

    // Set the time between moving the markers
    sleep 45;

    // Take the marker's current position and alter it based upon the polar coordinates
    {
        _x setMarkerPos ([_x, _distance, _phi] call Zen_ExtendPosition);
    } forEach _dynamicMarkers;
};
