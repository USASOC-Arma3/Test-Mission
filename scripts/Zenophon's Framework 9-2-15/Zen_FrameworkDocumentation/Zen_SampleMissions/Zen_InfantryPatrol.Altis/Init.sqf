#include "Zen_FrameworkFunctions\Zen_InitHeader.sqf"

// Infantry Patrol by Zenophon
// Version = 5/24/14
// Tested with ArmA 3 1.18

// the preprocessor is your friend
#define AI_SKILL "Infantry"
#define LOADOUTS_OPFOR ["Rifleman", "Rifleman", "Assistant AR", "Team Leader", "Grenadier", "Auto Rifleman", "Marksman", "AT Rifleman", "AT Rifleman", "AT Specialist"]
#define LOADOUTS_BLUFOR ["Rifleman", "Rifleman", "Team Leader", "Grenadier", "Auto Rifleman", "Marksman", "AT Rifleman"]
#define INDFOR_VEHICLES ["I_MRAP_03_F", "I_MRAP_03_hmg_F", "B_G_Offroad_01_armed_F"]
#define CIV_VEHICLES ["C_Hatchback_01_F", "C_Hatchback_01_sport_F", "C_Offroad_01_F", "C_SUV_01_F", "C_Van_01_transport_F"]
#define RANDOM_OBJECTIVES ["box", "wreck", "officer", "mortar", "custom", "special"]
#define RANDOM_SPECIAL ["Clear Area", "Defuse IED"]
#define RANDOM_IED ["Land_GarbageBags_F", "land_JunkPile_F"]

// exploit every pattern you see with a loop
_blacklist = [];
for "_i" from 1 to 8 do {
    0 = [_blacklist, format ["mkBlack%1", _i]] call Zen_ArrayAppend;
};

{_x setMarkerAlpha 0;} forEach (_blacklist + ["mkAll"]);

titleText ["Good Luck", "BLACK FADED", 0.3];
enableSaving [false, false];

// if you don't advertise your mission's features, no one will
player createDiaryRecord ["Diary", ["Features", "Endless random objectives of different types<br/>Random infantry patrols with random loadouts<br/>Random vehicle patrols<br/>Random civilian cars in towns<br/>Cleanup of far away enemies and dead objects<br/>Finely tuned AI skill settings<br/>Random time of day and weather<br/>Full JIP compatibility<br/>Repacking magazines<br/>Giving magazines to team members with an easy action<br/>Marker script for player groups and vehicles<br/>Increased weapon lethality<br/>Reinforcements delivered to replace lost units<br/>Automatic resupply of AI after objective completion<br/>Supply drops with random equipment for players"]];
player createDiaryRecord ["Diary", ["Mission", "You have been deployed to patrol Altis and destroy Indfor units.  Blufor forces consist of two 4-man infantry fireteams.  Each objective is defended by infantry patrols and vehicles.  You will receive new objectives as you complete them.  Dead infantry will be replaced with reinforcements every turn.  There is extra ammo and AT weapons in the vehicles, and all AI units will receive extra magazines after each objective is completed.  You can steal civilian cars in towns."]];

f_joinSwitchable = {
    private ["_units", "_leader"];
    _units = [(_this select 0)] call Zen_ConvertToObjectArray;
    _leader = _this select 1;

    // addSwitchableUnit works fine in singleplayer
    // setPlayable does not work in multiplayer, confirmed by a developer in the ticket
    // a player cannot respawn into an AI that is set playable
    // this is a known issue that BIS must fix
    // vote: http://feedback.arma3.com/view.php?id=7915
    // this function is included anyway, in the hope that this is someday fixed
    {
        setPlayable _x;
        addSwitchableUnit _x;
    } forEach _units;

    _units join _leader;
};

// for more custom action fun, see the MP Remote Action demonstration
f_addDefuseAction = {
    0 = (_this select 0) addAction ["Defuse the IED", f_bombDefuse, (_this select 1), 6, true, true, "", "(_caller distance _target) < 3"];
};

f_bombDefuse = {
    removeAllActions (_this select 0);
    0 = [(_this select 3), "succeeded"] call Zen_UpdateTask;
};

// for the hardcore, quitters need not apply
f_removeFirstAid = {
    {
        _x removeItem "FirstAidKit";
        _x removeItem "FirstAidKit";
    } forEach _this;
};

#include "JIPSync.sqf"

if (!isServer) exitWith {};

// the AI are a little slow, so automating their resupply saves players a headache
f_resupplyInfantry = {
    private ["_units", "_i", "_mag"];
    _units = [(_this select 0)] call Zen_ConvertToObjectArray;

    sleep 3;
    // here we have the standard way to fill inventory with magazines from any weapon
    {
        if (!(isPlayer _x) && ((primaryWeapon _x) != "")) then {
            _mag = (getArray (configFile >> "CfgWeapons" >> (primaryWeapon _x) >> "magazines")) select 0;
            for "_i" from 1 to 5 do {
                _x addMagazineGlobal _mag;
            };
        };
    } forEach _units;
    if (true) exitWith {};
};

// the first reinforcement function, this just waits for them to land and joins them
f_syncReinforcements = {
    private ["_a_g_arg_reinforcements", "_a_g_arg_existingGroups", "_h_insertion", "_o_insertionHeli", "_group", "_reinfGroup"];

    _a_g_arg_reinforcements = _this select 0;
    _a_g_arg_existingGroups = _this select 1;
    _h_insertion = _this select 2;
    _o_insertionHeli = _this select 3;

    sleep 5;
    {
        _reinfGroup = _x;
        waitUntil {
            sleep 5;
            (isTouchingGround (leader _reinfGroup))
        };
        sleep 5;

        // sharing tasks is made easy
        _group = _a_g_arg_existingGroups select _forEachIndex;
        {
            0 = [_x, _reinfGroup] call Zen_ReassignTask;
        } forEach ([(leader _group)] call Zen_GetUnitTasks);

        0 = [_reinfGroup, (leader _group)] call f_joinSwitchable;

        Zen_MP_Closure_Packet = ["f_joinSwitchable", [_reinfGroup, (leader _group)]];
        publicVariable "Zen_MP_Closure_Packet";
    } forEach _a_g_arg_reinforcements;

    waitUntil {
        sleep 5;
        (scriptDone _h_insertion)
    };

    // always cleanup
    {
        deleteVehicle _x;
    } forEach (crew _o_insertionHeli + [_o_insertionHeli]);
};

// this creates and inserts the reinforcements, it adapts to the number and size of groups
f_sendReinforcements = {
    private ["_groupsArray", "_groupUnitsMaxArray", "_groupUnitsNeeded", "_groupsArrayRemove", "_reinforceGroupArray", "_i", "_totalCount", "_reinforceGroupsCargo", "_reinforceGroup", "_h_insertion", "_posAvg", "_landPos", "_heliSpawnPos", "_reinforceHeli"];

    _groupsArray = _this select 0;
    _groupUnitsMaxArray = _this select 1;

    // all of this figures out which groups need how many units
    _groupUnitsNeeded = [];
    {
        _groupUnitsNeeded set [(count _groupUnitsNeeded), ((_groupUnitsMaxArray select _forEachIndex) - (count units _x))];
    } forEach _groupsArray;

    // and removes those who need 0
    _groupsArrayRemove = [];
    {
        if (_x == 0) then {
            _groupsArrayRemove set [(count _groupsArrayRemove), (_groupsArray select _forEachIndex)];
        };
    } forEach _groupUnitsNeeded;

    // the group-number indexes still match up correctly
    _groupsArray = _groupsArray - _groupsArrayRemove;
    _groupUnitsNeeded = _groupUnitsNeeded - [0];

    if (count _groupUnitsNeeded == 0) exitWith {};

    // now spawn the reinforcements and assign them to an array
    _reinforceGroupArray = [];
    {
        _reinforceGroup = [[0,0,0], west, "infantry", _x] call Zen_SpawnInfantry;
        _reinforceGroupArray set [(count _reinforceGroupArray), _reinforceGroup];
    } forEach _groupUnitsNeeded;

    0 = [_reinforceGroupArray] call Zen_GiveLoadoutBlufor;
    0 = [_reinforceGroupArray] call Zen_AddGiveMagazine;
    0 = [_reinforceGroupArray] call Zen_AddRepackMagazines;

    while {true} do {
        _i = 0;
        _totalCount = 0;
        _reinforceGroupsCargo = [];

        // this now divides up the reinforcements to fit in their insertion vehicle
        while {true} do {
            _totalCount = _totalCount + (count units (_reinforceGroupArray select _i));
            _reinforceGroupsCargo set [(count _reinforceGroupsCargo), (_reinforceGroupArray select _i)];
            _i = _i + 1;
            if (_totalCount > 8 || _i >= (count _reinforceGroupArray)) exitWith {};
        };

        // however many reinforcement groups fit, select their corresponding destination groups
        _receivingGroups = [_groupsArray, 0, _i - 1] call Zen_ArrayGetIndexedSlice;

        // helicopter insertion of reinforcements
        _posAvg = _receivingGroups call Zen_FindAveragePosition;
        _landPos = [_posAvg, [5, 125], [], 1, [1, 200]] call Zen_FindGroundPosition;
        _heliSpawnPos = [_landPos, [1500, 1700], [], 0] call Zen_FindGroundPosition;
        _reinforceHeli = [_heliSpawnPos, "b_heli_transport_01_f"] call Zen_SpawnHelicopter;
        0 = [_reinforceGroupsCargo, _reinforceHeli] call Zen_MoveInVehicle;

        // threads to get the insertion and joining of groups
        _h_insertion = [_reinforceHeli, [_landPos, [0,0,0]], _reinforceGroupsCargo, "normal", 60, "fastrope"] spawn Zen_OrderInsertion;
        0 = [_reinforceGroupsCargo, _receivingGroups, _h_insertion, _reinforceHeli] spawn f_syncReinforcements;

        // remove the group pairs we just inserted, and continue the loop if we need another helicopter
        _groupsArray = _groupsArray - _receivingGroups;
        _reinforceGroupArray = _reinforceGroupArray - _reinforceGroupsCargo;
        if (count _groupsArray == 0) exitWith {};
    };
};

// some custom objectives are easy to do
f_ClearAreaObjective = {
    _s_ret_objTask = [_a_o_players, "Eliminate all hostiles in about a 1km radius from the objective position.  UAV support has revealed hostile locations.", "Clear the Area", _p_ret_objective, true] call Zen_InvokeTask;
    0 = [resistance, _s_ret_objTask, "succeeded", _m_ret_patrol] spawn Zen_TriggerAreaClear;
};

f_DefuseIEDObjective = {
    _p_ret_IED = [_m_ret_patrol, 0, [], 1, [1, 800]] call Zen_FindGroundPosition;
    _s_ret_objTask = [_a_o_players, "The resistance has planted an IED along a road near the objective position.  Find and defuse this device carefully before Blufor personnel or civilians are harmed.", "Find and Defuse IED", _p_ret_IED, true] call Zen_InvokeTask;

    // all of this is done by the server, but the clients will be able to interact with it just fine
    _s_ret_IEDClass = [RANDOM_IED] call Zen_ArrayGetRandom;
    _o_ret_IED = [([_p_ret_IED, random 50, random 360] call Zen_ExtendPosition), _s_ret_IEDClass] call Zen_SpawnVehicle;

    [_o_ret_IED, _s_ret_objTask] call f_addDefuseAction;
    Zen_MP_Closure_Packet = ["f_addDefuseAction", [_o_ret_IED, _s_ret_objTask]];
    publicVariable "Zen_MP_Closure_Packet";
};

// the core objective and enemy generator
f_ObjectiveTemplate = {
    _s_ret_randomType = [RANDOM_OBJECTIVES] call Zen_ArrayGetRandom;

    if (_s_ret_randomType == "custom") then {
        _s_customClass = [INDFOR_VEHICLES] call Zen_ArrayGetRandom;
    };

    _b_showEnemy = false;
    _m_ret_patrol = [_p_ret_objective, "", "colorBlack", [800 + random 200, 800 + random 200], "ellipse", 0, 0] call Zen_SpawnMarker;

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
        _a_ret_objective = [_p_ret_objective, _a_o_players, resistance, _s_ret_randomType, "eliminate", _s_customClass] call Zen_CreateObjective;
        _o_ret_objObj = (_a_ret_objective select 0) select 0;
        _s_ret_objTask = _a_ret_objective select 1;
    };

    // get those custom vehicles moving, use Zen_SpawnVehicleCrew to put the 'wrong' side crew into a vehicle
    if (_s_ret_randomType == "custom") then {
        0 = [_o_ret_objObj, resistance] call Zen_SpawnVehicleCrew;
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
    for "_i" from 0 to (5 + random 2) do {
        _p_ret_spawn = [_m_ret_patrol] call Zen_FindGroundPosition;
        _g_ret_patrol = [_p_ret_spawn, resistance, AI_SKILL, [3, 6]] call Zen_SpawnInfantry;
        0 = [_g_ret_patrol, LOADOUTS_OPFOR] call Zen_GiveLoadoutIndfor;
        _a_g_patrol set [(count _a_g_patrol), _g_ret_patrol];
    };

    // just double now that there are vehicles
    for "_i" from 0 to (2 + random 1) do {
        _p_ret_spawn = [_m_ret_patrol] call Zen_FindGroundPosition;
        _o_ret_patrol = [_p_ret_spawn, ([INDFOR_VEHICLES] call Zen_ArrayGetRandom)] call Zen_SpawnVehicle;
        0 = [_o_ret_patrol, resistance] call Zen_SpawnVehicleCrew;
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
    // set up the variables needed for the turn
    _a_o_players = [(units _g_X1 + units _g_X2)] call Zen_ArrayRemoveDead;
    _p_ret_playerCenter = _a_o_players call Zen_FindAveragePosition;

    0 = [_a_o_players] spawn f_resupplyInfantry;

    // cleanup
    {
        if (([([_a_o_players, _x] call Zen_FindMinDistance), _x] call Zen_Find2dDistance) > 400) then {
            deleteVehicle _x;
        };
    } forEach (allUnits + allDead);

    {
        if (count units _x == 0) then {
            deleteGroup _x;
        };
    } forEach allGroups;

    // how to do an ammo resupply drop, simple and easy
    _p_ret_heliSpawn = [_p_ret_playerCenter, [1600, 1700], [], 0] call Zen_FindGroundPosition;
    _o_B_resupplyHeli = [_p_ret_heliSpawn, "B_Heli_Transport_01_F", 30] call Zen_SpawnHelicopter;
    _o_B_box = [_p_ret_heliSpawn, west] call Zen_SpawnAmmoBox;
    _h_resupply = [_o_B_resupplyHeli, [_p_ret_playerCenter, [0,0,0]], _o_B_box] spawn Zen_OrderVehicleDrop;

    _o_B_box addItemCargoGlobal ["FirstAidKit", 10];
    _o_B_box addMagazineCargoGlobal ["30Rnd_65x39_caseless_mag", 25];
    _o_B_box addMagazineCargoGlobal ["100Rnd_65x39_caseless_mag", 10];
    _o_B_box addMagazineCargoGlobal ["HandGrenade", 10];
    _o_B_box addMagazineCargoGlobal ["SmokeShell", 5];
    _o_B_box addMagazineCargoGlobal ["1Rnd_HE_Grenade_shell", 15];
    _o_B_box addMagazineCargoGlobal ["Titan_AT", 2];

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

    _p_ret_objective = [_p_ret_playerCenter, [1000, 1600], _blacklist, 1, 0, 0, [1,0,15], 0, [1, 150]] call Zen_FindGroundPosition;

    // spawning cars in towns, it is done this way so we don't spawn in one town twice, as calling Zen_SpawnAmbientVehicles twice would
    _a_m_remove = [];
    {
        if ((([_x, _p_ret_playerCenter] call Zen_Find2dDistance) < 1500) || (([_x, _p_ret_objective] call Zen_Find2dDistance) < 1500)) then {
            _a_m_remove set [(count _a_m_remove), _x];
            for "_j" from 0 to (2 + random 2) do {
                _p_ret_spawnCar = [_x, 0, [], 1, [2, 500], 0, [1,0,15]] call Zen_FindGroundPosition;
                _s_ret_vehType = [CIV_VEHICLES] call Zen_ArrayGetRandom;
                _o_ret_civVeh = [_p_ret_spawnCar, _s_ret_vehType, 0, random 360] call Zen_SpawnVehicle;
                // 0 = [_p_ret_spawnCar] call Zen_SpawnMarker; // debug
            };
        };
    } forEach _a_m_towns;
    _a_m_towns = _a_m_towns - _a_m_remove;

    // some weather management
    if (time - _fogStart > _fogTime) then {
        0 = [["fog", -1, random 0.2, 60*15]] spawn Zen_SetWeather;
        Zen_JIP_Args_Server set [7, time];
    };

    if (time - _overcastStart > _overcastTime) then {
        0 = [["overcast", -1, random 0.5, 60*45]] spawn Zen_SetWeather;
        Zen_JIP_Args_Server set [3, time];
    };

    // this now creates the objective
    0 = [_groups, _groupMaxs] call f_sendReinforcements;
    [] call f_ObjectiveTemplate;

    0 = [allUnits, true] call Zen_MultiplyDamage;

    // enable it if you dare
    // 0 = allUnits call f_removeFirstAid;
    // Zen_MP_Closure_Packet = ["f_removeFirstAid", allUnits];
    // publicVariable "Zen_MP_Closure_Packet";
};

// define variables, recall that called functions are a lower scope, so these could be used in f_ObjectiveTurn, etc.
_groups = 0;
_groupMaxs = [];
_s_customClass = "";
_g_X1 = group X11;
_g_X2 = group X21;
_a_o_players = units _g_X1 + units _g_X2;

// set up the data for reinforcements
if (isMultiplayer) then {
    _groups = [playableUnits] call Zen_ConvertToGroupArray;
} else {
    _groups = [switchableUnits] call Zen_ConvertToGroupArray;
};

// this array will be used by the reinforcement functions
{
    _groupMaxs set [(count _groupMaxs), (count units _x)];
} forEach _groups;

{
    _x disableTIEquipment true;
    clearItemCargoGlobal _x;
    clearWeaponCargoGlobal _x;
    clearMagazineCargoGlobal _x;
    _x addWeaponCargoGlobal ["arifle_mx_f", 2];
    _x addWeaponCargoGlobal ["launch_B_Titan_short_F", 1];
    _x addWeaponCargoGlobal ["binocular", 1];
    _x addMagazineCargoGlobal ["30Rnd_65x39_caseless_mag", 25];
    _x addMagazineCargoGlobal ["100Rnd_65x39_caseless_mag", 10];
    _x addMagazineCargoGlobal ["HandGrenade", 10];
    _x addMagazineCargoGlobal ["SmokeShell", 10];
    _x addMagazineCargoGlobal ["1Rnd_HE_Grenade_shell", 15];
    _x addMagazineCargoGlobal ["Titan_AT", 3];
} forEach [X1_Car, X2_Car];

_a_m_towns = [["NameVillage", "NameCity", "NameCityCapital"]] call Zen_ConfigGetLocations;
_startPos = ["mkAll", 0, _blacklist, 1, 0, 0, [1, 2, 50], 0, [1, 500], [1, 15, 25], [1, [2, -1, -1], 40]] call Zen_FindGroundPosition;
"mkStart" setMarkerPos _startPos;

// moving and rotating together can put units inside the terrain, etc.
sleep 0.5;
0 = [[X1_Car, X2_Car, _a_o_players], _startPos] call Zen_MoveAsSet;
sleep 0.5;
0 = [[X1_Car, X2_Car, _a_o_players], (random 360)] call Zen_RotateAsSet;
sleep 0.5;

_overcastTime = 60*45;
_fogTime = 60*15;
_overcastStart = time;
_fogStart = time;

// A full, standard mission start
0 = [3000] call Zen_SetViewDistance;
0 = [["overcast", random 0.8, random 0.1, _overcastTime], ["fog", random 0.2, random 0.2, _fogTime], ["date", random 60, 9 + random 6]] spawn Zen_SetWeather;

0 = [_a_o_players] call Zen_AddGiveMagazine;
0 = [_a_o_players] call Zen_AddRepackMagazines;
0 = [_a_o_players, LOADOUTS_BLUFOR] call Zen_GiveLoadoutBlufor;
0 = [_a_o_players, AI_SKILL] call Zen_SetAISkill;
0 = [_a_o_players, "none"] call Zen_TrackGroups;
0 = [[X1_Car, X2_Car]] call Zen_TrackVehicles;

// most JIP arguments look similar
Zen_JIP_Args_Server = [time, overcast, overcastForecast, _overcastStart, _overcastTime, fog, fogForecast, _fogStart, _fogTime, 3000, [_g_X1, _g_X2]];

sleep 4;
private ["_s_ret_randomType", "_o_ret_objObj", "_s_ret_objTask"];

// TL's should have them
{
    _x addWeaponGlobal "binocular";
} forEach [X11, X21];

// the main loop, infinite yet simple
while {true} do {
    [] call f_ObjectiveTurn;

    waitUntil {
        sleep 5;
        if ((_s_ret_randomType == "custom") && {(({alive _x} count crew _o_ret_objObj) == 0 || !(canMove _o_ret_objObj))}) then {
            0 = [_s_ret_objTask, "succeeded"] call Zen_UpdateTask;
        };
        ([_s_ret_objTask] call Zen_AreTasksComplete)
    };

    // winning is a state of mind, but feedback helps, this is only for SP though
    activateKey "BIS_Zen_InfantryPatrol.Altis_done";
};
