#include "Zen_FrameworkFunctions\Zen_InitHeader.sqf"

// <Your mission name here> by <your name here>
// Version = <the date here>
// Tested with ArmA 3 -- <version number>

// This will fade in from black, edit the number to change the length of the fade
titleText ["Good Luck", "BLACK FADED", 0.5];
// SQF functions cannot continue running after loading a saved game, do not delete this line
enableSaving [false, false];

player createDiaryRecord ["Diary", ["Features", "Endless random objectives of different types<br/>Random patrols around objectives with random loadouts<br/>Cleanup of far away enemies<br/>Finely tuned AI skill settings<br/>Random time of day and weather<br/>Marker script for player units<br/>"]];
player createDiaryRecord ["Diary", ["Mission", "You have been deployed to patrol Altis and harass any Opfor units.  Each objective is defended by patrols.  You will receive new objectives as you complete them.  Scavenge enemy equipment and supplies to help you complete your next objective.  You can also steal civilian cars in towns."]];

// Preprocess function that will replenish depleted squads after each objective is completed
call compileFinal preprocessFileLineNumbers "ReinforceGroups.sqf";

// All clients stop executing here, do not delete this line
if (!isServer) exitWith {};

f_CreateRandomObjective = compileFinal preprocessFileLineNumbers "CreateRandomObjective.sqf";

// Execution stops until the mission begins (past briefing), do not delete this line 
sleep 2.0;

// Create references to this missions two playable groups
_group_X11 = group X11;
_group_X12 = group X21;
// Concatenate all playable units into single array of objects
_allplayersArray = units _group_X11 + units _group_X12;

// Overide co-op play view distance, which is too low
// [totalViewDistance = 4000, objectViewDistance = 1200]
0 = [4000, 1200] call Zen_SetViewDistance;

// Set random weather and random time between 9 am and 5 pm
0 = [["overcast", random 0.3, random 0.7, 60*45], ["fog", random 0.3, random 0.3, 60*15], ["date", random 60, 9 + random 7]] spawn Zen_SetWeather;

// Helper functions
0 = [_allplayersArray] call Zen_AddGiveMagazine;
0 = [_allplayersArray] call Zen_AddRepackMagazines;

// Set units in playable groups to infantry skill level
0 = [_allplayersArray, "infantry"] call Zen_SetAISkill;

// Track all units in playable groups
0 = [_allplayersArray] call Zen_TrackInfantry;

// Automobile types to spawn in Altis towns
_civilianVehicleTypes = ["C_Hatchback_01_F", "C_Hatchback_01_sport_F", "C_Offroad_01_F", "C_Quadbike_01_F", "C_SUV_01_F", "C_Van_01_transport_F"];
// Get an array of markers, one for each town in Altis
_altistownMarkers = [["NameVillage", "NameCity", "NameCityCapital"]] call Zen_ConfigGetLocations;

// Array of playable groups as placed in editor
_groups = [group X11, group X21];
// Initial count of units in partisan groups
_groupMaxs = [(count units group X11), (count units group X21)];
	
// Main objective spawning loop
while {true} do {

	// If necessary, replace lost units
	0 = [_groups, _groupMaxs] call f_sendReinforcements;

	// Calculate the average position ("center') of all units in playable groups
	_playerCenter = _allplayersArray call Zen_FindAveragePosition;

	// Remove all OPFOR ("east") units greater than 1500 meters from center of playable units
	{
		if ((alive _x) && (side _x == east) && (([_x, _playerCenter] call Zen_Find2dDistance) > 1500)) then {
			deleteVehicle _x;
		};
	} forEach allUnits;

	// Generate the position of the next objective to be created
	_objectivePosition = [_playerCenter, [1200, 1800], [], 1, 0, 0, [1,0,15]] call Zen_FindGroundPosition;
	
	// Call in-line function to generate Zen Objective and OPFOR patrolling squads
	_currentObjectiveTaskName = [_objectivePosition, _allplayersArray] call f_CreateRandomObjective;
	
	_populatedTowns = [];
    {
	if (([_x, _playerCenter] call Zen_Find2dDistance) < 2000 || ([_x, _playerCenter] call Zen_Find2dDistance) < 2000) then {
		// Add town to array of populated towns
		_populatedTowns set [(count _populatedTowns), _x];
		for "_j" from 0 to (7 + random 2) do {
			_autospawnPosition = [_x, 0, [], 1, [2, 500], 0, [1,0,10]] call Zen_FindGroundPosition;
			_autoType = [_civilianVehicleTypes] call Zen_ArrayGetRandom;
			_autoSpawnLocation = [_autospawnPosition, _autoType, 0, random 360] call Zen_SpawnVehicle;
			//0 = [_autospawnPosition] call Zen_SpawnMarker; // debug
		};
	};
    } forEach _altistownMarkers;
	// Remove all towns populated with vehicles from the master list
    _altistownMarkers = _altistownMarkers - _populatedTowns;
	
	// Wait until objective's task is complete
    waitUntil {
        sleep 2;
        ([_currentObjectiveTaskName] call Zen_AreTasksComplete)
    };
};
