//

// Some of this is covered in the JIP demonstration, what isn't is commented on here
if (_Zen_Is_JIP) then {
    titleText ["Good Luck", "BLACK FADED", 0.25];

    Zen_Task_Array_Global = 1;
    Zen_MP_Closure_Packet = ["Zen_SyncJIPServer", player];
    publicVariableServer "Zen_MP_Closure_Packet";

    waitUntil {
        (!(isNil "Zen_JIP_Args_Server") && (typeName Zen_Task_Array_Global == "ARRAY"))
    };

    _serverArgs = Zen_JIP_Args_Server;

    0 = [["overcast", (_serverArgs select 1), (_serverArgs select 2), (_serverArgs select 3) + (_serverArgs select 4) - (_serverArgs select 0)], ["fog", (_serverArgs select 5), (_serverArgs select 6), (_serverArgs select 7) + (_serverArgs select 8) - (_serverArgs select 0)], ["packet", false]] spawn Zen_SetWeather;

    0 = [(_serverArgs select 9), -1, -1, false] call Zen_SetViewDistance;
    0 = [(_serverArgs select 11), BLUFOR_LOADOUTS, -1, false] call Zen_AddLoadoutDialog;

    // we must give the player's machine the action for all other client's objects
    0 = [([(_serverArgs select 10)] call Zen_ConvertToObjectArray) - [player], false] call Zen_AddGiveMagazine;
    0 = [([(_serverArgs select 10)] call Zen_ConvertToObjectArray) - [player], false] call Zen_AddRepackMagazines;

    // we must give the action to the player's new object on all machines
    0 = [player] call Zen_AddGiveMagazine;
    0 = [player] call Zen_AddLoadoutDialog;

    // Since this is a fixed value, we can use it to determine which group the new player is in
    if (typeOf player == "B_crew_F") then {
        0 = [player, "crewman", false] call Zen_GiveLoadoutBlufor;
    } else {
        0 = [player, BLUFOR_LOADOUTS, false] call Zen_GiveLoadoutBlufor;
    };

    // This part is new, because there are no AI, we need to put the new player with his teammates
    // We also need to account for vehicles
    if (vehicle leader group player == leader group player) then {
        player setPosATL ([leader group player, 2 + random 3, random 360] call Zen_ExtendPosition);
    } else {
        0 = [player, vehicle leader group player, "all"] call Zen_MoveInVehicle;

        if (vehicle player == player) then {
            player setPosATL ([vehicle leader group player, 5 + random 5, random 360] call Zen_ExtendPosition);
        };
    };

    // Just use Zen_ReassignTask, as in the JIP demo
    {
        0 = [_x, player] call Zen_ReassignTask;
    } forEach ([(leader group player)] call Zen_GetUnitTasks);

    // new player == new markers
    Zen_MP_Closure_Packet = ["f_ResetTracking", []];
    publicVariableServer "Zen_MP_Closure_Packet";

    // no Zen_CreateObjective is used
    // sleep 2;
    // {
        // _data = [_x] call Zen_GetTaskDataGlobal;
        // _dest = _data select 3;
        // _marker = [allMapMarkers, _dest] call Zen_FindMinDistance;
        // if ((([_marker, _dest] call Zen_Find2dDistance) < 2) && {(markerShape _marker == "ICON")}) then {
            // _marker setMarkerAlphaLocal 1;
        // };
    // } forEach ([player] call Zen_GetUnitTasks);
};

if (isServer) then {
    Zen_SyncJIPServer = {
        Zen_JIP_Args_Server set [0, time];
        Zen_JIP_Args_Server set [1, overcast];
        Zen_JIP_Args_Server set [2, overcastForecast];
        Zen_JIP_Args_Server set [5, fog];
        Zen_JIP_Args_Server set [6, fogForecast];

        // Any command that aught to be executed on the server for an object should be executed here for a JIP client
        _this addMPEventHandler ["MPRespawn", f_HandleRespawn];

        (owner _this) publicVariableClient "Zen_Task_Array_Global";
        (owner _this) publicVariableClient "Zen_Fire_Support_Array_Global";
        (owner _this) publicVariableClient "Zen_Loadout_Array_Global";
        (owner _this) publicVariableClient "Zen_Damage_Increase";
        (owner _this) publicVariableClient "Zen_JIP_Args_Server";
    };
};
