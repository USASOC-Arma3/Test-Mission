#include "Zen_FrameworkFunctions\Zen_InitHeader.sqf"

// Attack the Compound by Zenophon
// Version = Final 12/14/13
// Tested with ArmA 3 -- 1.16

#define AI_SKILL "infantry"

// A more realistic briefing than some, with linked map markers
player createDiaryRecord ["Diary", ["Execution", "Insertion by UH-80 near the <marker name='mkInsertion_3'>beach</marker> will be accompanied by artillery fire across a large area.<br/><br/>An AH-9 will provide CAS and eliminate any Indfor vehicles.  While it is not available for CAS tasking directly, it will continue to patrol the AO.<br/> <br/>Each squad is assigned a third of the AO to attack, with the goal of engaging and holding enemy patrols so they cannot consolidate a defense of the compound.  Squads on the east and west will advance south the cut off Indfor patrols from the compound, allowing us to surround it and assault it from all sides.  All squads must gain ground quickly to prevent the Indfor from creating a single defensive front.<br/><br/>There will be no extraction from the AO.  Each squad will set up defensive positions in their AOR and prepare to defend the compound against a counter-attack."]];
player createDiaryRecord ["Diary", ["Mission", "Clear all enemy forces from the compound and the surrounding countryside.  Find and eliminate all enemy vehicles and any other assets or supplies that the enemy has in the compound."]];
player createDiaryRecord ["Diary", ["Situation", "Resistance forces have seized a weapons research and storage <marker name='mkCampCenter'>compound</marker> in an attempt to obtain an unknown quantity of chemical weapons.  Indfor forces consist of several platoons of infantry and one or more armored vehicles.  Intel suggests that most Indfor forces are staying close to the compound, and they have few reinforcements to call on. <br/> <br/>Blufor forces consist of three 6-man squads, three UH-80's, and one AH-9.  We also have artillery support to suppress the compound and surrounding area."]];

titleText ["Good Luck", "BLACK FADED", 0.3];
enableSaving [false, false];
{_x setMarkerAlpha 0;} forEach ["mkPatrolEast", "mkPatrolWest", "mkCampCenter"];

// fun with identities, all the AI in the player's group now get names with working sounds
_a_s_names = [];
_cfgIds = configFile >> "CfgIdentities";
for "_i" from 0 to ((count _cfgIds) - 1) do {
    _configPath = _cfgIds select _i;
    _identity = configName _configPath;
    _name = getText (_configPath >> "name");
    _nameSound = getText (_configPath >> "nameSound");
    if ((_name == _nameSound) && !(_identity in _a_s_names)) then {
        _a_s_names set [(count _a_s_names), _identity];
    };
};

{
    if !(isPlayer _x) then {
        _s_ret_name = [_a_s_names] call Zen_ArrayGetRandom;
        _x setIdentity _s_ret_name;
        _a_s_names = _a_s_names - [_s_ret_name];
    };
} forEach (units group X11);

// shuffle the groups, so the player group could insert anywhere
_a_o_ret_leaders = [X11, X21, X31];
0 = [_a_o_ret_leaders] call Zen_ArrayShuffle
_a_g_players = [];
{
    0 = [_a_g_players, (group _x)] call Zen_ArrayAppend;
} forEach _a_o_ret_leaders;

_g_X1 = _a_g_players select 0;
_g_X2 = _a_g_players select 1;
_g_X3 = _a_g_players select 2;

sleep 1;
if (!isServer) exitWith {};

// triplicate fun here, this mission really has three parts to it
// this is everything you would do to set up a mission for multiple squads of players
_o_ret_inHeli1 = ["mkBase_1", "B_Heli_Transport_01_F", 25, 180] call Zen_SpawnHelicopter;
_o_ret_inHeli2 = ["mkBase_2", "B_Heli_Transport_01_F", 25, 90] call Zen_SpawnHelicopter;
_o_ret_inHeli3 = ["mkBase_3", "B_Heli_Transport_01_F", 25, 270] call Zen_SpawnHelicopter;

0 = [_g_X1, _o_ret_inHeli1] call Zen_MoveInVehicle;
0 = [_g_X2, _o_ret_inHeli2] call Zen_MoveInVehicle;
0 = [_g_X3, _o_ret_inHeli3] call Zen_MoveInVehicle;

0 = [2000] call Zen_SetViewDistance;
0 = [["date", random 60, 5 + random 5], ["overcast", random 0.7, random 0.4, 60*35], ["fog", random 0.8, random 0.1, 60*10]] spawn Zen_SetWeather;

0 = [[_g_X1, _g_X2, _g_X3], ["Team Leader", "Rifleman", "Grenadier", "Auto Rifleman", "Marksman", "AT Rifleman", "Assistant AR"]] call Zen_GiveLoadoutBlufor;
0 = [[_g_X1, _g_X2, _g_X3]] call Zen_AddRepackMagazines;
0 = [[_g_X1, _g_X2, _g_X3]] call Zen_AddGiveMagazine;

0 = [[_g_X1, _g_X2, _g_X3], "none"] call Zen_TrackGroups;
0 = [[_g_X1, _g_X2, _g_X3], "sof"] call Zen_SetAISkill;
0 = [[_o_ret_inHeli1, _o_ret_inHeli2, _o_ret_inHeli3], ["Team Leader", "Rifleman", "Grenadier", "Auto Rifleman", "Marksman", "AT Rifleman", "Assistant AR"], 2] call Zen_AddLoadoutDialog;

_o_ret_attackHeli = ["mkBase_4", "b_heli_light_01_armed_f", 50, 180] call Zen_SpawnHelicopter;
0 = [_o_ret_inHeli1, ["mkInsertion_1", "mkBase_1"], _g_X1, "normal", 25] spawn Zen_OrderInsertion;
0 = [_o_ret_inHeli2, ["mkInsertion_2", "mkBase_2"], _g_X2, "normal", 25] spawn Zen_OrderInsertion;
0 = [_o_ret_inHeli3, ["mkInsertion_3", "mkBase_3"], _g_X3, "normal", 25] spawn Zen_OrderInsertion;

0 = [_o_ret_attackHeli, "mkCampCenter", 400] spawn Zen_OrderAircraftPatrol;
0 = [_o_ret_attackHeli] spawn Zen_TrackVehicles;

// very compact code here, to make up for the mess above
_a_I_allPatrols = [];
{
    _a_g_patrol = [];
    for "_i" from 0 to 2 do {
        _g_ret_patrol = [([_x] call Zen_FindGroundPosition), resistance, AI_SKILL, [3,5]] call Zen_SpawnInfantry;
        0 = [_a_g_patrol, _g_ret_patrol] call Zen_ArrayAppend;
    };
    0 = [_a_I_allPatrols, _a_g_patrol] call Zen_ArrayAppendNested;
    0 = [_a_g_patrol, _x] spawn Zen_OrderInfantryPatrol;
    0 = [_a_g_patrol, ["Team Leader", "rifleman", "grenadier", "Auto Rifleman", "Assistant AR", "Medic"]] call Zen_GiveLoadoutIndfor;
} forEach ["mkCampCenter", "mkPatrolEast", "mkPatrolWest"];

_o_ret_indVeh = ["mkIndforVeh_2", "I_MRAP_03_hmg_F", 45] call Zen_SpawnGroundVehicle;

// once the tasks and triggers are set up, the mission will complete for you
_s_ret_secureAll = [[_g_X1, _g_X2, _g_X3], "Take control of the main compound and all surrounding farmland.", "Secure the Area"] call Zen_InvokeTask;
_s_ret_secureArea1 = [_g_X1, "Your squad is tasked with sweeping the east side of the compound for enemy patrols.", "Clear East Side", "mkPatrolEast", true] call Zen_InvokeTask;
_s_ret_secureArea2 = [_g_X2, "Your squad is tasked with sweeping the west side of the compound for enemy patrols.", "Clear West Side", "mkPatrolWest", true] call Zen_InvokeTask;
_s_ret_secureArea3 = [_g_X3, "Your squad is tasked with directly attacking and securing the compound itself.", "Clear Compound", "mkCamp", true] call Zen_InvokeTask;

0 = [independent, _s_ret_secureArea1, "succeeded", "mkPatrolEast"] spawn Zen_TriggerAreaClear;
0 = [independent, _s_ret_secureArea2, "succeeded", "mkPatrolWest"] spawn Zen_TriggerAreaClear;
0 = [independent, _s_ret_secureArea3, "succeeded", "mkCampCenter"] spawn Zen_TriggerAreaClear;

// a little objective, just because we can
0 = [(["mkCampCenter", 2, random 360] call Zen_ExtendPosition), [_g_X1, _g_X2, _g_X3], resistance, ["officer", "custom", "box", "mortar"], "eliminate", "I_MRAP_03_F"] call Zen_CreateObjective;

waitUntil {
    sleep 2;
    (([_o_ret_inHeli2, "mkInsertion_2"] call Zen_Find2dDistance) < 500)
};

// fire support is very easy, and deadly
_s_ret_fireSupport = ["sh_155mm_amos", [3, 5], 3, 2, [7,9], 150, 10] call Zen_CreateFireSupport;
{
    0 = [_x, _s_ret_fireSupport] spawn Zen_InvokeFireSupport;
} forEach ["mkCampCenter", "mkPatrolEast", "mkPatrolWest"];

// here we have a typical insertion, followed by a patrol order
_o_ret_indAttackVeh = ["mkIndforVeh_1", "I_Truck_02_covered_F"] call Zen_SpawnGroundVehicle;
_g_ret_patrol = ["mkIndforVeh_2", resistance, AI_SKILL, [3,4]] call Zen_SpawnInfantry;
0 = [_g_ret_patrol, ["Team Leader", "rifleman", "grenadier", "autoRifleman", "Assistant AR", "Medic"]] call Zen_GiveLoadoutIndfor;
0 = [_g_ret_patrol, _o_ret_indAttackVeh, "cargo"] call Zen_MoveInVehicle;
0 = [_o_ret_indAttackVeh, "mkIndforReinforce", _g_ret_patrol, "full"] spawn Zen_OrderInsertion;

_a_I_allPatrols set [(count _a_I_allPatrols), _g_ret_patrol];
// 0 = [_a_I_allPatrols, "none"] call Zen_TrackGroups; // debug

// to get the patrol function running at the right time, we need another thread
// when in doubt, the show must go on (the init must keep generating the mission)
0 = _g_ret_patrol spawn {
    waitUntil {
        sleep 2;
        ([_this] call Zen_AreNotInVehicle)
    };
    0 = [_this, "mkIndforReinforce"] spawn Zen_OrderInfantryPatrol;
};

// insertion is done
waitUntil {
    sleep 2;
    ([[_g_X1, _g_X2, _g_X3]] call Zen_AreNotInVehicle)
};

// now we force the AI groups to clear their assigned areas
{
    _group = _x select 0;
    _marker = _x select 1;

    if !(isPlayer leader _group) then {

        _group move (getMarkerPos _marker);
        _group setSpeedMode "full";
        _group setCombatMode "red";
        _group setBehaviour "Aware";

        0 = _x spawn {
            waitUntil {
                sleep 10;
                (_this call Zen_AreInArea)
            };
            0 = _this spawn Zen_OrderInfantryPatrol;
        };
    };
} forEach [[_g_X1, "mkPatrolEast"], [_g_X2, "mkPatrolWest"], [_g_X3, "mkCampCenter"]];

// no more 5 shot kills
0 = [allUnits, true] call Zen_MultiplyDamage;

// now init just waits, all of the code above only took about 2 minutes, including waiting of course
waitUntil {
    sleep 10;
    ([[_s_ret_secureArea1, _s_ret_secureArea2, _s_ret_secureArea3]] call Zen_AreTasksComplete)
};

// a standard ending, no task left behind (make sure all tasks are shown as finished in some way)
0 = [_s_ret_secureAll, "succeeded"] call Zen_UpdateTask;

sleep 15;

"end1" call bis_fnc_endMission;

Zen_MP_Closure_Packet = ["bis_fnc_endMission", "end1"];
publicVariable "Zen_MP_Closure_Packet";
