#include "Zen_FrameworkFunctions\Zen_InitHeader.sqf"

// <Your mission name here> by <your name here>
// Version = <the date here>
// Tested with ArmA 3 -- <version number>

// This will fade in from black, edit the number to change the length of the fade
titleText ["Good Luck", "BLACK FADED", 0.3];
// SQF functions cannot continue running after loading a saved game, do not delete this line
enableSaving [false, false];

Player creatediaryRecord["Diary", ["Chained Objectives Tutorial", "Travel North and complete the objectives in turn. If necessary, resupply at the spawned ammo boxes.<br/>"]];

// All clients stop executing here, do not delete this line
if (!isServer) exitWith {};

// Execution stops until the mission begins (past briefing), do not delete this line 
sleep 1.5;

// Enter the mission code here

// Add these actions for all playable units
0 = [(group X11)] call Zen_AddGiveMagazine;
0 = [(group X11)] call Zen_AddRepackMagazines;

//Set the time to early morning with overcast

0 = [["date", 18, 8, 10, 3, 2035]] spawn Zen_SetWeather;
0 = [["overcast",0.6]] spawn Zen_SetWeather;

// One patrolling squad just for flavor
_PatrolOneInitialPos = ["OPFORPatrolOne"] call Zen_FindGroundPosition;
_PatrolOne = [_PatrolOneInitialPos, east, 0.5, [1,2]] call Zen_SpawnInfantry;
0 = [_PatrolOne, "OPFORPatrolOne"] spawn Zen_OrderInfantryPatrol;
_returnArray = [[_PatrolOne], "group"] call Zen_TrackInfantry;

// Eliminate Officer objective
_Objective1Pos = ["BLUFORObjectiveAreaOne"] call Zen_FindGroundPosition;
_yourObjective1 = [_Objective1Pos, (group X11), east, "Officer","eliminate"] call Zen_CreateObjective;

waituntil { sleep 5; [(_yourObjective1 select 1)] call Zen_AreTasksComplete };

// Random resupply
_ResupplyOnePos = ["BLUFORResupplyOne"] call Zen_FindGroundPosition;
0 = [_ResupplyOnePos, west] call Zen_SpawnAmmoBox;
0 = [_ResupplyOnePos, "Ammo Box", "ColorBlue",[1,1],"mil_flag"] call Zen_SpawnMarker;

// Fog closes in
0 = [["fog", 0.9]] spawn Zen_SetWeather;

// Two objectives. Framework will choose one at random from list
// Note: Prisoner of war is on side West (Blufor)
_Objective2APos = ["BLUFORObjectiveAreaTwo"] call Zen_FindGroundPosition;
_yourObjective2A = [_Objective2APos, (group X11), east, ["Mortar","Wreck","Officer"],"eliminate"] call Zen_CreateObjective;
_Objective2BPos = ["BLUFORObjectiveAreaTwo"] call Zen_FindGroundPosition;
_yourObjective2B = [_Objective2BPos, (group X11), west, ["POW"],"rescue"] call Zen_CreateObjective;

// Wait until both are completed before going to next statement
waituntil { sleep 5; [[(_yourObjective2A select 1),(_yourObjective2B select 1)]] call Zen_AreTasksComplete };

// Second resupply. Nato specific.
_ResupplyTwoPos = ["BLUFORResupplyTwo"] call Zen_FindGroundPosition;
0 = [_ResupplyTwoPos, "Box_NATO_Wps_F"] call Zen_SpawnVehicle;
0 = [_ResupplyTwoPos, "Nato Ammo", "ColorBlue",[1,1],"mil_join"] call Zen_SpawnMarker;

// Rain forecast!
0 = [["fog",0.9,0.1,120],["overcast",0.9],["rain",1.0]] spawn Zen_SetWeather;

// Custom objective. Reach the helicopter and fly your squad to safety.
_Objective3Pos = ["BLUFORObjectiveAreaThree"] call Zen_FindGroundPosition;
_yourObjective3 = [_Objective3Pos, (group X11), west, "Custom","reach","B_Heli_Light_01_F"] call Zen_CreateObjective;

// Fly 1000 meters and end the mission
waituntil {
	sleep 2;
	((X11 distance _Objective3Pos) > 1000)
};
endMission "end1"
