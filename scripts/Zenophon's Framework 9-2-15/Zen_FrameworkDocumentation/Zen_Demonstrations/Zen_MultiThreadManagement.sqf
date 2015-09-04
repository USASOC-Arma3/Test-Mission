// This file is part of Zenophon's ArmA 3 Co-op Mission Framework
// This file is released under Creative Commons Attribution-NonCommercial-NoDerivatives 4.0 International (CC BY-NC-ND 4.0)
// See Legal.txt

#include "Zen_FrameworkFunctions\Zen_InitHeader.sqf"

// Demonstration of Multi-Thread Management by Zenophon
// Version = Final at 9/14/2013
// Tested with ArmA 3 1.0

/*  Multi-threading is incredibly easy in sqf, but it is also important to write scripts that are thread-safe.  Threads do not actually run concurrently on separate processors, but each receives CPU time assigned by a scheduler such that they appear to run in parallel.  This demonstration shows how manage threads of framework functions to alter data and your mission on-the-fly.  This is useful for having the mission react to what players are doing and not spawning dozens of AI that you don't need right in the beginning.  This also applies to spawning new AI reinforcements to challenge the players.*/

// Create a variable to hold the latest marker the Opfor should patrol
// Right now it is the marker placed on the map, which I will call the ancestor
_currentGenMarker = "mkStaticAncestorPatrol";

enableSaving [false, false];
if !(isServer) exitWith {};

// Make the marker invisible, this will take effect during the briefing, as it is before 'sleep 1;'
_currentGenMarker setMarkerAlpha 0;

sleep 1;

// Create an array of the playable blufor soldiers, this way you only need to name one person in the group
_players = units group X11;

// Give each player a random loadout, mark them on the map, and let them repack and give magazines
0 = [_players] call Zen_GiveLoadoutBlufor;
0 = [_players] call Zen_TrackInfantry;
0 = [_players] call Zen_AddGiveMagazine;
0 = [_players] call Zen_AddRepackMagazines;

// Declare array to be set later with all squads that are patrolling
// It can contain groups of dead units, Zen_OrderInfantryPatrol will handle that
_opforPatrolGroupsArray = [];

for "_i" from 1 to 2 do {
    // Calculate a spawning position
    _opforPatrolSpawnPos = [_currentGenMarker] call Zen_FindGroundPosition;

    // Spawn a 2-3 man Opfor squad in the marker
    _opforPatrolGroup = [_opforPatrolSpawnPos, east, "infantry", [2,3]] call Zen_SpawnInfantry;

    // Give them random loadouts, giving the group name directly works fine
    0 = [_opforPatrolGroup] call Zen_GiveLoadoutOpfor;

    // Update the array of all groups
    0 = [_opforPatrolGroupsArray, _opforPatrolGroup] call Zen_ArrayAppend;
};

// Make the groups patrol in the marker and keep the script handle
_currentPatrolHandle = [_opforPatrolGroupsArray, _currentGenMarker] spawn Zen_OrderInfantryPatrol;

// Mark the leaders of the groups, so that we can see them and their destination
_Zen_TrackGroupsArray = [_opforPatrolGroupsArray, "group", true] call Zen_TrackGroups;

// Get the values from the array returned by Zen_TrackGroups
_groupMarkers = _Zen_TrackGroupsArray select 0;
_currentThreadHandle = _Zen_TrackGroupsArray select 1;

for "_i" from 1 to 2 do {
    // the Opfor retreat every time the Blufor reach their area
    // this would probably not be used in a real mission, but any condition will work here
    // a better condition would be checking if X number of Opfor are dead
    waitUntil {
        sleep 2;
        // not (Zen_AreNotInArea) returns true if one Blufor soldier is within the area
        !([_players, _currentGenMarker] call Zen_AreNotInArea);
    };

    // Create a new marker for the Opfor to retreat to, and inherit the properties of the current marker
    // Get a new random name for this marker
    // We could simply move the original marker, but that is not the point of this demonstration
    // It also might be useful to change the marker size or direction depending on the mission
    _nextGenMarker = [[0,0], "", (markerColor _currentGenMarker), (markerSize _currentGenMarker), (markerShape _currentGenMarker), (markerDir _currentGenMarker), (markerAlpha _currentGenMarker)] call Zen_SpawnMarker;

    // Move the new marker 1000 meters North of the current marker
    _nextGenMarker setMarkerPos [((getMarkerPos _currentGenMarker) select 0), (((getMarkerPos _currentGenMarker) select 0) + 1000)];
    _nextGenMarker setMarkerPos ([_currentGenMarker, 1000, 0] call Zen_ExtendPosition);

    // Create a new squad to patrol the new area and help the old squads
    _opforPatrolSpawnPos = [_nextGenMarker] call Zen_FindGroundPosition;
    _opforPatrolGroup = [_opforPatrolSpawnPos, east, "infantry", [2,3]] call Zen_SpawnInfantry;
    0 = [_opforPatrolGroup] spawn Zen_GiveLoadoutOpfor;

    // Update the array of all groups
    0 = [_opforPatrolGroupsArray, _opforPatrolGroup] call Zen_ArrayAppend

    // End the thread of Zen_OrderInfantryPatrol and create a new one with updated parameters
    // note that the same variable is used, but it refers to the updated array
    terminate _currentPatrolHandle;
    _currentPatrolHandle = [_opforPatrolGroupsArray, _nextGenMarker] spawn Zen_OrderInfantryPatrol;

    // End the thread of Zen_TrackGroups and create a new one with updated parameters
    // We must also delete all of the markers created by the previous thread or duplicates will be created
    // all of the destination markers are deleted also
    terminate _currentThreadHandle;
    {deleteMarker _x;} forEach _groupMarkers;
    _Zen_TrackGroupsArray = [_opforPatrolGroupsArray, "group", true] call Zen_TrackGroups;

    // Get the values from the array returned by Zen_TrackGroups
    _groupMarkers = _Zen_TrackGroupsArray select 0;
    _currentThreadHandle = _Zen_TrackGroupsArray select 1;

    // Delete the current marker, make the next gen marker the current one
    deleteMarker _currentGenMarker;
    _currentGenMarker = _nextGenMarker;

    /*  Make the squads that are retreating run; they will go back to walking once they get to their destination.  Squads get their first waypoint as soon as Zen_OrderInfantryPatrol is spawned, so the new waypoint will override the old one.*/
    sleep 10;
    {
        _x setSpeedMode "full";
    } forEach _opforPatrolGroupsArray;
};
