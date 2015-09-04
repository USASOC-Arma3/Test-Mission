#include "Zen_FrameworkFunctions\Zen_InitHeader.sqf"

// <Your mission name here> by <your name here>
// Version = <the date here>
// Tested with ArmA 3 -- <version number>

// This will fade in from black, edit the number to change the length of the fade
titleText ["Good Luck", "BLACK FADED", 0.6];
// SQF functions cannot continue running after loading a saved game, do not delete this line
enableSaving [false, false];
// All clients stop executing here, do not delete this line
if (!isServer) exitWith {};

f_getrandomcityAreaMarker = {
	private ["_ptownMarkers"];
	
	// Get array of cities and villages on map
	_ptownMarkers = [["NameVillage", "NameCity", "NameCityCapital"]] call Zen_ConfigGetLocations;

	// Choose random element and return it to calling function
	[_ptownMarkers] call Zen_ArrayGetRandom;
};

// Execution stops until the mission begins (past briefing), do not delete this line 
sleep 1.5;

// Enter the mission code here

// Call function to get random city/village area marker
_randomCity = call f_getrandomcityAreaMarker;

// Use reference to area marker to generate random position within this marker
_ObjectivePos = [_randomCity] call Zen_FindGroundPosition;

// Create custom rescue PoW objective
_yourObjective = [_ObjectivePos, (group X11), west, "custom", "rescue",["B_soldier_M_F", "B_Soldier_TL_F"]] call Zen_CreateObjective;

// Set PoWs to captive and stripped of weapons
{
    _x setCaptive true;
    _x disableAI "move";
    removeAllWeapons _x;
    removeBackpack _x;
    removeGoggles _x;
    removeHeadgear _x;
} forEach (_yourObjective select 0);  

// Place EAST squad
_enemyGroup = [_ObjectivePos, east, 0.2, [2,4]] call Zen_SpawnInfantry;

// Generate random position for player group
_randomStartingLocation = [(getMarkerPos _randomCity),[300,400],[],1] call Zen_FindGroundPosition;

// Move player squad to new starting position
0 = [group X11,_randomStartingLocation] call Zen_MoveAsSet;

// For convenience, track players
_btrackingArray = [[group X11], "group"] call Zen_TrackInfantry;

// Create simple loadout for PoW
_PoWLoadout = [[
    ["weapons", ["arifle_Katiba_F"]],
    ["magazines", [["30Rnd_65x39_caseless_green", 5]]]
]] call Zen_CreateLoadout;

// Wait until the PoW objective is complete.
waitUntil {
    sleep 2;
    ([(_yourObjective select 1)] call Zen_AreTasksComplete)
};

// Equip the former captives
0 = [(_yourObjective select 0), _PoWLoadout, "additive"] call Zen_GiveLoadoutCustom;
