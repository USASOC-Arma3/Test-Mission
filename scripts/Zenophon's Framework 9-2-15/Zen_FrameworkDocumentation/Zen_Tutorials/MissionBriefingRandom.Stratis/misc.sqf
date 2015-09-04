f_getrandomcityAreaMarker = {
	private ["_ptownMarkers"];
	
	// Get array of cities and villages on map
	_ptownMarkers = [["NameVillage", "NameCity", "NameCityCapital"]] call Zen_ConfigGetLocations;

	// Choose random element and return it to calling function
	[_ptownMarkers] call Zen_ArrayGetRandom;
};

f_getnearbyPositionsNine = {
	private ["_pcenterzone","_pmarkersize","_newX","_newY","_ppositionarray"];
	// Assign local variables to center and marker size function parameters
	_pcenterzone = _this select 0;
	_pmarkersize = _this select 1;
	// Initialize empty array
	_ppositionarray = [];
	
	//player sidechat "Center Zone " + (str _pcenterzone);	// Debug
	
	// Use the idea of a "normalized" 3x3 matrix
	for "_x" from -1 to 1 step 1 do {
		for "_y" from -1 to 1 step 1 do {
			_newX = (_pcenterzone select 0) + (_x * _pmarkersize);
			_newY = (_pcenterzone select 1) + (_y * _pmarkersize);
			[_ppositionarray,[_newX,_newY]] call Zen_ArrayAppend;	
			//player sidechat "X and Y " + (str _newX) + ", " + (str _newY);	// Debug
		};
	};
	
	// Return array of positions to calling function
	_ppositionarray
};

f_createMarkersfromArray = {
	private ["_ppositionarray","_pmarkersize","_newMarker","_markerarray"];
	// Assign local variables to center and marker size function parameters
	_ppositionarray = _this select 0;
	_pmarkersize = _this select 1;
	// Initialize empty array
	_markerarray = [];
	
	// Iterate across array of positions
	// For each position spawn an area marker
	{	
		_newMarker = [[(_x select 0),(_x select 1)],"", "colorBlack",[_pmarkersize/2, _pmarkersize/2],"rectangle", 0, 0] call Zen_SpawnMarker;
		[_markerarray,_newMarker] call Zen_ArrayAppend;	
	} forEach _ppositionarray;
	
	// Return array of markers to the calling function
	_markerarray
};

f_filtermarkersbyTerrain = {
	private ["_parmarray","_pmarkerarray","_terrainExtent"];
	// Assign to local variable the function argument
	_parmarray = _this select 0;
	_pmarkerarray = +_parmarray;	// Filter a copy of the array argument
	
	// Iterate across array of positions
	// If the position is mostly water then replace it in the array with the value '0'
	{ 	
		_terrainExtent = [_x] call Zen_IsWaterArea;
		if (_terrainExtent > 0.6) then {
			_pmarkerarray set [_forEachIndex,0];
		};
	} forEach _pmarkerarray;
	
	// Remove all elements of position array that have value of '0'
	[_pmarkerarray,0] call Zen_ArrayRemoveValue;
	
	//private ["_alphaValue"];	// Debug
	//_alphaValue = 0;	// Debug
	//{	_x setMarkerAlpha 1;	// Debug
	//	if ((_alphaValue mod 2) == 0) then {_x setMarkerColor "ColorOrange"};	// Debug
	//	_alphaValue = _alphaValue+1;	// Debug
	//} forEach _pmarkerarray;	// Debug
	
	// Return filtered array of area markets to the calling function
	_pmarkerarray
};