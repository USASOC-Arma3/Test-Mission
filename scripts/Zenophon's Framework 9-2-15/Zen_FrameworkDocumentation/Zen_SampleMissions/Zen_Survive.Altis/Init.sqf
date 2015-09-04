#include "Zen_FrameworkFunctions\Zen_InitHeader.sqf"

// Survive by Zenophon
// Version = Beta 6/20/14
// Tested with ArmA 3 1.22

#define UNIFORMS ["U_C_Poloshirt_blue", "U_C_Poloshirt_burgundy", "U_C_Poloshirt_stripped", "U_C_Poloshirt_tricolour", "U_C_Poloshirt_salmon", "U_C_Poloshirt_redwhite", "U_C_Commoner1_1", "U_C_Commoner1_2", "U_C_Commoner1_3", "U_C_Poor_1", "U_C_Poor_2", "U_C_Commoner_shorts", "U_C_ShirtSurfer_shorts", "U_C_TeeSurfer_shorts_1", "U_C_TeeSurfer_shorts_2"]
#define VESTS ["V_TacVest_khk", "V_TacVest_brn", "V_TacVest_oli", "V_TacVest_blk", "V_TacVest_camo", "V_TacVest_blk_POLICE", "V_TacVestCamo_khk"]
#define HATS ["H_MilCap_ocamo", "H_MilCap_mcamo", "H_MilCap_rucamo", "H_MilCap_gry", "H_MilCap_dgtl", "H_MilCap_blue", "H_Cap_red", "H_Cap_blu", "H_Cap_oli", "H_Cap_tan", "H_Cap_blk", "H_Cap_blk_CMMG", "H_Cap_brn_SPECOPS", "H_Cap_tan_specops_US", "H_Cap_khaki_specops_UK", "H_Cap_grn", "H_Cap_grn_BI", "H_Cap_blk_Raven", "H_Cap_blk_ION", "H_Cap_oli_hs", "H_Hat_blue", "H_Hat_brown", "H_Hat_camo", "H_Hat_grey", "H_Hat_checker", "H_Hat_tan", "H_Watchcap_blk", "H_Watchcap_khk", "H_Watchcap_camo", "H_Watchcap_sgg", "H_StrawHat", "H_StrawHat_dark"]
#define ITEM ["ItemWatch", "ItemCompass", "ItemRadio", "ItemMap"]

player createDiaryRecord ["Diary", ["Mission", "Work in progress.  Fight as a guerrilla against the Opfor invasion of Altis.  Complete various opportunity objectives across the Altis countryside.<br/><br/>Currently features:<br/>    Help the Blufor assault Zaros<br/><br/>Coop version, 2 players, no respawn."]];

titleText ["Altis, Zaros\nBlufor units sighted to the east\nOpfor patrols in the town", "BLACK FADED", 0.4];
enableSaving [false, false];
if (!isServer) exitWith {};

KillOpfor = {
    {
        if (side _x == east) then {
            _x setDamage 1;
        };
    } forEach allUnits;
};

{_x setMarkerAlpha 0;} forEach ["mkOpforSpawn", "mkBluforSpawn", "mkOpforVeh", "mkBluforBase",  "mkGraveyard"];
sleep 1;

0 = [[
    ["uniform", UNIFORMS], 
    ["vest", VESTS], 
    ["headgear", HATS], 
    ["assignedItems", ITEM], 
    ["weapons", [["hgun_ACPC2_F", "SMG_02_F"]]], 
    ["magazines", [[["9Rnd_45ACP_Mag", (5 + floor random 3)], ["30Rnd_9x21_Mag", (4 + floor random 4)]]]]
],"Srv_Guer"] call Zen_CreateLoadout;

0 = [[
    ["uniform",UNIFORMS],
    ["vest",VESTS],
    ["backpack","B_AssaultPack_mcamo"],
    ["headgear",HATS],
    ["goggles",""],
    ["assignedItems",["ItemMap","ItemCompass","ItemWatch","ItemRadio","ItemGPS","NVGoggles_OPFOR","Rangefinder"]],
    ["weapons",["arifle_Katiba_F", "hgun_ACPC2_F", "Rangefinder"]],
    ["magazines",[["9Rnd_45ACP_Mag",1],["HandGrenade",4],["30Rnd_65x39_caseless_green",15],["SmokeShellOrange",3],["30Rnd_65x39_caseless_green",1],["9Rnd_45ACP_Mag",1]]],
    ["items",["FirstAidKit","FirstAidKit","acc_flashlight"]],["primaryAttachments",["optic_ACO_grn"]]
], "Srv_Merc"] call Zen_CreateLoadout;

_spawnPos = ["mkInsertionHeli", [400, 550], 0, 0, 0, [45, 135]] call Zen_FindGroundPosition;
_uh80 = [_spawnPos, "B_Heli_Transport_01_F", 20] call Zen_SpawnHelicopter;

_grpX = group X;
0 = [_grpX, "Srv_Guer"] call Zen_GiveLoadoutCustom;
0 = [_grpX] call Zen_AddRepackMagazines;
0 = [["overcast", random 1, random 1, 60*60], ["fog", random 0.3], ["date", random 60, 8 + random 7]] spawn Zen_SetWeather;

_patrolArray = [];
_Blufor_patrolArray = [];

_spawnPos = ["mkBluforSpawn"] call Zen_FindGroundPosition;
for "_i" from 0 to 3 do {
    _patrolGroup = [_spawnPos, west, "infantry", [3,4]] call Zen_SpawnInfantry;
    0 = [_patrolGroup] call Zen_GiveLoadoutBlufor;

    0 = [_Blufor_patrolArray, _patrolGroup] call Zen_ArrayAppend;
    0 = [_patrolArray, _patrolGroup] call Zen_ArrayAppend;
};

_Blufor_Heli_Groups = [_Blufor_patrolArray, 0, 1] call Zen_ArrayGetIndexedSlice;
_Blufor_Car_Groups = [_Blufor_patrolArray, 2] call Zen_ArrayGetIndexedSlice;

_uh80 allowDamage false;
0 = [_Blufor_Heli_Groups, _uh80] call Zen_MoveInVehicle;
0 = [_uh80, ["mkInsertionHeli", "mkUH80"], _Blufor_Heli_Groups, "limited"] spawn Zen_OrderInsertion;

_spawnPos = ["mkInsertionCar", [175, 250], 0, 1, [2,0], [90, 180]] call Zen_FindGroundPosition;
_HEMTT = [_spawnPos, "B_Truck_01_covered_F", 315] call Zen_SpawnGroundVehicle;
0 = [_Blufor_Car_Groups, _HEMTT] call Zen_MoveInVehicle;
0 = [_HEMTT, "mkInsertionCar", _Blufor_Car_Groups, "limited"] spawn Zen_OrderInsertion;
_HEMTT lock 3;

for "_i" from 0 to 1 do {
    _spawnPos = ["mkOpforSpawn", 0, ["mkGraveyard"]] call Zen_FindGroundPosition;
    _patrolGroup = [_spawnPos, east, "infantry", 7] call Zen_SpawnInfantry;
    0 = [_patrolGroup] call Zen_GiveLoadoutOpfor;
    0 = [_patrolArray, _patrolGroup] call Zen_ArrayAppend;
};

_h_patrol = [_patrolArray, "mkZaros", [], 0, "normal"] spawn Zen_OrderInfantryPatrol;

sleep 2;

{
    _x setCombatMode "aware";
} forEach _patrolArray;

_secureZaros = [_grpX, "Clear the town of Opfor forces, with the help of a blufor squad.", "Secure Zaros", "mkZaros", true] call Zen_InvokeTask;
sleep 2;
_protectBlufor = [_grpX, "Assist the Blufor soldiers, do not allow them to be killed.", "Help the Blufor", 0, false, _secureZaros] call Zen_InvokeTask;

// _bluforPatrols = [_patrolArray, {!((side leader _this) == (side X))}] call Zen_ArrayFilterCondition;
_h_protect = [_Blufor_patrolArray, _protectBlufor, "failed"] spawn Zen_TriggerAreDead;

waitUntil {
    sleep 2;
    (!([east, "mkZaros"] call Zen_AreNotInArea) && {!([west, "mkZaros"] call Zen_AreNotInArea)})
};

_extraUnit = driver _HEMTT;
[_extraUnit] join (_Blufor_Car_Groups select 1);
doGetOut _extraUnit;
unassignVehicle _extraUnit;
0 = [_extraUnit, "rifleman"] call Zen_GiveLoadoutBlufor;
sleep 2;
_HEMTT lock 2;
_extraUnit enableAI "MOVE";
_extraUnit commandFollow (leader group _extraUnit);

// 0 = [allUnits, true] call Zen_MultiplyDamage;

_h_clearE = [east, west, [_secureZaros, _protectBlufor], "succeeded", "mkZaros"] spawn Zen_TriggerAreaSecure;
_h_clearW = [west, east, _secureZaros, "failed", "mkZaros"] spawn Zen_TriggerAreaSecure;

waitUntil {
    sleep 2;
    (scriptDone _h_clearE)
};

if ([_secureZaros, "succeeded"] call Zen_AreTasksComplete) then { // Blufor won
    terminate _h_clearW;
    terminate _h_protect;
    "mkZaros" setMarkerColor "colorBlufor";
} else { // Opfor won
    terminate _h_clearW;
    terminate _h_protect;
    "mkZaros" setMarkerColor "colorOpfor";

    0 = "EndLoss" call BIS_fnc_EndMission;
    MP_Closure_Packet = ["BIS_fnc_EndMission", "EndLoss"];
    publicVariable "MP_Closure_Packet";
};

_surviveMortars = [_grpX, "Take cover in a sturdy building to survive the Opfor mortar retaliation.", "Survive Mortar Fire", 0, true] call Zen_InvokeTask;
[west, "base"] sideChat "All units, HQ, take cover!  Incoming Opfor mortar fire on the town.";

sleep 15;

_opforMortars = ["Sh_82mm_AMOS", [4, 6], [8, 12], 1, [4, 7], ([150, 200] call Zen_FindInRange), [15, 20]] call Zen_CreateFireSupport;
_h_mortars = ["mkZaros", _opforMortars] spawn Zen_InvokeFireSupport;

_HEMTT setDamage 1;

waitUntil {
    sleep 2;
    (scriptDone _h_mortars)
};

sleep 5;
0 = [_surviveMortars, "succeeded"] call Zen_UpdateTask;

sleep 5;
[west, "base"] sideChat "All units, HQ, Is anyone still alive down there?  The Opfor are sending armored vehicles to counter-attack from the North.";
sleep 8;
[west, "base"] sideChat "All units, HQ, Extraction chopper and air support are inbound, everyone hold tight.";

_opforVehArray = [];
_opforReinfArray = [];

for "_i" from 0 to 0 do {
    _spawnPos = ["mkOpforVeh"] call Zen_FindGroundPosition;
    _opforVeh = [_spawnPos, "O_APC_Tracked_02_cannon_F"] call Zen_SpawnGroundVehicle;
    0 = [_opforVehArray, _opforVeh] call Zen_ArrayAppend;
};

for "_i" from 0 to 1 do {
    _spawnPos = ["mkOpforVeh"] call Zen_FindGroundPosition;
    _reinfGroup = [_spawnPos, east, "infantry", 8] call Zen_SpawnInfantry;
    0 = [_reinfGroup, east] call Zen_GiveLoadout;
    0 = [_opforReinfArray, _reinfGroup] call Zen_ArrayAppend;
};

0 = [_opforReinfArray, "mkZaros", [], 0, "full"] spawn Zen_OrderInfantryPatrol;
0 = [_opforVehArray, "mkZaros"] spawn Zen_OrderVehiclePatrol;

sleep 60;

_ah99 = ["mkAH99", "B_Heli_Attack_01_F", 0] call Zen_SpawnHelicopter;
// _uh80 = ["mkUH80", "B_Heli_Transport_01_F", 40] call Zen_SpawnHelicopter;

0 = [_ah99, "mkZaros"] spawn Zen_OrderAircraftPatrol;
// 0 = [allUnits, true] call Zen_MultiplyDamage;

terminate _h_patrol;
{
    _x move (getMarkerPos "mkExtraction");
    _x setSpeedMode "full";
} forEach _Blufor_patrolArray;

_h_extract = [_uh80, ["mkExtraction", "mkUH80"], [_Blufor_patrolArray, _grpX], "limited", 25] spawn Zen_OrderExtraction;

[west, "base"] sideChat "All units, HQ, Extraction helicopter is on its way, LZ is near the football field at the east side of the town.  Get there now!";
_extract = [_grpX, "Get to the Blufor helicopter and escape with the surviving soldiers.", "Extract with Blufor", "mkExtraction", true] call Zen_InvokeTask;

_baseGroup = ["mkBluforBase", west, 1, 2] call Zen_SpawnInfantry;
0 = [_baseGroup, "mkBluforBase"] spawn Zen_OrderInfantryPatrol;

waitUntil {
    sleep 2;
    ([_grpX] call Zen_AreInVehicle);
};

sleep 5;

{
    if ((_x distance _uh80) > 25) then {
        _x setDamage 1;
    };
} forEach ([_Blufor_patrolArray] call Zen_ConvertToObjectArray);

sleep 5;

_uh80 setSpeedMode "full";

waitUntil {
    sleep 2;
    (scriptDone _h_extract)
};

0 = [_extract, "succeeded"] call Zen_UpdateTask;

sleep 10;

0 = "EndWin" call BIS_fnc_EndMission;

Zen_MP_Closure_Packet = ["BIS_fnc_EndMission", "EndWin"];
publicVariable "Zen_MP_Closure_Packet";
