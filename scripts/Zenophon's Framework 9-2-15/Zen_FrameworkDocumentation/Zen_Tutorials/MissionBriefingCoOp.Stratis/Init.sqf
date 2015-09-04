#include "Zen_FrameworkFunctions\Zen_InitHeader.sqf"
#include "misc.sqf"

// <Your mission name here> by <your name here>
// Version = <the date here>
// Tested with ArmA 3 -- <version number>

// This will fade in from black, edit the number to change the length of the fade
titleText ["Good Luck", "BLACK FADED", 0.9];
// SQF functions cannot continue running after loading a saved game, do not delete this line
enableSaving [false, false];

Player creatediaryRecord["Diary", ["Briefing Tutorial Part Two", "The mortar is protected by at least one squad.<br/>"]];
Player creatediaryRecord["Diary", ["Briefing Tutorial Part One", "Complete the secondary objectives and then destroy the Mortar Emplacement<br/>"]];

// All clients stop executing here, do not delete this line
if (!isServer) exitWith {};

// Execution stops until the mission begins (past briefing), do not delete this line 
sleep 1.5;

// Enter the mission code here

// Create array of all playable groups, whether occupied by players or AI
_allPlayedGroups = [];
if (isMultiplayer) then { 
    _allPlayedGroups = [playableUnits] call Zen_ConvertToGroupArray;
} else {
    _allPlayedGroups = [switchableUnits] call Zen_ConvertToGroupArray;
};

// Initializing functions collected in housekeeping functions
0 = [_allPlayedGroups] call f_housekeeping;

// Call function to generate random city/village area marker
_primaryTaskAreaMarker = call f_getPrimaryObjectiveMarker;

// Create array of secondary markers centered on primary marker
_markerArray = [_primaryTaskAreaMarker] call f_createSecondaryAreaMarkers;

// Create secondary objectives and an array reference to these objectives
_secondaryObjectives = [];
_secondaryObjectives = [_allPlayedGroups,_markerArray] call f_createSecondaryObjectives;

// Move all groups and set the behavior of AI controlled groups
0 = [_primaryTaskAreaMarker, _allPlayedGroups ] call f_manageMissionGroups;

// Wait until all secondary objectives completed
_completedObjectives = [];
{ 
	[_completedObjectives, _x select 1] call Zen_ArrayAppend;
} foreach _secondaryObjectives;

waituntil { sleep 5; [_completedObjectives] call Zen_AreTasksComplete;
	};

{
	// Move respawn marker to player's position
	if (isPlayer leader _x) then {"respawn_west_X" setMarkerPos (getPos player)};
} forEach _allPlayedGroups;

_primaryObjective = [_primaryTaskAreaMarker,_allPlayedGroups] call f_createPrimaryObjective;

waituntil { sleep 5; [(_primaryObjective select 1)] call Zen_AreTasksComplete };

endMission "end1"
