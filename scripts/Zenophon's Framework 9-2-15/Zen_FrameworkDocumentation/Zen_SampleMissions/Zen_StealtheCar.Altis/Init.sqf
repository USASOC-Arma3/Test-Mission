#include "Zen_FrameworkFunctions\Zen_InitHeader.sqf"

// Steal the Car by Zenophon
// Version = Final 6/13/14
// Tested with ArmA 3 1.20

// This mission is inspired by the classic Operation Flashpoint mission 'Steal the Car'.  A bit of nostalgia for those who remember the old days.

// This will fade in from black, to hide jarring actions at mission start, this is optional and you can change the value
titleText ["Good Luck", "BLACK FADED", 0.4];
// SQF functions cannot continue running after loading a saved game, do not delete this line
enableSaving [false, false];

Player creatediaryRecord["Diary", ["Intel Reports that high-ranking CSAT officer, in possession of some highly sensitive documents is visiting troops in Frini.", "Locate these documents and bring them back for analysis. Take the officer's car from the town and drive to your intelligence liaison."]];

// All clients stop executing here, do not delete this line
if (!isServer) exitWith {};

// task/trigger combined in a function for ease of use
f_createrendezvousObjective = {
    private ["_pUnits", "_pPosition", "_taskName","_aredeadHandle"];

    _pPosition = _this select 0;
    _pUnits = _this select 1;
    _pVehicle = _this select 2;

    _taskName = [_pUnits, "Takes the car from the town and return it to your liaison", "Car Jacking",_pPosition] call Zen_InvokeTask;

    // Task is completed in two ways: Failure from death of player or vehicle reaches the commanding officer
    _aredeadHandle = [_pUnits, _taskName, "failed"] spawn Zen_TriggerAreDead;
    0 = [_pVehicle, _taskName, "succeeded", _pPosition, "one", 15] spawn Zen_TriggerAreNear;

    // Return pointer to trigger
    (_aredeadHandle)
};

// Execution stops until the mission begins (past briefing), do not delete this line
sleep 1;

// Set random weather and random time between 8 am and 4 pm
0 = [["overcast", random 0.3, random 0.7, 60*45], ["fog", random 0.3, random 0.3, 60*15], ["date", random 60, 8 + random 8]] spawn Zen_SetWeather;
sleep 1.0;

// no Zen_AddGiveMagazine here, this is a solo mission
0 = [X11] call Zen_AddRepackMagazines;

// changing the player(s)' start position is easy
_x11StartPosition = [ "BLUFORStartZone" ] call Zen_FindGroundPosition;
0 = [X11, _x11StartPosition] call Zen_MoveAsSet;

// ambient helicopter patrols
_helicopter = ["OPFORPatrolCenter", "O_Heli_Light_02_unarmed_F", 400, 180] call Zen_SpawnHelicopter;
_markerCenter = getMarkerPos "OPFORPatrolCenter";
0 = [_helicopter, _markerCenter, 250, 0, "limited"] spawn Zen_OrderAircraftPatrol;

// a more traditional for loop
for [{_i=0}, {_i<([3,4] call Zen_FindInRange)}, {_i=_i+1}] do {
    _groupPosition = ["OPFORPatrolCenter"] call Zen_FindGroundPosition;

    // Spawn a squad at that position
    _groupEAST = [_groupPosition, east, "infantry", [1,1]] call Zen_SpawnInfantry;

    // Order it to patrol within a range
    _initialDegrees = [[0,90,180,270]] call Zen_ArrayGetRandom;

    // Patrol sections of the town, this distributes patrols more evenly, so they don't leave a sector unguarded
    0 = [_groupEAST,"OPFORPatrolCenter",[],[_initialDegrees,_initialDegrees+89],"normal"] spawn Zen_OrderInfantryPatrol;
};

// set up the car and the soldiers guarding it
_ParkedCarPosition = ["OPFORPatrolCenter",0,0,1,[2,0],[270,340]] call Zen_FindGroundPosition;
0 = [_ParkedCarPosition,"","colorblue",[1,1],"o_recon"] call Zen_SpawnMarker;
_Ifrit = [_ParkedCarPosition,"O_MRAP_02_F",0,180] call Zen_SpawnVehicle;

_staticsquadPosition = [_ParkedCarPosition,[0,20],0,1,[1,10]] call Zen_FindGroundPosition;
_staticSquad = [_staticsquadPosition, east, "infantry", 1] call Zen_SpawnInfantry;

// force them to lie down
{
    _x setUnitPosWeak "DOWN";
} forEach (units _staticSquad);

// Assign the task to player
_alldeadHandle = [MacGyver, X11, _Ifrit] call f_createrendezvousObjective;

// Give the in-line function time to complete
sleep 1;
_X11Task = [X11] call Zen_GetUnitTasks;

// Wait until all tasks are complete
waitUntil {
    sleep 5;
    ([_X11Task] call Zen_AreTasksComplete)
};

endMission "end1";
