#include "Zen_FrameworkFunctions\Zen_InitHeader.sqf"
#include "misc.sqf"

// <Your mission name here> by <your name here>
// Version = <the date here>
// Tested with ArmA 3 -- <version number>

// This will fade in from black, edit the number to change the length of the fade
titleText ["Good Luck", "BLACK FADED", 1.5];
// SQF functions cannot continue running after loading a saved game, do not delete this line
enableSaving [false, false];

Player creatediaryRecord["Diary", ["Chained Objectives Tutorial", "Complete the objectives in turn. If necessary, resupply at the spawned ammo boxes.<br/>"]];

// Turn off argument checking
ZEN_DEBUG_ARGUMENTS = false;

// All clients stop executing here, do not delete this line
if (!isServer) exitWith {};

// Execution stops until the mission begins (past briefing), do not delete this line 
sleep 1.5;

// Enter the mission code here

// Add these actions for all playable units
0 = [(group X11)] call Zen_AddGiveMagazine;
0 = [(group X11)] call Zen_AddRepackMagazines;

//Set the time to early morning
0 = [["date",18,8,10,3,2035]] spawn Zen_SetWeather;

_startWeather = [0.1,0.9] call Zen_FindInRange;
_nextWeather = 0;
if ((.5 - _startWeather) > 0) then 
	{_nextWeather = 0.9;} 
else 
	{_nextWeather = 0.1;};
//player sideChat (str _startWeather) + " " + (str _nextWeather);	// Debug
// Set overcast and then trend less or more over 30 minutes
0 = [["overcast",_startWeather,_nextWeather,60*30]] spawn Zen_SetWeather;

// Enter the mission code here
_randomCity = call f_getrandomcityAreaMarker;
//_randomCity setMarkerAlpha 1;	// Debug

// Call custom functions to create a two dimensional array of 
// markers in and around the center of the town
_cityCenter = getMarkerPos _randomCity;
_AREAMARKER_WIDTH = 100;
// Create an array of positions relative to the city center
_positionArray = [4,4,_cityCenter,_AREAMARKER_WIDTH] call f_getnearbyPositionsbyParm;
// Convert all the positions into area markers
_markerArray = [_positionArray,_AREAMARKER_WIDTH] call f_createMarkersfromArray;
// Filter out all positions that are water
_markerArray = [_markerArray,[["water",20]]] call f_filtermarkersbyParm;

// Select first area randomly
_O1Marker = [_markerArray] call Zen_ArrayGetRandom;
// Remove this area marker so it isn't used for next objective
[_markerArray,_O1Marker] call Zen_ArrayRemoveValue;
	
// Eliminate Officer objective
_Objective1Pos = [_O1Marker] call Zen_FindGroundPosition;
_yourObjective1 = [_Objective1Pos, (group X11), east, "Officer","eliminate"] call Zen_CreateObjective;

// Generate random position for player group and move to that position
_randomStartingLocation = [_Objective1Pos,[300,350],[],1] call Zen_FindGroundPosition;
0 = [group X11,_randomStartingLocation] call Zen_MoveAsSet;
// For convenience, track players
0 = [[group X11], "group"] call Zen_TrackInfantry;

waituntil { sleep 5; [(_yourObjective1 select 1)] call Zen_AreTasksComplete };

// Random resupply
_ResupplyOnePos = [_O1Marker] call Zen_FindGroundPosition;
0 = [_ResupplyOnePos, west] call Zen_SpawnAmmoBox;
0 = [_ResupplyOnePos, "Ammo Box", "ColorBlue",[1,1],"mil_flag"] call Zen_SpawnMarker;

_startWeather = [0.1,0.9] call Zen_FindInRange;
_nextWeather = 0;
if ((.5 - _startWeather) > 0) then 
	{_nextWeather = 0.9;} 
else 
	{_nextWeather = 0.1;};
// Immediately reduce overcast and then trend to zero. Add starting fog and trend less or more.
0 = [["overcast",overcast-0.2,0,60*30],["fog",_startWeather,_nextWeather,60*30]] spawn Zen_SetWeather;

// Select next area randomly
_O2Marker = [_markerArray] call Zen_ArrayGetRandom;
// Remove this area marker so it isn't used for next objective
[_markerArray,_O2Marker] call Zen_ArrayRemoveValue;

// Two objectives. Framework will choose one at random from list
// Note: Prisoner of war is on side West (Blufor)
_Objective2APos = [_O2Marker] call Zen_FindGroundPosition;
_yourObjective2A = [_Objective2APos, (group X11), east, ["Mortar","Wreck","Officer"],"eliminate"] call Zen_CreateObjective;
_Objective2BPos = [_O2Marker] call Zen_FindGroundPosition;
_yourObjective2B = [_Objective2BPos, (group X11), west, ["POW"],"rescue"] call Zen_CreateObjective;

// Wait until both are completed before going to next statement
waituntil { sleep 5; [[(_yourObjective2A select 1),(_yourObjective2B select 1)]] call Zen_AreTasksComplete };

// Second resupply. Nato specific.
_ResupplyTwoPos = [_O2Marker] call Zen_FindGroundPosition;
0 = [_ResupplyTwoPos, "Box_NATO_Wps_F"] call Zen_SpawnVehicle;
0 = [_ResupplyTwoPos, "Nato Ammo", "ColorBlue",[1,1],"mil_join"] call Zen_SpawnMarker;

// Immediately overcast and raining
0 = [["overcast",0.7],["rain",1.0]] spawn Zen_SetWeather;

// Filter out all positions that are GT 20% urban
_filteredArray = [_markerArray,[["urban",20]]] call f_filtermarkersbyParm;
// Select next area randomly
_O3Marker = [_filteredArray] call Zen_ArrayGetRandom;

// Custom objective. Reach the helicopter and fly your squad to safety.
_Objective3Pos = [_O3Marker,0,0,1,0,0,[1,0,15],0,0,[1,15],[1,[0,0,-1],10]] call Zen_FindGroundPosition;
_yourObjective3 = [_Objective3Pos, (group X11), west, "Custom","reach","B_Heli_Light_01_F"] call Zen_CreateObjective;

// Fly 1000 meters and end the mission
waituntil {
	sleep 2;
	((X11 distance _Objective3Pos) > 1000)
};
endMission "end1"
