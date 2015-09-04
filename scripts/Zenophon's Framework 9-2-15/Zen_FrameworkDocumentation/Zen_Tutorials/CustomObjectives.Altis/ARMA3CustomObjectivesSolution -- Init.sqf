#include "Zen_FrameworkFunctions\Zen_InitHeader.sqf"

// <Your mission name here> by <your name here>
// Version = <the date here>
// Tested with ArmA 3 <version number>

// This will fade in from black, to hide jarring actions at mission start, this is optional and you can change the value
titleText ["Good Luck", "BLACK FADED", 0.4];
// SQF functions cannot continue running after loading a saved game, do not delete this line
enableSaving [false, false];

Player creatediaryRecord["Diary", ["Custom Objectives Tutorial", "Complete the tasks in the order presented.<br/>Designed for a single player led squad.<br/>"]];

// All clients stop executing here, do not delete this line
if (!isServer) exitWith {};

f_createrendezvousObjective = {
	private ["_pUnits", "_pPosition", "_taskName","_aredeadHandle"];
 
 	_pPosition = _this select 0;
	_pUnits = _this select 1;
		
	_taskName = [_pUnits, "Reach the rendezvous point, collect your squad and await further instructions", "Rendezvous",_pPosition] call Zen_InvokeTask;
			
	// Task is completed in two ways: Failure from death of squad leader or squad leader reaches the rendezvous point	
	_aredeadHandle = [_pUnits, _taskName, "failed"] spawn Zen_TriggerAreDead;
	0 = [_pUnits, _taskName, "succeeded", _pPosition, "one", 5] spawn Zen_TriggerAreNear;
	
	// Return pointer to trigger
	(_aredeadHandle)
	
};

f_createClearAreaObjective = {
	private ["_pPosition", "_pUnits", "_pSide", "_pNumberofSquads","_pAverageSize","_pSkillLevel","_minSize","_maxSize","_oppositionArray","_randomPosition","_randomGroup","_taskName","_aredeadHandle"];
	
	_pPosition = _this select 0;
	_pUnits = _this select 1;
	_pSide = _this select 2;
	_pNumberofSquads = _this select 3;
	
	// Test if fifth parameter is an element of system supplied parameter _this
	if (count _this > 4) then {
		_pAverageSize = _this select 4;
	} else {
		_pAverageSize = 3;
	};

	_minSize = _pAverageSize - 2; 
	_maxSize = _pAverageSize + 2;
	if (_minSize <= 0) then {_minSize = 1};
	
	// Test if sixth parameter is an element of system supplied parameter _this
	if (count _this > 5) then {
		_pSkillLevel = _this select 5;
	} else {
		_pSkillLevel = "infantry";
	};

	_oppositionArray = [];
	for "_i" from 0 to (_pNumberofSquads - 1) do {
		_randomPosition = [_pPosition] call Zen_FindGroundPosition;
		_randomGroup = [_randomPosition, _pSide, _pSkillLevel, [_minSize,_maxSize]] call Zen_SpawnInfantry;
		_oppositionArray set [(count _oppositionArray), _randomGroup];
	};
	
	0 = [_oppositionArray,_pPosition] spawn Zen_OrderInfantryPatrol;
	0 = [(_oppositionArray), "group"] call Zen_TrackInfantry;
	
	_taskName = [_pUnits, "Clear the designated area and await further instructions", "Clear and Hold",_pPosition] call Zen_InvokeTask;
	
	// Task is completed in two ways: Failure from death of all units or all opposition units killed	
	_aredeadHandle = [_pUnits, _taskName, "failed"] spawn Zen_TriggerAreDead;
	0 = [_oppositionArray, _taskName, "succeeded", _pPosition] spawn Zen_TriggerAreaClear;
	
	// Return pointer to trigger	
	(_aredeadHandle) 
	
};

// Execution stops until the mission begins (past briefing), do not delete this line
sleep 1.5;

// Enter the mission code here

"RendezvousOne" setMarkerAlpha 0;
"ClearArea" setMarkerAlpha 0;

// Set random weather and random time between 9 am and 5 pm
0 = [["overcast", random 0.3, random 0.7, 60*45], ["fog", random 0.3, random 0.3, 60*15], ["date", random 60, 9 + random 7]] spawn Zen_SetWeather;
sleep 1.0;

// Create references to squad leader and members
_group_X11 = group X11;
_group_Partisan = group PartisanReinforcement;

// Concatenate all playable units into single array of objects
_allplayersArray = [_group_X11,_group_Partisan] call Zen_ConvertToObjectArray;

// Helper functions
0 = [_allplayersArray] call Zen_AddGiveMagazine;
0 = [_allplayersArray] call Zen_AddRepackMagazines;

// Set units in playable groups to infantry skill level
0 = [_allplayersArray, "infantry"] call Zen_SetAISkill;

// Track all units in playable groups
0 = [_allplayersArray] call Zen_TrackInfantry;

// Begin logic for first objective

// Generate a random location
_X11rendezvousOne = ["RendezvousOne"] call Zen_FindGroundPosition;
// Move squad members to rendezvous point
0 = [_group_Partisan,_X11RendezvousOne] call Zen_MoveAsSet;
// Create a custom objective
_alldeadHandle = [_X11rendezvousOne, _group_X11] call f_createrendezvousObjective;
// Give the inline function time to complete
sleep 1; 
_X11Task = [X11] call Zen_GetUnitTasks;

// Wait until all tasks are complete
waituntil { sleep 5; [_X11Task] call Zen_AreTasksComplete };

(units _group_Partisan) join _group_X11;

// Kill the thread that would complete task if all players killed
terminate _alldeadHandle;	

// Begin logic for second objective

// Create another objective	
_alldeadHandle = ["ClearArea",_allplayersArray,EAST,4,3,"infantry"] call f_createClearAreaObjective;
// Give the inline function time to complete
sleep 1;
_X11Task = [X11] call Zen_GetUnitTasks;
// Wait until all tasks are complete
waituntil { sleep 5; [_X11Task] call Zen_AreTasksComplete };
// Kill the thread that would complete task if all players killed
terminate _alldeadHandle;	
