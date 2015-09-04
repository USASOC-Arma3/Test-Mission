// This file is part of Zenophon's ArmA 3 Co-op Mission Framework
// This file is released under Creative Commons Attribution-NonCommercial-NoDerivatives 4.0 International (CC BY-NC-ND 4.0)
// See Legal.txt

#include "Zen_FrameworkFunctions\Zen_InitHeader.sqf"

// Demonstration of JIP by Zenophon
// Version = Final 6/17/15
// Tested with ArmA 3 1.24

/**  Multiplayer compatibility is a major featured offered by the framework.  The most difficult part of this is dealing with JIP clients, who will ruin an otherwise perfect mission.  It would require an unreasonable and inefficient amount of special coding to make every relevant framework function work with JIP automatically.  Therefore, a special function must be created to synch JIP players in every necessary way.  After this is done, they are just like any other client.  That function is written below for you to use in your missions.  However, some customization of its contents will be necessary, as every mission is different. */

titleText ["Good Luck", "BLACK FADED", 0.2];
enableSaving [false, false];

/**  First, we must be able to detect if a client is JIP.  This is handled for you in Zen_InitHeader.sqf, as it is too late for a check in the init to work after that code has run.  You can simply use the framework local variable _Zen_Is_JIP in the init and assume it will work.  If you need that variable in other threads, simply make it a global variable.  You should not need to do that though, all synch'ing is done below. */

/**  If you are not familiar with locality and remote execution, you can still make use of this code to make your missions JIP compatible.  It is not necessary that you understand why any of this works, only that you know what its effect is so that you can use it.  Some of the function calls will make use of special arguments that disable the remote execution of some functions; these are only intended to be used for JIP and internally.  Unless you are interested in how I have written the framework source code, don't worry about how those extra arguments work. */

/**  Some of the code below should remain unchanged; some things are always synch'd the same way.  I have decided how these should be done for you, as you cannot be expected to know how the framework handles client-server interactions internally.  In other things, you have a choice based upon how you wrote your mission for normal clients.  The comments below will explain what everything does and what you can change. */

/**  Do not expect to just copy this into your mission and have it work.  Part of the function below is just a template for you to modify for your mission.  This is, like everything else, a framework to help you create your mission.  This demonstration is a short mission, showing how the template has been customized to fit the example mission. */

if (_Zen_Is_JIP) then {

    // Some trickiness with global variables to get the data the client needs, do not change this
    // If you have not seen Zen_MP_Closure_Packet used before, just assume that this makes the server send over the correct data
    Zen_Task_Array_Global = 1;
    Zen_MP_Closure_Packet = ["Zen_SyncJIPServer", player];
    publicVariableServer "Zen_MP_Closure_Packet";

    // Wait until the client has the necessary data, do not change this
    waitUntil {
        (!(isNil "Zen_JIP_Args_Server") && (typeName Zen_Task_Array_Global == "ARRAY"))
    };

    // Zen_JIP_Args_Server contains the data necessary to synch the JIP client
    // You can decide exactly what is contained here later in the init
    // We can assign each element to a variable to improve readability
    _overcast = Zen_JIP_Args_Server select 0;
    _fog = Zen_JIP_Args_Server select 1;
    _viewDist = Zen_JIP_Args_Server select 2;
    _playerGroup = Zen_JIP_Args_Server select 3;
    _truck = Zen_JIP_Args_Server select 4;
    _loadouts = Zen_JIP_Args_Server select 5;
    _loadoutLimit = Zen_JIP_Args_Server select 6;
    _supportAction = Zen_JIP_Args_Server select 7;
    _fireSupportData = [_supportAction] call Zen_GetFireSupportActionData;

    /**  You have two choices for weather: immediate changes only or immediate and long-term changes.  This depends on how your weather is setup for other clients.  It only matters that they agree.  You can customize this to your liking with different arguments to Zen_SetWeather.  All the data used here is provided by a variable from the server.  Time is synch'd for you by the engine, so only weather effects need to be dealt with here. */

    /**  This demonstration only covers an immediate weather sync.  For an example of how to synch both immediate and long term weather changes, see the Zen_InfantryPatrol, Zen_RespawnPatrol, and Zen_AssaultFrini sample missions. */
    0 = [["overcast", _overcast], ["fog", _fog], ["packet", false]] spawn Zen_SetWeather;

    // You also want to ensure the JIP client has the same view distance as everyone else
    0 = [_viewDist, -1, -1, false] call Zen_SetViewDistance;

    /**  All of the framework's helpful actions are local to the clients, so you need to add them again to a JIP player.  Here all you need to do is match up the data that you setup in Zen_JIP_Args_Server with the right functions to match what the server did in the init.  This only applies to action that are on other objects, not on players.  Actions like repack magazines or fire support must be handled different in the two cases below. */
    // 0 = [(Zen_JIP_Args_Server select X), false] call Zen_AddEject;
    // 0 = [(Zen_JIP_Args_Server select X), false] call Zen_AddFastRope;

    /**  Here we must split the JIP code into two sections.  One for friendly AI existing, and one for when they do not.  It is up to the admin/players of the mission if they want to stop AI from filling playable slots, so a good mission is prepared for anything. */

    // We must check if the player's object is new and not an object previously controlled by the AI
    // First check if the mission has disabled the AI entirely
    // Otherwise, assume players and friendly AI have some tasks from the framework's task system
    // If that is not case, you need to find a reliable substitute for this check
    if (((missionConfigFile >> "disabledAI") isEqualTo 1) || ((count ([player] call Zen_GetUnitTasks)) == 0)) then {

        // Due to the nature of actions in MP, the framework's actions must be added this way
        0 = [([_playerGroup] call Zen_ConvertToObjectArray) - [player], false] call Zen_AddGiveMagazine;
        0 = [player] call Zen_AddGiveMagazine;

        0 = [([_playerGroup] call Zen_ConvertToObjectArray) - [player], false] call Zen_AddRepackMagazines;
        0 = [player] call Zen_AddRepackMagazines;

        // The new object would have the default loadout
        // You must change it if you have done so for the other players
        0 = [player, _loadouts, false] call Zen_GiveLoadoutBlufor;

        // This code handles placing the new player object in the correct spot
        // First we must get a reliable unit that the player would be with if he was previously an AI
        private ["_refUnit"];
        _refUnitArray = (units group player) - [player];
        if (count _refUnitArray == 0) then {
            _refUnit = (([side player] call Zen_ConvertToObjectArray) - [player]) select 0;
        } else {
            _refUnit = _refUnitArray select 0;
        };

        // If the JIP unit's team member is in a vehicle, put him in too
        // The code has fail-safe logic in case the vehicle is full
        if (vehicle _refUnit != _refUnit) then {
            player moveInAny (vehicle _refUnit);
            if (vehicle player == player) then {
                player setPosATL ([_refUnit, 2 + random 3, random 360] call Zen_ExtendPosition);
            };
        } else {
            player setPosATL ([_refUnit, 2 + random 3, random 360] call Zen_ExtendPosition);
        };

        // Now for a fire support action, if the mission has it
        // This looks similar to Zen_AddGiveMagazine and Zen_AddRepackMagazines
        // This client must add the action to all client objects
        // And all other clients must add the action to this client's object
        // It must also check that the fire support has not been used or deleted
        if (count _fireSupportData > 0) then {
            0 = ([_supportAction, ([_playerGroup] call Zen_ConvertToObjectArray) - [player]] + ([_fireSupportData, 2, 6] call Zen_ArrayGetIndexedSlice)) call Zen_AddFireSupportAction_AddAction_MP;
            0 = [_supportAction, player] call Zen_UpdateFireSupport;
        };

        // Finally, the new object gets all of the tasks of his teammate
        // If different teammates have different tasks,
        // You might need to change the teammate selection logic to get a specific unit
        // However, for small co-op missions, this is very easy with Zen_ReassignTask
        {
            0 = [_x, player] call Zen_ReassignTask;
        } forEach ([_refUnit] call Zen_GetUnitTasks);
    } else {
        // If you already had AI, this becomes a lot easier.
        0 = [_playerGroup, false] call Zen_AddGiveMagazine;
        0 = [_truck, _loadouts, _loadoutLimit, false] call Zen_AddLoadoutDialog;
        0 = [_playerGroup, false] call Zen_AddRepackMagazines;

        // Here we use a private function from the fire support system
        // As with the task system below, the object must already be in the global data
        if (count _fireSupportData > 0) then {
            0 = ([_supportAction, [_playerGroup] call Zen_ConvertToObjectArray] + _fireSupportData) call Zen_AddFireSupportAction_AddAction_MP;
        };

        // This synchs and updates all tasks, do not change this
        // We can't use Zen_ReassignTask as the object already exists
        // It is in the task system's internal data, which is being used directly here
        {
            0 = [(_x select 1), (_x select 4), (_x select 5), (_x select 3), false, (_x select 0), (_x select 6)] call Zen_InvokeTaskClient;
            0 = [(_x select 0)] call Zen_UpdateTask;
            sleep 0.1;
        } forEach Zen_Task_Array_Global;
    };

    // This synchs markers created by Zen_CreateObjective, do not change this
    // If you do not use Zen_CreateObjective in your mission, you can remove this block entirely
    sleep 1;
    {
        _data = [_x] call Zen_GetTaskDataGlobal;
        _dest = _data select 3;
        _marker = [allMapMarkers, _dest] call Zen_FindMinDistance;
        if ((([_marker, _dest] call Zen_Find2dDistance) < 5) && {(markerShape _marker == "ICON")}) then {
            _marker setMarkerAlphaLocal 1;
        };
    } forEach ([player] call Zen_GetUnitTasks);
};

// I recommend placing all of the template above into another file, then using #include to place it in the init.sqf
// This will clean up your init and make it look similar to a init that does not support JIP
// Once you customize the template for your mission, no more changes are required
// You could also do this for Zen_SyncJIPServer
// Examples of this are shown in the Zen_InfantryPatrol, Zen_RespawnPatrol, and Zen_AssaultFrini sample missions

// JIP clients should exit here too, they are done being synch'd and are the same as any other client now
if (!isServer) exitWith {};

// This function runs on the server to send over the correct data to the JIP player
// Don't change the publicVariable's here
Zen_SyncJIPServer = {
    Zen_JIP_Args_Server set [0, overcast];
    Zen_JIP_Args_Server set [1, fog];

    (owner _this) publicVariableClient "Zen_Task_Array_Global";
    (owner _this) publicVariableClient "Zen_Fire_Support_Array_Global";
    (owner _this) publicVariableClient "Zen_Fire_Support_Action_Array_Global";
    (owner _this) publicVariableClient "Zen_Loadout_Array_Global";
    (owner _this) publicVariableClient "Zen_Damage_Increase";
    (owner _this) publicVariableClient "Zen_JIP_Args_Server";

    // If you use tracking in your mission, and have disabled the AI,
    // you must reset the server's tracking thread to track the new client object
    // The choice of variable and tracking function is up to you
    // The variable must be global on the server, but it should not be sent to clients
    terminate (h_Tracking select 1);
    {
        deleteMarker _x;
    } forEach (h_Tracking select 0);

    h_Tracking = [(Zen_JIP_Args_Server select 3)] call Zen_TrackInfantry;
};

sleep 2;
_playerGroup = group X;

_fireSupport = ["r_80mm_he", 10, 1, 1, 1, 100, 0] call Zen_CreateFireSupport;
_supportAction = [_playerGroup, _fireSupport, "Artillery Strike", 2, "player"] call Zen_AddFireSupportAction;

/**  This is where you construct the data that every JIP client will use.  The composition of this array is entirely up to you.  You want to match what is synch'd with what the server does below.  The actions and view distance are done in the exact same way as below with the same arguments.  Weather is slightly more complex, because it could be random and could change.  Thus, spaces are reserved in the array for the weather and fog.  These values are then updated in the server's function above to the most current values when the JIP client joins.  Tasks are done for you, so no information about them is necessary. */

Zen_JIP_Args_Server = [overcast, fog, 3000, _playerGroup, Truck, ["Rifleman", "Recon", "Marksman"], 1, _supportAction];

0 = [_playerGroup] call Zen_AddGiveMagazine;
0 = [Truck, ["Rifleman", "Recon", "Marksman"], 1] call Zen_AddLoadoutDialog;
0 = [_playerGroup] call Zen_AddRepackMagazines;
h_Tracking = [_playerGroup] call Zen_TrackInfantry;

0 = [["overcast", random 1], ["fog", random 1], ["date"]] spawn Zen_SetWeather;
0 = [3000] call Zen_SetViewDistance;

_testTask = [_playerGroup, "This is a test.  It completes when you get in the truck.", "Get In the Truck", Truck, false] call Zen_InvokeTask;

/**  If a player joins here, while the waitUntil loop is running, they will get the task in an created state.  The code on the server is still running, so when the players get in the truck, it will succeed normally for both of them.  If the JIP client joined after the task completed, they would just see a completed task. */

waitUntil {
    sleep 2;
    ([_playerGroup] call Zen_AreInVehicle)
};

0 = [_testTask, "succeeded"] call Zen_UpdateTask;

/**  This is probably the most incomplete demonstration, as I cannot go over every possible combination of functions to synch a JIP client.  You are given a simple example and the full template to synch JIP players, but it is up to you to study this demonstration and apply the solution to your missions.  Remember that JIP and multiplayer considerations in general can be frustrating, but, once you are familiar with using this template, you can add JIP to any framework mission easily. */
