#include "Zen_FrameworkFunctions\Zen_InitHeader.sqf"

// Respawn Patrol by Zenophon
// Version = Beta 6/1/14
// Tested with ArmA 3 1.18

// the preprocessor is your friend, \ for new line
#define AI_SKILL "Infantry"
#define PATROL_RADIUS 1000
#define CLEANUP_DISTANCE 400
#define RESPAWN_TIME 65
#define LOADOUTS_OPFOR ["Rifleman", "Rifleman", "Assistant AR", "Team Leader", "Grenadier", "Auto Rifleman", "Marksman", "AT Rifleman", "AT Rifleman", "AT Specialist", "AA Specialist", "Squad Leader", "Assistant AT", "Assistant AA", "Sapper"]
#define LOADOUTS_BLUFOR ["Rifleman", "Rifleman", "Team Leader", "Grenadier", "Auto Rifleman", "Marksman", "AT Rifleman", "AT Specialist", "Squad Leader"]
#define OPFOR_VEHICLES ["O_APC_Wheeled_02_rcws_F", "O_APC_Wheeled_02_rcws_F", "O_MRAP_02_F", "O_MRAP_02_gmg_F", "O_MRAP_02_hmg_F", "O_MRAP_02_hmg_F"]
#define RANDOM_OBJECTIVES ["box", "wreck", "officer", "mortar", "custom", "special"]
#define RANDOM_SPECIAL ["Clear Area", "Defuse IED"]
#define RANDOM_IED ["Land_GarbageBags_F", "land_JunkPile_F"]
#define RESPAWN_BASE _startPos = ["mkBase", [5, 15]] call Zen_FindGroundPosition; \
                    _unit setPosATL _startPos; \
                    _unit setDir random 360; \

// Add objectives
    // Secure crash site
        // plant explosives

// exploit every pattern you see with a loop
_blacklist = [];
for "_i" from 1 to 22 do {
    0 = [_blacklist, format ["mkBlack%1", _i]] call Zen_ArrayAppend;
};

{_x setMarkerAlpha 0;} forEach (_blacklist + ["mkAltis"]);

titleText ["Good Luck", "BLACK FADED", 0.3];
enableSaving [false, false];

// sell it
player createDiaryRecord ["Diary", ["Features", "Endless random objectives of different types<br/>
Respawning players and vehicles<br/>
Random infantry patrols with random loadouts<br/>
Random vehicle patrols, with soft and armored vehicles<br/>
Cleanup of far away enemies and dead objects<br/>
Finely tuned AI accuracy and spotting ability<br/>
Totally random time of day and dynamic weather<br/>
Full JIP compatibility<br/>
Repacking magazines<br/>
Giving magazines to team members with an easy action<br/>
Markers for player groups and vehicles<br/>
Increased weapon lethality<br/>
Automatic rearming and refuelling of vehicles at base<br/>
Supply creates with random equipment<br/>"]];
player createDiaryRecord ["Diary", ["Mission", "You have been deployed to patrol Altis and destroy Opfor units.  Objectives can appear anywhere on the island.  Blufor forces consist of a 6-man infantry squad and a 2-man helicopter crew.  Dead infantry and vehicles will respawn in 1 minute.  Each objective is defended by infantry patrols and vehicles.  You will receive new objectives as you complete them.  Vehicles automatically rearm and refuel at base."]];

// some custom objectives are easy to do
f_AddDefuseAction = {
    0 = (_this select 0) addAction ["Defuse the IED", f_bombDefuse, (_this select 1), 6, true, true, "", "(_caller distance _target) < 3"];
};

f_BombDefuse = {
    removeAllActions (_this select 0);
    0 = [(_this select 3), "succeeded"] call Zen_UpdateTask;
};

// anything remotely executed gets a function
f_ResupplyVehicles_Set_MP = {
    _this setVehicleAmmo 1;
    _this setFuel 1;
};

// keep control over your mission by handling respawn yourself
f_HandleRespawn = {
    if (time < 5) exitWith {};

    0 = _this spawn {
        private ["_unit", "_body"];

        _unit = _this select 0;
        _body = _this select 1;

        if (player == _unit) then {
            titleText ["Still Alive", "BLACK FADED", 0.2];
        };

        0 = [_unit] call Zen_AddGiveMagazine;
        0 = [_unit] call Zen_AddRepackMagazines;
        0 = [_unit, AI_SKILL] call Zen_SetAISkill;

        // parachute insertion for infantry
        if (["heli", typeOf _unit] call Zen_StringIsInString) then {
            0 = [_unit, "Helicopter Pilot"] call Zen_GiveLoadoutBlufor;
            RESPAWN_BASE
        } else {
            if (count units group _unit > 1) then {
                removeBackpack _unit;
                _unit addBackpack "b_parachute";
                0 = [_unit, (((units group _unit) - [_unit]) call Zen_FindAveragePosition), 500, random 360] call Zen_TransformObject;

                0 = _unit spawn {
                    waitUntil {
                        sleep 2;
                        isTouchingGround _this;
                    };

                    0 = [_this, LOADOUTS_BLUFOR] call Zen_GiveLoadoutBlufor;
                };
            } else {
                0 = [_unit, LOADOUTS_BLUFOR] call Zen_GiveLoadoutBlufor;
                RESPAWN_BASE
            };
        };

        // you must maintain tracking respawned units
        if (isServer) then {
            [] call f_ResetTracking;
        } else {
            Zen_MP_Closure_Packet = ["f_ResetTracking", []];
            publicVariableServer "Zen_MP_Closure_Packet";
        };

        0 = [_unit] call Zen_MultiplyDamage;

        sleep 300;
        deleteVehicle _body;
    };
};

#include "JIPSync.sqf"

if (!isServer) exitWith {};
sleep 1;

// Zen_TrackGroups's return values are useful
f_ResetTracking = {
    terminate (h_GroupTrack select 1);
    {
        deleteMarker _x;
    } forEach (h_GroupTrack select 0);

    h_GroupTrack = [west, "none"] call Zen_TrackGroups;
};

// it isn't a base without resupply
f_ResupplyVehicle = {
    private ["_vehicle"];

    _vehicle = _this;

    while {alive _vehicle} do {
        sleep 30;
        if ((isTouchingGround _vehicle) && {[_vehicle, getMarkerPos "mkBase", [100, 100], 0, "ellipse"] call Zen_AreInArea}) then {
            _vehicle call f_ResupplyVehicles_Set_MP;
            Zen_MP_Closure_Packet = ["f_ResupplyVehicles_Set_MP", _vehicle];
            publicVariable "Zen_MP_Closure_Packet";
        };
    };
};

f_InitVehicle = {
    _this spawn f_ResupplyVehicle;

    _this disableTIEquipment true;
    clearItemCargoGlobal _this;
    clearWeaponCargoGlobal _this;
    clearMagazineCargoGlobal _this;
    _this addWeaponCargoGlobal ["arifle_mx_f", 2];
    _this addWeaponCargoGlobal ["launch_B_Titan_short_F", 1];
    _this addWeaponCargoGlobal ["binocular", 1];
    _this addMagazineCargoGlobal ["30Rnd_65x39_caseless_mag", 25];
    _this addMagazineCargoGlobal ["100Rnd_65x39_caseless_mag", 10];
    _this addMagazineCargoGlobal ["HandGrenade", 10];
    _this addMagazineCargoGlobal ["SmokeShell", 10];
    _this addMagazineCargoGlobal ["1Rnd_HE_Grenade_shell", 15];
    _this addMagazineCargoGlobal ["Titan_AT", 3];

    // vehicle tracking must be handled too
    if (time > 30) then {
        terminate (h_VehicleTrack select 1);
        {
            deleteMarker _x;
        } forEach (h_VehicleTrack select 0);

        Blufor_Vehicle_Array = ([Blufor_Vehicle_Array] call Zen_ArrayRemoveDead) + [_this];
        h_VehicleTrack = [Blufor_Vehicle_Array] call Zen_TrackVehicles;
    };

    // fastroping for JIP players
    if (typeOf _this == "I_Heli_light_03_F") then {
        Zen_JIP_Args_Server set [11, _this];
    };
};

// very simple vehicle respawn script, we don't need no engine-based respawn
f_VehicleRespawn = {
    private ["_vehicle", "_timer", "_startPos", "_code", "_className", "_oldVehicle"];

    _vehicle = _this select 0;
    _timer = _this select 1;

    _startPos = getPosATL _vehicle;
    _code = "";

    if (count _this > 2) then {
        _startPos = [(_this select 2)] call Zen_ConvertToPosition;
    };

    if (count _this > 3) then {
        _code = _this select 3;
    };

    _oldVehicle = objNull;
    _className = typeOf _vehicle;

    // main loop to detect death of vehicle
    while {true} do {
        // can run custom code on respawn
        if (_code != "") then {
            _vehicle call (missionNamespace getVariable _code);
        };

        waitUntil {
            sleep 5;
            (!(alive _vehicle) || !(canMove _vehicle))
        };

        sleep _timer;

        if !(isNull _oldVehicle) then {
            deleteVehicle _oldVehicle;
        };

        sleep 5;

        _oldVehicle = _vehicle;
        _vehicle = [_startPos, _className, 0, 130] call Zen_SpawnVehicle;
    };
};

// some custom objectives are easy to do
f_ClearAreaObjective = {
    _s_ret_objTask = [_a_o_players, "Eliminate all hostiles in about a 1km radius from the objective position.  UAV support has revealed hostile locations.", "Clear the Area", _p_ret_objective, true] call Zen_InvokeTask;
    0 = [east, _s_ret_objTask, "succeeded", _m_ret_patrol] spawn Zen_TriggerAreaClear;
};

f_DefuseIEDObjective = {
    _p_ret_IED = [_m_ret_patrol, 0, [], 1, [1, 1200]] call Zen_FindGroundPosition;
    _s_ret_objTask = [_a_o_players, "Resistance reports indicate the presence of an IED along a road near the objective position.  Find and defuse this device carefully before Blufor personnel or civilians are harmed.", "Find and Defuse IED", _p_ret_IED, true] call Zen_InvokeTask;

    // see the MP Remote Action demonstration for more about these kind of actions
    _s_ret_IEDClass = [RANDOM_IED] call Zen_ArrayGetRandom;
    _o_ret_IED = [([_p_ret_IED, [5, 50], [], 1, [1, 50]] call Zen_FindGroundPosition), _s_ret_IEDClass] call Zen_SpawnVehicle;

    [_o_ret_IED, _s_ret_objTask] call f_addDefuseAction;
    Zen_MP_Closure_Packet = ["f_addDefuseAction", [_o_ret_IED, _s_ret_objTask]];
    publicVariable "Zen_MP_Closure_Packet";
};

// the core objective and enemy generator
f_ObjectiveTemplate = {
    _s_ret_randomType = [RANDOM_OBJECTIVES] call Zen_ArrayGetRandom;

    if (_s_ret_randomType == "custom") then {
        _s_customClass = [OPFOR_VEHICLES] call Zen_ArrayGetRandom;
    };

    _b_showEnemy = false;
    _m_ret_patrol = [_p_ret_objective, "", "colorBlack", [PATROL_RADIUS + random 200, PATROL_RADIUS + random 200], "ellipse", 0, 0] call Zen_SpawnMarker;

    // how to combine those custom objectives with Zen_CreateObjective
    if (_s_ret_randomType == "special") then {
        _s_ret_randomSpecial = [RANDOM_SPECIAL] call Zen_ArrayGetRandom;

        switch (_s_ret_randomSpecial) do {
            case "Clear Area": {
                _b_showEnemy = true;
                [] call f_ClearAreaObjective;
            };
            case "Defuse IED": {
                [] call f_DefuseIEDObjective;
            };
        };
    } else {
        _a_ret_objective = [_p_ret_objective, _a_o_players, east, _s_ret_randomType, "eliminate", _s_customClass] call Zen_CreateObjective;
        _o_ret_objObj = (_a_ret_objective select 0) select 0;
        _s_ret_objTask = _a_ret_objective select 1;
    };

    // get those custom vehicles moving
    if (_s_ret_randomType == "custom") then {
        0 = [_o_ret_objObj, east] call Zen_SpawnVehicleCrew;
        0 = [_s_ret_objTask, _o_ret_objObj] call Zen_SetTaskTarget;

        if (_o_ret_objObj isKindOf "air") then {
            0 = [_o_ret_objObj, _m_ret_patrol] spawn Zen_OrderAircraftPatrol;
        } else {
            0 = [_o_ret_objObj, _m_ret_patrol] spawn Zen_OrderVehiclePatrol;
        };
    };

    // lots of spawning, the basic algorithm is always the same
    _a_g_patrol = [];
    _a_o_Vehpatrol = [];
    for "_i" from 1 to (7 + random 2) do {
        _p_ret_spawn = [_m_ret_patrol] call Zen_FindGroundPosition;
        _g_ret_patrol = [_p_ret_spawn, east, AI_SKILL, [5, 7]] call Zen_SpawnInfantry;
        0 = [_g_ret_patrol, LOADOUTS_OPFOR] call Zen_GiveLoadoutOpfor;
        _a_g_patrol set [(count _a_g_patrol), _g_ret_patrol];
    };

    // vehicles can have a crew of any side you want
    for "_i" from 1 to (3 + random 1) do {
        _p_ret_spawn = [_m_ret_patrol] call Zen_FindGroundPosition;
        _o_ret_patrol = [_p_ret_spawn, ([OPFOR_VEHICLES] call Zen_ArrayGetRandom)] call Zen_SpawnVehicle;
        0 = [_o_ret_patrol, east] call Zen_SpawnVehicleCrew;
        _a_o_Vehpatrol set [(count _a_o_Vehpatrol), _o_ret_patrol];
    };

    0 = [_a_g_patrol, _m_ret_patrol] spawn Zen_OrderInfantryPatrol;
    0 = [_a_o_Vehpatrol, _m_ret_patrol] spawn Zen_OrderVehiclePatrol;

    if (_b_showEnemy) then {
        0 = [_a_g_patrol, "none"] call Zen_TrackGroups; // debug
        0 = [_a_o_Vehpatrol] call Zen_TrackVehicles; // debug
    };
};

// the game is organized by turns, one objective per turn
f_ObjectiveTurn = {
    _a_o_players = [(units _g_X1 + units _g_X2)] call Zen_ArrayRemoveDead;
    _p_ret_playerCenter = (units _g_X1) call Zen_FindAveragePosition;

    // cleanup
    {
        if (!(isNull _x) && {(([([_a_o_players, _x] call Zen_FindMinDistance), _x] call Zen_Find2dDistance) > CLEANUP_DISTANCE)}) then {
            deleteVehicle _x;
        };
    } forEach +(allUnits + allDead);

    {
        if (!(isNull _x) && {(count units _x == 0)}) then {
            deleteGroup _x;
        };
    } forEach +allGroups;

    // an ammo box back at base
    _boxPos = ["mkBase", [5, 15]] call Zen_FindGroundPosition;
    _supplyBoxBase = [_boxPos, west] call Zen_SpawnAmmoBox;

    // how to do an ammo resupply drop, simple and easy
    _p_ret_heliSpawn = [_p_ret_playerCenter, [1600, 1700], [], 0] call Zen_FindGroundPosition;
    _o_B_resupplyHeli = [_p_ret_heliSpawn, "B_Heli_Transport_01_F", 40] call Zen_SpawnHelicopter;
    _supplyBoxDrop = [_p_ret_heliSpawn, west] call Zen_SpawnAmmoBox;
    _h_resupply = [_o_B_resupplyHeli, [_p_ret_playerCenter, [0,0,0]], _supplyBoxDrop] spawn Zen_OrderVehicleDrop;

    {
        _x addItemCargoGlobal ["FirstAidKit", 10];
        _x addMagazineCargoGlobal ["30Rnd_65x39_caseless_mag", 25];
        _x addMagazineCargoGlobal ["100Rnd_65x39_caseless_mag", 10];
        _x addMagazineCargoGlobal ["HandGrenade", 10];
        _x addMagazineCargoGlobal ["SmokeShell", 5];
        _x addMagazineCargoGlobal ["1Rnd_HE_Grenade_shell", 15];
        _x addMagazineCargoGlobal ["Titan_AT", 2];
    } forEach [_supplyBoxBase, _supplyBoxDrop];

    // cleanup the helicopter
    0 = [_h_resupply, _o_B_resupplyHeli] spawn {
        waitUntil {
            sleep 5;
            (scriptDone (_this select 0))
        };
        {
            deleteVehicle _x;
        } forEach ((crew (_this select 1)) + [(_this select 1)]);
    };

    _p_ret_objective = ["mkAltis", 0, _blacklist, 1, 0, 0, [1,0,15], [1, "mkBase", 2500], [1, 250]] call Zen_FindGroundPosition;

    // some weather management
    if ((time - _fogStart) > _fogTime) then {
        0 = [["fog", -1, random 0.05, _fogTime]] spawn Zen_SetWeather;
        Zen_JIP_Args_Server set [7, time];
    };

    if ((time - _overcastStart) > _overcastTime) then {
        0 = [["overcast", -1, random 1, _overcastTime]] spawn Zen_SetWeather;
        Zen_JIP_Args_Server set [3, time];
    };

    // this now creates the objective
    [] call f_ObjectiveTemplate;
    0 = [allUnits, true] call Zen_MultiplyDamage;
};

// define variables, recall that called functions are a lower scope, so these could be used in f_ObjectiveTurn, etc.
_s_customClass = "";
_g_X1 = group X;
_g_X2 = group P;
_a_o_players = units _g_X1 + units _g_X2;

_overcastTime = 60*60;
_fogTime = 60*30;
_overcastStart = time;
_fogStart = time;

// set up JIP and respawning
Blufor_Vehicle_Array = [B_APC_01, B_Truck_01, B_Heli_01];
Zen_JIP_Args_Server = [time, overcast, overcastForecast, _overcastStart, _overcastTime, fog, fogForecast, _fogStart, _fogTime, 3000, [_g_X1, _g_X2], B_Heli_01];

{
    0 = [_x, RESPAWN_TIME, _x, "f_InitVehicle"] spawn f_VehicleRespawn;
} forEach Blufor_Vehicle_Array;

{
    _x addMPEventHandler ["MPRespawn", f_HandleRespawn];
} forEach _a_o_players;

// A full, standard mission start, just ["date"] means totally random
0 = [3000] call Zen_SetViewDistance;
0 = [["overcast", random 1, random 1, _overcastTime], ["fog", random 0.05, random 0.05, _fogTime], ["date"]] spawn Zen_SetWeather;

0 = [_a_o_players] call Zen_AddGiveMagazine;
0 = [_a_o_players] call Zen_AddRepackMagazines;
0 = [_a_o_players, AI_SKILL] call Zen_SetAISkill;

0 = [_g_X1, LOADOUTS_BLUFOR] call Zen_GiveLoadoutBlufor;
0 = [_g_X2, "Helicopter Pilot"] call Zen_GiveLoadoutBlufor;
0 = [B_Heli_01] call Zen_AddFastRope;

// declare the tracking global variables
h_GroupTrack = [west, "none"] call Zen_TrackGroups;
h_VehicleTrack = [Blufor_Vehicle_Array] call Zen_TrackVehicles;

sleep 4;
private ["_s_ret_randomType", "_o_ret_objObj", "_s_ret_objTask"];

// the main loop, infinite and simple
while {true} do {
    [] call f_ObjectiveTurn;

    waitUntil {
        sleep 10;
        if ((_s_ret_randomType == "custom") && {(({alive _x} count crew _o_ret_objObj) == 0 || !(canMove _o_ret_objObj))}) then {
            0 = [_s_ret_objTask, "succeeded"] call Zen_UpdateTask;
        };
        ([_s_ret_objTask] call Zen_AreTasksComplete)
    };

    // winning is a state of mind, but feedback helps, this is only for SP though
    activateKey "BIS_Zen_RespawnPatrol.Altis_done";
};

