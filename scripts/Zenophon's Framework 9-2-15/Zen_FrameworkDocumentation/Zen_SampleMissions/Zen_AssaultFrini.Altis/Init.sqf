#include "Zen_FrameworkFunctions\Zen_InitHeader.sqf"

// Assault Frini by Zenophon
// Version = Beta 7/7/14
// Tested with ArmA 3 1.22

#define BLUFOR_LOADOUTS ["Rifleman", "Grenadier", "Autorifleman", "Marksman", "Team Leader", "Assistant AR", "Medic", "AT Rifleman"]
#define OPFOR_LOADOUTS ["Rifleman", "Rifleman", "Grenadier", "Autorifleman", "Marksman", "Team Leader", "AT Specialist", "AT Rifleman", "Assistant AT"]
#define VIEW_DISTANCE 3000

// An improvement on the typical text, we use this later to print out the random start time to players
f_PrintWelcome = {
    titleText [str (round _this) + " Hours\n2km South of Frini", "BLACK FADED", 0.25];
};

titleText ["Standby", "BLACK FADED", 0.25];
enableSaving [false, false];
"mkFrini" setMarkerAlpha 0;
player createDiaryRecord ["Diary", ["Mission", "HQ has received reports that the Opfor have an ammunition dump in the valleys North of Frini.  We must secure the town before teams can be send to locate it.  You are part of a mechanized assault team tasked with attacking and securing Frini.  Move from the staging area near Athira within range of Frini using the IFV.  Opfor strength is estimated at no more than a platoon-sized element, but be prepared for AT weapons and MRAP's."]];

f_HandleRespawn = {
    if (time < 5) exitWith {};

    0 = _this spawn {
        private ["_unit", "_body"];

        _unit = _this select 0;
        _body = _this select 1;

        if (player == _unit) then {
            titleText ["Still Alive", "BLACK FADED", 0.2];
        };

        // actions must be added again
        0 = [_unit] call Zen_AddGiveMagazine;
        0 = [_unit] call Zen_AddRepackMagazines;

        // easy to tell who is respawning
        if (typeOf player == "B_crew_F") then {
            0 = [player, "crewman"] call Zen_GiveLoadoutBlufor;
        } else {
            0 = [player, BLUFOR_LOADOUTS] call Zen_GiveLoadoutBlufor;
        };

        // bring the player back to group leader, and account to him being in a vehicle
        if (vehicle leader group player == leader group player) then {
            player setPosATL ([leader group player, 2 + random 3, random 360] call Zen_ExtendPosition);
        } else {
            0 = [player, vehicle leader group player, "all"] call Zen_MoveInVehicle;

            if (vehicle player == player) then {
                player setPosATL ([vehicle leader group player, 5 + random 5, random 360] call Zen_ExtendPosition);
            };
        };

        // avoids messy tracking issues
        if (isServer) then {
            [] call f_ResetTracking;
        } else {
            Zen_MP_Closure_Packet = ["f_ResetTracking", []];
            publicVariableServer "Zen_MP_Closure_Packet";
        };

        sleep 300;
        deleteVehicle _body;
    };
};

#include "JIPSync.sqf"
if (!isServer) exitWith {};

// there's a reason the tracking function return what they do
f_ResetTracking = {
    terminate (h_GroupTrack select 1);
    {
        deleteMarker _x;
    } forEach (h_GroupTrack select 0);

    h_GroupTrack = [west, "none"] call Zen_TrackGroups;
};

_startTime = (round (8 + random 8))*100 + random 60;

sleep 1;

// the time is determined by the server and sent to all clients
Zen_MP_Closure_Packet = ["f_PrintWelcome", _startTime];
publicVariable "Zen_MP_Closure_Packet";

if !(isDedicated) then {
    _startTime call f_PrintWelcome;
};

_grpX = group X;
_grpP = group P;

// script-driven respawn, why leave things up to the engine when you interfere?
{
    _x addMPEventHandler ["MPRespawn", f_HandleRespawn];
} forEach (units _grpX + units _grpP);

// setting up for JIP, a lot of this deals with weather
_overcastTime = 60*45;
_fogTime = 60*20;
Zen_JIP_Args_Server = [time, overcast, overcastForecast, time, _overcastTime, fog, fogForecast, time, _fogTime, VIEW_DISTANCE, [_grpX, _grpP], B_IFV];

// no surprise seeing all these functions, B_IFV is in the editor
0 = [["overcast", random 0.4, random 0.5, _overcastTime], ["fog", random 0.1, random 0.1, _fogTime], ["date", _startTime - (floor (_startTime / 100.))*100, floor (_startTime / 100.)]] spawn Zen_SetWeather;
0 = [VIEW_DISTANCE] call Zen_SetViewDistance;
0 = [B_IFV, BLUFOR_LOADOUTS] call Zen_AddLoadoutDialog;
0 = [_grpP, B_IFV, "all"] call Zen_MoveInVehicle;

// for polish
_grpX setGroupID ["Infantry"];
_grpP setGroupID ["Crew"];

0 = [_grpX, BLUFOR_LOADOUTS] call Zen_GiveLoadoutBlufor;
0 = [_grpP, "Crewman"] call Zen_GiveLoadoutBlufor;
0 = [[_grpX, _grpP]] call Zen_AddGiveMagazine;
0 = [[_grpX, _grpP]] call Zen_AddRepackMagazines;

// start the tracking cycle, this will be handled when someone respawns
h_GroupTrack = [[_grpX, _grpP]] call Zen_TrackGroups;
0 = [B_IFV] call Zen_TrackVehicles;

// SP compatible
if !(isMultiplayer) then {
    (units _grpP) join X;
    doStop P;
};

// tasks and enemies...
_insertTask = [[_grpX, _grpP], "Insert near Frini using the IFV.  You are free to choose any direction to attack from.", "Insert with IFV", 0, true] call Zen_InvokeTask;
sleep 5;
_secureFriniTask = [[_grpX, _grpP], "Clear the town of Frini of Opfor forces.  Beware that they may have AT weapons and armored vehicles.", "Secure Frini", "mkFrini"] call Zen_InvokeTask;

_opforTeams = [];
for "_i" from 1 to 3 do {
    _spawnPos = ["mkFrini", 0, 0, 1, [2,0]] call Zen_FindGroundPosition;
    _opforGroup = [_spawnPos, east, "infantry", [5, 6]] call Zen_SpawnInfantry;
    0 = [_opforTeams, _opforGroup] call Zen_ArrayAppend;
};

0 = [_opforTeams, OPFOR_LOADOUTS] call Zen_GiveLoadoutOpfor;
0 = [_opforTeams, "mkFrini"] spawn Zen_OrderInfantryPatrol;

// enemy vehicles, they don't patrol so the AI doesn't embarrass itself with bad driving
for "_i" from 1 to (round (1 + random 1)) do {
    _spawnPos = ["mkFrini", 0, 0, 1, [2,0]] call Zen_FindGroundPosition;
    _opforVeh = [_spawnPos, ["O_MRAP_02_HMG_F", "O_MRAP_02_GMG_F"], random 360] call Zen_SpawnGroundVehicle;
};

// here we have the definition of an insertion, players get in...players get out
waitUntil {
    sleep 5;
    ([_grpX] call Zen_AreInVehicle)
};

waitUntil {
    sleep 5;
    ([_grpX] call Zen_AreNotInVehicle)
};

// then they clear the town
0 = [_insertTask, "succeeded"] call Zen_UpdateTask;
0 = [_secureFriniTask] call Zen_SetTaskCurrent;

_h_clear = [east, west, _secureFriniTask, "succeeded", "mkFrini"] spawn Zen_TriggerAreaSecure;

waitUntil {
    sleep 5;
    (scriptDone _h_clear)
};

Zen_MP_Closure_Packet = ["BIS_Fnc_EndMission", "EndWin"];
publicVariable "Zen_MP_Closure_Packet";
0 = "EndWin" call BIS_Fnc_EndMission;
