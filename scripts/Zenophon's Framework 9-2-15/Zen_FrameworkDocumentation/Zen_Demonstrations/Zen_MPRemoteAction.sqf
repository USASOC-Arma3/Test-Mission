// This file is part of Zenophon's ArmA 3 Co-op Mission Framework
// This file is released under Creative Commons Attribution-NonCommercial-NoDerivatives 4.0 International (CC BY-NC-ND 4.0)
// See Legal.txt

#include "Zen_FrameworkFunctions\Zen_InitHeader.sqf"

// Demonstration of Remote Actions and Objectives by Zenophon
// Version = Final at 2/10/2014
// Tested with ArmA 3 1.10

/** The framework is written in a style that supports the server doing almost everything possible, and the tutorials and demonstration urge you to exclude the clients entirely from your init. However, there are many possible situations that require the players to take some action that cannot be detected by a trigger.  Some of these are abstractions of the simulation, such as selecting an action to disarm an IED.  Others are commands given by the player that must be send across the network due to locality, such as a player ordering an AI convoy to stop.  There are also player actions that advance the mission, such as calling for extraction.  Although it is possible to use the radio or communication menu, I believe that the most straightforward and flexible system is the action menu.  The action menu is not a very advanced UI, and sometimes it can cause problems.  Nevertheless, the framework is meant to make things easier for mission maker, not the players.  A seasoned ArmA player can handle the action menu's quirks.*/

/** The key to understanding the action menu is that actions are created, shown, and executed locally.  This means that two players can have different actions or have the same action appear at different times.  The code that runs from an action only executes on that player's machine.  This seems to present a problem for scripts that are meant to run on the server.  However, some framework functions are specially designed to overcome this issue, and those that are not can be remotely executed on the server.*/

/** One thing that makes actions so powerful is the ability to attach arguments to them.  When an action is created, any values can be given that will be passed to the called function.  These values are a persistent property of the action.  This allows you to send necessary data to a function without using global variables.*/

/** Most often, you want to provide feedback to the player(s) about their choice of action.  For one-time mission events, tasks are a good choice, as they look nice and are easy to use with the framework's task system.  For other things, radio communication subtitles add immersion to your mission, even if voice acting is not an option.*/

/** If you have never seen or done anything like this, this is not a walk in the park.  I highly recommend that you read MP Remote Execution Demonstration and brush up your understanding of locality before reading this demonstration.  It may not be clear what is being executed where and when.  I suggest that you trace the program's execution, either mentally or on paper, to see why this design works.  Nevertheless, learning this skill will allow you to do things that are not possible otherwise.*/

/** As an example of something that could be done, I will now show an objective about assassinating an officer.  This requires a player to plant a bomb on his personal car, which will detonate when he gets in.  Any of the players should be able to plant the bomb, and other players will get feedback that the objective is complete.  The players will then escape in a civilian vehicle, calling for sniper support to get past a hostile roadblock.  This is obviously a short, tidy mission without any surprises, but you could always add in random events and increase the difficulty in various ways.*/

enableSaving [false, false];

/** The first thing to do is define the functions that client machines will use.  The structure below could be used as template for many similar designs.  The key to doing this properly is to divide the functions into the smallest operations that are still useful, while keeping related code together.  In general, a separate add and execute functions for each action works well (and is used several times in the framework).  It is also important that these functions run only on the clients (and the server if it is not dedicated), we will see what extra things the server will do later.  Each function here is documented in the framework style to help you see how they are used later.*/

/** Adds the action to plant a bomb, which calls f_PlantBomb.
Usage : Call
Params: 1. Object, the object that the bomb will be planted on
        2. Any, arguments for the action
Return: Void */
f_AddPlantBomb = {
    0 = (_this select 0) addAction ["Plant Bomb", f_PlantBomb, (_this select 1)];
};

/** Adds the action to request sniper fire, which calls f_CallSniper.
Usage : Call
Params: 1. Object, the object from which the sniper can be called
        2. Any, arguments for the action
Return: Void */
f_AddCallSniper = {
    0 = (_this select 0) addAction ["Call Sniper", f_CallSniper, (_this select 1)];
};

/** Performs commands when someone plants the bomb.  Removes actions, updates (4),
and calls f_TriggerBomb on the server.
Usage : Call
Params: 1. Object, to which the action is assigned
        2. Object, who called the action
        3. Scalar, the action ID
        4. String, a task
Return: Void */
f_PlantBomb = {
    0 = _this call f_RemoveActions;

    // All other clients run the function
    Zen_MP_Closure_Packet = ["f_RemoveActions", (_this select 0)];
    publicVariableClient "Zen_MP_Closure_Packet";

    // Zen_UpdateTask will work when called from any machine, the changes will be propagated correctly
    0 = [(_this select 3), "succeeded"] call Zen_UpdateTask;

    // Only the server runs the function
    Zen_MP_Closure_Packet = ["f_TriggerBomb", _this];
    publicVariableServer "Zen_MP_Closure_Packet";
};

/** Performs commands when someone calls the sniper.  Removes actions, updates (4),
and calls f_SniperFire on the server.
Usage : Call
Params: 1. Object, to which the action is assigned
        2. Object, who called the action
        3. Scalar, the action ID
        4. String, a task
Return: Void */
f_CallSniper = {
    0 = _this call f_RemoveActions;

    // all other clients run the function
    Zen_MP_Closure_Packet = ["f_RemoveActions", (_this select 0)];
    publicVariableClient "Zen_MP_Closure_Packet";

    // Zen_UpdateTask will work when called from any machine, the changes will be propagated correctly
    0 = [((_this select 3) select 0), "succeeded"] call Zen_UpdateTask;

    // only the server runs the function
    Zen_MP_Closure_Packet = ["f_SniperFire", [((_this select 3) select 1)]];
    publicVariableServer "Zen_MP_Closure_Packet";
};

/** Removes all actions from the given object.
Usage : Call
Params: 1. Object, to remove actions from
Return: Void */
f_RemoveActions = {
    removeAllActions _this;
};

/** Prints a side radio message from the given unit.
Usage : Call
Params: 1. Object, to send messages
        2. Scalar, the index of the message
Return: Void */
f_SniperRadio = {
    switch (_this select 1) do {
        case 0: {
            (_this select 0) sideChat "Eyes on target.";
        };
        case 1: {
            (_this select 0) sideChat "Target down.";
        };
    };
};

if !(isServer) exitWith {};

/** These functions will run on the server.  By dividing the functions across the exitWith, it is clear what can/will be called where.  The server should perform all the actions it can, especially those dealing with AI.  None of these or the above functions use global variables.  This demonstration would be simpler if no arguments were passed through these functions.  However, more work is needed every time a variable changes, and the functions become dependant on other functions or the init to define their variables.  By organizing what every function does and giving just the data it needs, you create a more flexible and reusable system.*/

/** Creates an officer and sends him to (1).  Explodes (1) when he gets in.
Completes (4) when he is dead.
Usage : Call
Params: 1. Object, the car the action was assigned to
        2. Object, who called the action
        3. Scalar, the action ID
        4. String, a task
Return: Void */
f_TriggerBomb = {
    private ["_officerCar", "_killOfficerTask", "_spawnPos", "_officerGroup", "_i"];
    sleep 30;

    // These values are the same as the ones below in the main thread
    _officerCar = _this select 0;
    _killOfficerTask = _this select 3;

    // Place the officer and one guard in the nearest building
    _spawnPos = (nearestBuilding _officerCar) buildingPos 0;
    _officerGroup = [_spawnPos, ["o_soldier_f", "o_officer_f"]] call Zen_SpawnGroup;

    // Order them to enter the vehicle
    {_x assignAsCargo _officerCar;} forEach (units _officerGroup);
    (units _officerGroup) orderGetIn true;

    // Wait for the officer to get in
    waitUntil {
        sleep 3;
        ([_officerGroup] call Zen_AreInVehicle)
    };

    // Suspense, then BOOM!
    sleep 2;
    for "_i" from 0 to 2 do {
    0 = [_officerCar, "r_80mm_he", 0, 0, true] call Zen_SpawnVehicle;
    };

    // Make sure it worked
    _officerCar setDamage 1;

    // Suspense, then success
    sleep 2;
    0 = [_killOfficerTask, "succeeded"] call Zen_UpdateTask;
};

/** Simulates a sniper eliminating (1).  Creates a dummy soldier
to provide radio chat for immersion.  Kills are timed randomly.
Usage : Call
Params: 1. Array, group, object, side, the units to kill
Return: Void */
f_SniperFire = {
    private ["_sniperGroup", "_sniper"];

    // Create the sniper and make him a dummy unit
    _sniperGroup = [[0,0,0], "b_sniper_f"] call Zen_SpawnGroup;
    _sniperGroup setGroupId ["Sniper"];
    _sniper = (units _sniperGroup) select 0;

    _sniper allowDamage false;
    _sniper hideObject true;
    _sniper disableAI "Move";
    _sniper disableAI "Target";
    _sniper disableAI "AutoTarget";
    _sniper disableAI "FSM";

    // Suspense, then print radio message 0 from the sniper
    sleep 4;
    if !(isDedicated) then {
        0 = [_sniper, 0] call f_SniperRadio;
    };
    Zen_MP_Closure_Packet = ["f_SniperRadio", [_sniper, 0]];
    publicVariable "Zen_MP_Closure_Packet";

    // Kill one of the given units every 2 to 4 seconds, printing a radio message
    // This would be more immersive with a sound effect
    {
        sleep (2 + random 2);
        _x setDamage 1;

        if !(isDedicated) then {
            0 = [_sniper, 1] call f_SniperRadio;
        };
        Zen_MP_Closure_Packet = ["f_SniperRadio", [_sniper, 1]];
        publicVariable "Zen_MP_Closure_Packet";
    } forEach ([(_this select 0)] call Zen_ConvertToObjectArray);

    // Garbage collect
    deleteVehicle _sniper;
    deleteGroup _sniperGroup;
};

// These generic markers will be used below
{_x setMarkerAlpha 0;} forEach ["mkTown", "mkRoadblock", "mkSafeHouse"];

sleep 1;

// Create an array of the playable blufor soldiers, this way you only need to name one person in the group
_players = units group X11;

// Give each player civilian clothes, mark them on the map, don't allow the Opfor to shoot them
0 = [_players, "civilian"] spawn Zen_GiveLoadoutBlufor;
0 = [_players] call Zen_TrackInfantry;
{_x setCaptive true;} forEach _players;

// Get a random spot on a road to put the officer's car
_officerCarPos = ["mkTown", 0, [], 1, [1, 100]] call Zen_FindGroundPosition;

// Create the car itself
_officerCar = [_officerCarPos, "o_mrap_02_f", 0, (random 360)] call Zen_SpawnVehicle;

// Create the task to kill the officer, nothing can change its state for a while
// This is the parent task for planting the bomb, it will be succeeded later (not directly from the init)
_killOfficerTask = [_players, "Eliminate the Opfor officer.", "Kill Officer"] call Zen_InvokeTask;

// For the task notifications to appear in order
sleep 2;

// Create the task for planting the bomb, it is important that we have the name of the task before adding the action
_bombTask = [_players, "Plant the bomb", "Plant Bomb", _officerCarPos, true, _killOfficerTask] call Zen_InvokeTask;

// This init will work for both locally hosted and dedicated servers
if !(isDedicated) then {
    0 = [_officerCar, _bombTask] call f_AddPlantBomb;
};

// Using Zen_MP_Closure_Packet like this will execute any function on all other machines on the network
// See MP Remote Execution Demonstration for an explanation; otherwise, just trust that it works
// You could also use BIS_fnc_MP, but I prefer my own method
Zen_MP_Closure_Packet = ["f_AddPlantBomb", [_officerCar, _bombTask]];
publicVariable "Zen_MP_Closure_Packet";

/** Because the mission is now advanced by actions, there is little more we can do here but wait for the players to be successful.  The only thing to worry about here is how we know to advance to the next part of the mission on the server.  In this case, the car exploding is a good cue to go for extraction.  Alternatively, we could have checked for the kill the officer task to be complete, the officer to be in the car, or even the bomb task to be complete (to let players escape sooner).  This is the simplest way though.*/

waitUntil {
    sleep 3;
    !(alive _officerCar)
};

// Get random escape car position, also note that a name like _carPos would be ambiguous in this mission (officer or escape)
_escapeCarPos = ["mkTown", 0, [], 1, [1, 100]] call Zen_FindGroundPosition;

// Create the civilian car for the players to escape in
_escapeCar = [_escapeCarPos, "C_Offroad_01_F", 0, (random 360)] call Zen_SpawnVehicle;

// Create the parent escape task
_escapeTask = [_players, "Drive the civilian truck down the road to the safehouse", "Escape to Safehouse", "mkSafeHouse"] call Zen_InvokeTask;

// For the task notifications to appear in order
sleep 2;

// Create the first child task for the escape
_reachEscapeCarTask = [_players, "Reach the escape vehicle", "Reach Escape Car", _escapeCar, true, _escapeTask] call Zen_InvokeTask;

// Complete the first escape child task when players reach the car
_h_nearCar = [_players, _reachEscapeCarTask, "succeeded", _escapeCarPos, "all"] spawn Zen_TriggerAreNear;

// The trigger will stop executing when it completes the task
waitUntil {
    sleep 2;
    (scriptDone _h_nearCar)
};

// Create the child task to get through the roadblock
// The Opfor won't open fire because the players are set captive,
// It could be changed so that the Opfor fire if the players try to drive around
// But the players don't know that, so we can just bluff
_passRoadBlockTask = [_players, "Get through the Opfor roadblock quickly.  They will open fire if you try to drive around, so your best bet is to try to talk or bribe your way through.", "Pass Roadblock", "mkRoadblock", true, _escapeTask] call Zen_InvokeTask;

// For the task notifications to appear in order
sleep 2;

// Create a child task to the roadblock task
_callSniperTask = [_players, "The sniper will eliminate any Opfor targets at the roadblock", "Call Sniper (Opt.)", 0, false, _passRoadBlockTask] call Zen_InvokeTask;

// Get a random position on the road near the marker, then a slightly shifted position for the guards
_roadblockPos = ["mkRoadblock", [20, 60], [], 1, [1, 100]] call Zen_FindGroundPosition;
_guardPos = [_roadblockPos, [8, 15]] call Zen_FindGroundPosition;

// Spawn the Opfor vehicle blocking the road and the guards
0 = [_roadblockPos, "o_mrap_02_f", 0, (random 360)] call Zen_SpawnVehicle;
_guardsGroup = [_guardPos, east, "infantry", 2] call Zen_SpawnInfantry;

/** Now the mission waits again for players to do everything they need to (recall that the players have just gotten into the escape car right now).  The two waitUntil loops below are the typical way to determine when something approaches then moves away from a point.*/

waitUntil {
    sleep 3;
    (([_escapeCar, _roadblockPos] call Zen_Find2dDistance) < 30)
};

// The players are now at the roadblock, so they can request sniper fire now
// Just like adding the bomb action, except we now give another argument for the roadblock guards
if !(isDedicated) then {
    0 = [_escapeCar, [_callSniperTask, _guardsGroup]] call f_AddCallSniper;
};

// Using the escape car allows all the players to use the action, and it simulates a radio in the car
// It is also easier to remove the action from the car for all players than to remove one action from each player
Zen_MP_Closure_Packet = ["f_AddCallSniper", [_officerCar, [_callSniperTask, _guardsGroup]]];
publicVariable "Zen_MP_Closure_Packet";

// Now would also be the time to order the Opfor to fire on the players if they try to run the roadblock
// That is not part of this demonstration though

// Allow some wiggle room in case the players drive backward or something, 20m here
waitUntil {
    sleep 3;
    (([_escapeCar, _roadblockPos] call Zen_Find2dDistance) > 50)
};

// Succeed the roadblock task
0 = [_passRoadBlockTask, "succeeded"] call Zen_UpdateTask;

// If the players got around without using the sniper, cancel the sniper task
// This is included just for completeness, it is bad presentation to leave tasks unfinished if players do everything correctly
if !([_callSniperTask] call Zen_AreTasksComplete) then {
    0 = [_callSniperTask, "canceled"] call Zen_UpdateTask;
};

// The final leg of the journey to the safehouse
waitUntil {
    sleep 3;
    (([_escapeCar, "mkSafeHouse"] call Zen_Find2dDistance) < 30)
};

// Escape successful, mission complete
0 = [_escapeTask, "succeeded"] call Zen_UpdateTask;

/** This is the most difficult demonstration, as it deals with locality and executing code on different machines.  It is also a full mission, playable in its current state (if you add the markers and players on the map).  A lot of the code does not directly relate to remote action, but it is important to see that this structure has a real use in mission making.  The functions and their use are more difficult to understand out of context or in pseudocode.  Many of the techniques used to build this mission compose the typical mission made using the framework.  This kind of mission is conclusive proof why scripting is preferable to the editor.  Even if this could be done in the editor, it would be impossible to debug, maintain, or reuse.  There is more to be added to improve this mission (and make it possible to fail), but this is a good demonstration of how you can use tasks and actions to interact with players during a mission.  You could even present players with different choices that allow the mission to go differently.*/
