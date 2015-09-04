
f_housekeeping = {
	private ["_pAllGroups"];
	_pAllGroups = _this select 0;
	
	// Override co-op play view distance, which is too low
	// [totalViewDistance = 4000, objectViewDistance = 1200]
	0 = [4000, 1200] call Zen_SetViewDistance;
	// Helper functions
	0 = [_pAllGroups] call Zen_AddGiveMagazine;
	0 = [_pAllGroups] call Zen_AddRepackMagazines;
	// Set random weather and random time between 9 am and 5 pm
	0 = [["overcast", random 0.3, random 0.7, 60*45], ["fog", random 0.3, random 0.3, 60*15], ["date", random 60, 9 + random 7]] spawn Zen_SetWeather;
	sleep 1.0;
};

f_getPrimaryObjectiveMarker = {
	call f_getrandomcityAreaMarker;
};

f_getrandomcityAreaMarker = {
	private ["_ptownMarkers"];
	
	// Get array of cities and villages on map
	_ptownMarkers = [["NameVillage", "NameCity", "NameCityCapital"]] call Zen_ConfigGetLocations;
	// Choose random element and return it to calling function
	[_ptownMarkers] call Zen_ArrayGetRandom;
};

f_createSecondaryObjectives = {
	private ["_pAllGroups","_pobjectives","_pMarkerArray","_p1stSecondaryObjective","_p2ndSecondaryObjective"];
	_pAllGroups = _this select 0;
	_pMarkerArray = _this select 1;
	
	_pobjectives = [];
		
	_p1stSecondaryObjective = [([_pMarkerArray] call f_createSecondaryObjectiveMarker), _pAllGroups, east, "Wreck", "reach"] call Zen_CreateObjective;
	[_pobjectives,_p1stSecondaryObjective] call Zen_ArrayAppend;
				
	_p2ndSecondaryObjective = [([_pMarkerArray] call f_createSecondaryObjectiveMarker), _pAllGroups, east, "Wreck", "reach"] call Zen_CreateObjective;
	[_pobjectives,_p2ndSecondaryObjective] call Zen_ArrayAppend;

	_pobjectives;
};

f_createSecondaryAreaMarkers = {
	private ["_primaryArea","_pcenter","_ppositionArray","_pMarkerArray"];
	_primaryArea = _this select 0;
	
	// Call three custom functions to create a two dimensional array of 
	// markers in and around the center
	_pcenter = getMarkerPos _primaryArea;
	// Create an array of positions relative to the city center
	_ppositionArray = [_pcenter,150] call f_getnearbyPositionsNine;
	// Convert all the positions into area markers
	_pMarkerArray = [_ppositionArray,150] call f_createMarkersfromArray;
	// Filter out all markers that are mostly water
	[_pMarkerArray] call f_filtermarkersbyTerrain;
};

f_createSecondaryObjectiveMarker = {
	private ["_pMarkerArray","_prandomArea"];
	_pMarkerArray = _this select 0;
	
	// Select one of the the area markers randomly
	_prandomArea = [_pMarkerArray] call Zen_ArrayGetRandom;
	// Generate a random position within the area marker
	[_prandomArea] call Zen_FindGroundPosition;
};

f_createPrimaryObjective = {
	private ["_primaryAreaMarker","_pAllGroups","_pObjectivePos"];
	_primaryAreaMarker = _this select 0;
	_pAllGroups = _this select 1;
	
	// Generate a random position within the city
	_pObjectivePos = [_primaryAreaMarker] call Zen_FindGroundPosition;
	// Assign a squad to guard mortar
	0 = [_pObjectivePos, east, "militia", [3,4]] call Zen_SpawnInfantry;
	// Create an objective at generated position
	[_pObjectivePos, _pAllGroups, east, "Mortar", "eliminate"] call Zen_CreateObjective;
};

f_manageMissionGroups = {
	private ["_pTaskAreaMarker","_pAllGroups","_pStartingLocation"];
	_pTaskAreaMarker = _this select 0;
	_pAllGroups = _this select 1;
		
	// Move all groups and set the behavior of AI controlled groups
	{
		// Generate random position for every group
		_pStartingLocation = [(getMarkerPos _pTaskAreaMarker),[300,400],[],1] call Zen_FindGroundPosition;
		// Move every group to a new starting position
		0 = [_x,_pStartingLocation] call Zen_MoveAsSet;
		// For tutorial convenience, track groups
		0 = [_x, "group"] call Zen_TrackInfantry;

		// Order AI led groups to patrol
		if !(isPlayer leader _x) then {
			0 = [_x,(getMarkerPos _pTaskAreaMarker),[150,400],[0,360],"limited"] spawn Zen_OrderInfantryPatrol;
		};
			
		// Move respawn marker to player's position
		if (isPlayer leader _x) then {"respawn_west_X" setMarkerPos _pStartingLocation};
		
	} forEach _pAllGroups;
};
f_getnearbyPositionsNine = {
	private ["_pcenterzone","_pnMarkerSize","_pnewX","_pnewY","_ppositionarray"];
	// Assign local variables to center and marker size function parameters
	_pcenterzone = _this select 0;
	_pnMarkerSize = _this select 1;
	
	// Initialize empty array
	_ppositionarray = [];
	
	// Use the idea of a "normalized" 3x3 matrix
	for "_x" from -1 to 1 step 1 do {
		for "_y" from -1 to 1 step 1 do {
			_pnewX = (_pcenterzone select 0) + (_x * _pnMarkerSize);
			_pnewY = (_pcenterzone select 1) + (_y * _pnMarkerSize);
			[_ppositionarray,[_pnewX,_pnewY]] call Zen_ArrayAppend;	
		};
	};
	
	// Return array of positions to calling function
	_ppositionarray
};

f_createMarkersfromArray = {
	private ["_ppositionarray","_pmarkersize","_pnewMarker","_pMarkerArray"];
	// Assign local variables to center and marker size function parameters
	_ppositionarray = _this select 0;
	_pmarkersize = _this select 1;
	
	// Initialize empty array
	_pMarkerArray = [];
	
	// Iterate across array of positions
	// For each position spawn an area marker
	{	
		_pnewMarker = [[(_x select 0),(_x select 1)],"", "colorBlack",[_pmarkersize/2, _pmarkersize/2],"rectangle", 0, 0] call Zen_SpawnMarker;
		[_pMarkerArray,_pnewMarker] call Zen_ArrayAppend;	
	} forEach _ppositionarray;
	
	// Return array of markers to the calling function
	_pMarkerArray
};

f_filtermarkersbyTerrain = {
	private ["_parmarray","_pmarkerarray","_pterrainExtent"];
	// Assign to local variable the function argument
	_parmarray = _this select 0;
	_pmarkerarray = +_parmarray;	// Filter a copy of the array argument
	
	// Iterate across array of positions
	// If the position is mostly water then replace it in the array with the value '0'
	{ 	
		_pterrainExtent = [_x] call Zen_IsWaterArea;
		if (_pterrainExtent > 0.6) then {
			_pmarkerarray set [_forEachIndex,0];
		};
	} forEach _pmarkerarray;
	
	// Remove all elements of position array that have value of '0'
	[_pmarkerarray,0] call Zen_ArrayRemoveValue;
	
	// Return filtered array of area markets to the calling function
	_pmarkerarray
};