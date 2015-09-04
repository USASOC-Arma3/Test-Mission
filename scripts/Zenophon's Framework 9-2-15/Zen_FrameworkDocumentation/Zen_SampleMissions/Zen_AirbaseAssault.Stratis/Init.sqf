#include "Zen_FrameworkFunctions\Zen_InitHeader.sqf"

// Airbase Assault by Zenophon
// Version = Final 12/21/13
// Tested with ArmA 3 1.08

#define AI_SKILL "infantry"
#define LOADOUTS ["Rifleman", "AT Rifleman", "Assistant AR", "Team Leader", "Grenadier", "Auto Rifleman", "Marksman", "Medic", "Squad Leader"]

// split up the briefing
{
    if (_x in (units group Y11)) then {
        _x createDiaryRecord ["Diary", ["Mission", "     You are part of an Opfor infantry squad tasked with a ground assault on Stratis Airbase.  The Blufor have set up a defensive position in the South of the airbase with two APC's.  You will be inserted by a PO-30 at the point marked on the map.  You must eliminate an AA threat on the hill east of the base so that our Orca can destroy the Blufor APC's.  Once the helicopter has destroyed the APC's, you will assault the airbase.  Beware of enemy patrols near the hangars between you and the Blufor defensive position.  The helicopter cannot directly support your attack because of more Blufor AA weapons near their APC's.  Once you clear the airbase, you will extract with our helicopter to Camp Rogain.  Other units will move in to flank the Blufor counter-attack.  Tasks and further information will be given once the mission starts, read them carefully.  Good luck."]];
    } else {
        _x createDiaryRecord ["Diary", ["Mission", "     You are the pilot of an Opfor PO-30 tasked with airborne insertion and CAS in an assault on Stratis Airbase.  The Blufor have set up a defensive position in the South of the airbase with two APC's.  You will insert the infantry squad you are carrying and wait for them to eliminate an AA threat on a hill to the east of the Airbase.  Move low and slow through the valleys to get to Agia Marina without being seen by the AA site.  You will engage and destroy both Blufor APC's once the site is neutralized.  You should attack with caution as the Blufor may have more AA weapons near their APC's.  These Blufor AA assets prevent you from fully supporting our ground assault, but you could spot for the infantry from the hill top.  Once the airbase is secure, you will extract the infantry to Camp Rogain.  Other units will move in to flank the Blufor counter-attack.  Tasks and further information will be given once the mission starts, read them carefully.  Good luck."]];
    };
} forEach ((units group Y11) + (units group Y21));

titleText ["Good Luck", "BLACK FADED", 0.25];
enableSaving [false, false];
{_x setMarkerAlpha 0;} forEach ["mkAirFieldSecure", "mkPatrol", "mkSentrySpawn"];
if (!isServer) exitWith {};

_g_Y1 = group Y11;
_g_Y2 = group Y21;

sleep 1;

// A standard co-op mission start, most of these functions are going to be used again and again
0 = [["date", random 60, 9 + random 7], ["overcast", random 0.4, random 0.5, 60*40], ["fog", random 0.4, random 0, 300]] spawn Zen_SetWeather;
0 = [4000] call Zen_SetViewDistance;

// Players will start the mission in the spawned vehicle seamlessly
_o_ret_O_heli = ["mkStart", "o_heli_light_02_f", 10, 270] call Zen_SpawnVehicle;
0 = [_o_ret_O_heli] call Zen_AddEject;
0 = [_o_ret_O_heli] call Zen_AddFastRope;

0 = [[_g_Y2,_g_Y1], _o_ret_O_heli, "All"] call Zen_MoveInVehicle;

0 = [[_g_Y1, _g_Y1]] call Zen_AddGiveMagazine;
0 = [[_g_Y1, _g_Y1]] call Zen_AddRepackMagazines;
0 = [[_g_Y1, _g_Y2], "infantry"] call Zen_SetAISkill;
0 = [[_g_Y1, _g_Y2], "name"] call Zen_TrackGroups;

0 = [_g_Y1, LOADOUTS] call Zen_GiveLoadoutOpfor;
0 = [_g_Y2, "HelicopterPilot"] call Zen_GiveLoadoutOpfor;

sleep 2;

// multiple tasks for each group
_s_ret_infilY1 = [_g_Y1, "Get out of the helicopter once it lands.", "Insert Near the Airbase", "mkInsert", true] call Zen_InvokeTask;
_s_ret_infilY2 = [_g_Y2, "Land at the position marked on the map and let the infantry get out.  Fly carefully through the valleys to avoid Blufor AA.", "Insert the Infantry", "mkInsert", true] call Zen_InvokeTask;

sleep 2;

_s_ret_AASentryY1 = [_g_Y1, "The Blufor have put a AA site on a hill east of airbase.  Eliminate it and secure the area to confirm the kill so that our helicopter can engage the Blufor APC's.  Climb the hill carefully and flank the site; you outnumber them.  Do not wander onto the west side of the hill or you will be fired on the Blufor APC's.", "Eliminate the AA Site", "mkSentry"] call Zen_InvokeTask;
_s_ret_AASentryY2 = [_g_Y2, "The Blufor have put a AA site on a hill east of airbase.  Once it is eliminated, you can engage the Blufor APC's.", "Wait for the Infantry"] call Zen_InvokeTask;

// standard spawning, always position-spawn-patrol
_p_ret_spawnSentry = ["mkSentrySpawn"] call Zen_FindGroundPosition;
_g_ret_B_sentry = [_p_ret_spawnSentry, west, AI_SKILL, [2,2]] call Zen_SpawnInfantry;
_g_ret_B_guards = ["mkBluforAPC", west, AI_SKILL, [3,4]] call Zen_SpawnInfantry;

_g_ret_B_patrol = ["mkPatrol", west, AI_SKILL, [5, 6]] call Zen_SpawnInfantry;
0 = [_g_ret_B_patrol, "mkPatrol"] spawn Zen_OrderInfantryPatrol;

_p_ret_AA = [(getMarkerPos "mkBluforAPC"), [5, 100]] call Zen_FindGroundPosition;
_g_ret_B_AA = [_p_ret_AA, west, AI_SKILL, [3,3]] call Zen_SpawnInfantry;
0 = [[_g_ret_B_guards, _g_ret_B_AA], (getMarkerPos "mkBluforAPC"), [10, 200], [-10, 60]] spawn Zen_OrderInfantryPatrol;

// for those who like micromanagement, it's very possible
// don't use the 'false' argument in your code though, unless you know exactly what it does
0 = [((units _g_ret_B_sentry) select 0), "AssistantAA", false] call Zen_GiveLoadoutBlufor;
0 = [((units _g_ret_B_sentry) select 1), "AASpecialist", false] call Zen_GiveLoadoutBlufor;
0 = [_g_ret_B_patrol, LOADOUTS, false] call Zen_GiveLoadoutBlufor;
0 = [_g_ret_B_guards, LOADOUTS, false] call Zen_GiveLoadoutBlufor;
0 = [((units _g_ret_B_AA) select 0), "AssistantAA", false] call Zen_GiveLoadoutBlufor;
0 = [((units _g_ret_B_AA) select 1), "AASpecialist", false] call Zen_GiveLoadoutBlufor;
0 = [((units _g_ret_B_AA) select 2), "ATRifleman", false] call Zen_GiveLoadoutBlufor;

{
    _x setCombatMode "RED";
} forEach [_g_ret_B_sentry, _g_ret_B_patrol, _g_ret_B_guards, _g_ret_B_AA, _g_Y1];

// vehicles are now spawned; we could have used the editor, but now we can randomize what spawns
_o_ret_B_apc1 = ["mkAPC1", ["b_apc_wheeled_01_cannon_f", "b_apc_tracked_01_rcws_f"], 55] call Zen_SpawnGroundVehicle;
_o_ret_B_apc2 = ["mkAPC2", ["b_apc_wheeled_01_cannon_f", "b_apc_tracked_01_rcws_f"], 50] call Zen_SpawnGroundVehicle;

_o_ret_B_apc1 setFuel 0;
_o_ret_B_apc2 setFuel 0;

sleep 2;

// more tasks, the code between tasks took less than a second
_s_ret_taskAPC = [_g_Y2, "The Blufor have two APC's guarding the airbase.  Eliminate them so that our infantry can attack.  Be careful and use pop-up attacks to minimize your exposure to Blufor AA.", "Eliminate Blufor APC's", "mkBluforAPC"] call Zen_InvokeTask;

_s_ret_taskAttackY1 = [_g_Y1, "Attack and secure the Blufor position in the Southwest of the airbase.  Find and eliminate any patrols between you and the target.  Do not attempt to assault the main defenses until the Blufor APC's are destroyed.", "Assault the Airbase", "mkBluforAPC"] call Zen_InvokeTask;

// now the triggers, very easy to use, you don't have to waste time coding loops or setting up editor triggers
0 = [_g_ret_B_sentry, [_g_Y1, _g_Y2], [_s_ret_AASentryY1, _s_ret_AASentryY2], "succeeded", _g_ret_B_sentry, [50, 50], 0, "ellipse"] spawn Zen_TriggerAreaSecure;
0 = [[_o_ret_B_apc1, _o_ret_B_apc2], _s_ret_taskAPC, "succeeded"] spawn Zen_TriggerAreDead;
0 = [west, [_g_Y1, _g_Y2], _s_ret_taskAttackY1, "succeeded", "mkAirFieldSecure"] spawn Zen_TriggerAreaSecure;

// how to do an insertion with a player pilot
waitUntil {
    sleep 2;
    (isTouchingGround _o_ret_O_heli || ([_g_Y1] call Zen_AreNotInVehicle))
};

// the mission is technically playable in SP
if !(isPlayer Y11) then {
    _g_Y1 move getMarkerPos "mkSentry";
    {
        unassignVehicle _x;
        _x disableCollisionWith _o_ret_O_heli;
    } forEach (units _g_Y1);
};

// and the cycle of waiting begins, you are in 100% control of the milestones in your mission
waitUntil {
    sleep 2;
    ([_g_Y1] call Zen_AreNotInVehicle)
};

// tasks can seem like fluff sometimes, but they make your mission look polished
0 = [_s_ret_infilY1, "succeeded"] call Zen_UpdateTask;
0 = [_s_ret_infilY2, "succeeded"] call Zen_UpdateTask;

sleep 5;

0 = [_s_ret_AASentryY1] call Zen_SetTaskCurrent;
0 = [_s_ret_AASentryY2] call Zen_SetTaskCurrent;

sleep 10;

if !(isPlayer Y11) then {
    _g_Y1 move getMarkerPos "mkSentry";
};

// this mission really manages things closely
waitUntil {
    sleep 2;
    ([_s_ret_AASentryY1] call Zen_AreTasksComplete)
};

if !(isPlayer Y11) then {
    _g_Y1 move getMarkerPos "mkBluforAPC";
};

sleep 5;

0 = [_s_ret_taskAPC] call Zen_SetTaskCurrent;
0 = [_s_ret_taskAttackY1] call Zen_SetTaskCurrent;

waitUntil {
    sleep 2;
    (([_s_ret_taskAPC] call Zen_AreTasksComplete) || ([_s_ret_taskAttackY1] call Zen_AreTasksComplete))
};

// this doesn't really warrant a special milestone, but its up to you in your missions
if !([_s_ret_taskAttackY1] call Zen_AreTasksComplete) then {
    0 = [_s_ret_taskAttackY1] call Zen_SetTaskCurrent;
};

waitUntil {
    sleep 2;
    ([_s_ret_taskAttackY1] call Zen_AreTasksComplete)
};

_s_ret_taskExtractY1 = [_g_Y1, "Move to the extraction point and get in the helicopter when it arrives.", "Move to Extraction", "mkExtract", true] call Zen_InvokeTask;
_s_ret_taskExtractY2 = [_g_Y2, "Fly to the extraction point and let the infantry get in, then take them back to Camp Rogain.", "Extract the Infantry", "mkExtract", true] call Zen_InvokeTask;

sleep 5;

// multiple endings based upon if the helicopter survived
if (!(alive _o_ret_O_heli) || !(canMove _o_ret_O_heli)) then {
    sleep 5;
    0 = [_s_ret_taskExtractY1, "failed"] call Zen_UpdateTask;
    sleep 2;
    0 = [_s_ret_taskExtractY2, "failed"] call Zen_UpdateTask;
    sleep 5;
    "End2" call BIS_fnc_endMission;
    Zen_MP_Closure_Packet = ["BIS_fnc_endMission", "End2"];
    publicVariable "Zen_MP_Closure_Packet";
};

// this is a good way to do a helicopter extraction with a player pilot
waitUntil {
    sleep 2;
    ((isTouchingGround _o_ret_O_heli) && (([_o_ret_O_heli, "mkExtract"] call Zen_Find2dDistance) < 200));
};

{
    _x assignAsCargo _o_ret_O_heli;
} forEach (units group Y11);

(units group Y11) orderGetIn true;

waitUntil {
    sleep 2;
    ([_g_Y1] call Zen_AreInVehicle)
};

0 = [_s_ret_taskExtractY1, "succeeded"] call Zen_UpdateTask;

// how to detect the player flying away
waitUntil {
    sleep 2;
    (([_o_ret_O_heli, "mkExtract"] call Zen_Find2dDistance) > 500)
};

// standard ending, succeeding the last task
0 = [_s_ret_taskExtractY2, "succeeded"] call Zen_UpdateTask;

sleep 3;

// see the description.ext
"End1" call BIS_fnc_endMission;

Zen_MP_Closure_Packet = ["BIS_fnc_endMission", "End1"];
publicVariable "Zen_MP_Closure_Packet";
