// This file is part of Zenophon's ArmA 3 Co-op Mission Framework
// This file is released under Creative Commons Attribution-NonCommercial-NoDerivatives 4.0 International (CC BY-NC-ND 4.0)
// See Legal.txt

#include "Zen_FrameworkFunctions\Zen_InitHeader.sqf"

// Demonstration of Event Queue by Zenophon
// Version = Final 5/17/2014
// Tested with ArmA 3 1.18

/**  The SQF language mainly supports directly functional execution with multi-threading to react to mission events.  However, as threads can only communicate using global variables, allowing the events of your mission to happen in an arbitrary order becomes very messy.  Events that behave differently based upon the status of other events and the mission require a change of programming paradigm.  In this case, from functional to event-driven.  The system of events outlined below is a skeleton designed to be extremely customizable and adaptable.  An short example mission using the events is given to show some different possibilities in action.  This system is designed only for singleplayer.  However, it can be extended to support multiplayer by allowing client machines to send and receive events, and updating the data on all machines. */

enableSaving [false, false];
if !(isServer) exitWith {};

/**  Although events are abstracted, they still rely on functions to execute.  Thus, each event name is the name of the function that runs when it is triggered.  To allow an event to be flexible, the arguments passed to the function are read from an array when the event triggers.  The arguments are organized by name-value pairs, using the name of the function.  This allows the order of the events and arguments to be unimportant.  However, it means that duplicating arguments for the same event function causes only the first set of arguments with that event is used.  In this case, the order of the arguments array matters.  If you manage the queue and arguments list well, multiple events with the same name can use different arguments. */

/**  The format for each nested array is ["functionName", any].  Arguments do not have to exist when an event is queued, only when it is triggered.  This allows the triggering function to add the appropriate arguments just before triggering the event. */
Event_Arguments_Array = [];

/**  The format for the event queue is ["functionName", flag].  The function name must agree with the name in the arguments, and it is always a string.  This is done to minimize the amount of data that needs to be stored in the array.  The flag value is simply a boolean value, determining if the event is to be triggered.  Each time the queue handler reads through the queue, all events with a flag of 'true' will have their named function executed with the corresponding arguments.  Using the name queue is slightly misleading, as events to do not necessarily occur in the order they were put in.  Rather, duplicate events will trigger in the order they were added, which is unimportant because they are duplicates. */
Event_Queue_Array = [];

/**  This is the event listener thread itself.  It processes from left to right every time it checks, using the flags to evaluate.  Executed events and their arguments are removed from the respective arrays, so that the event can only trigger once.  This thread requires that the events have a matching entry in the arguments array. */
f_HandleEventQueue = {
    while {true} do {
        sleep 5;
        {
            if (_x select 1) then {
                _eventName = (_x select 0);
                _qualifier = [_eventName, "@$"] call Zen_StringGetDelimitedPart;
                _functionName = _eventName;
                if (count toArray _qualifier > 0) then {
                    _functionName = [_eventName, "@" + _qualifier + "$", ""] call Zen_StringFindReplace;
                };

                _argsIndex = [Event_Arguments_Array, _eventName, 0] call Zen_ArrayGetNestedIndex;
                _args = (Event_Arguments_Array select _argsIndex) select 1;
                0 = _args spawn (missionNamespace getVariable _functionName);
                0 = [Event_Arguments_Array, _argsIndex] call Zen_ArrayRemoveIndex;
                Event_Queue_Array set [_forEachIndex, 0];
            };
        } forEach Event_Queue_Array;
        0 = [Event_Queue_Array, 0] call Zen_ArrayRemoveValue;
    };
};

/**  This is the default event trigger function.  Calling this with the event function name will cause it to execute. Calling this function when the event is not queued will result in no action.  That is the strength of this system, you can call for the same event at different times, and only the first time will cause it to happen.  This allows you to not check every time you call the function, unlike calling the action code directly.  Usage is: "EventName" call f_EventTrigger_Generic;, returns void. */
f_EventTrigger_Generic = {
    _nestedArray = [Event_Queue_Array, _this, 0] call Zen_ArrayGetNestedValue;
    if (count _nestedArray > 0) then {
        _nestedArray set [1, true];
    };
};

/**  This functions provides a simple remove operation for events.  The event is not called, and its arguments are also removed.  This function also accounts for no arguments existing. */
f_RemoveEvent = {
    {
        _index = [_x, _this, 0] call Zen_ArrayGetNestedIndex;
        if (_index != -1) then {
            0 = [_x, _index] call Zen_ArrayRemoveIndex;
        };
    } forEach [Event_Arguments_Array, Event_Queue_Array];
};

/** This provides a simple check for an event existing.  You can use it terminate threads that are waiting to trigger the same event, or use it as a signal that a new event must be queued.
Usage is: "EventName" call f_EventIsQueued;, returns boolean.*/
f_EventIsQueued = {
    (([Event_Queue_Array, _this, 0] call Zen_ArrayGetNestedIndex) > -1)
};

// You have to start the event handling thread, do this only once
0 = [] spawn f_HandleEventQueue;

/**  Here ends the basic code for the event queue.  Everything after this is mission specific.  Using the event queue, we will build an incomplete mission that deals only with some objectives.  The pleasantries of loadouts, an insertion, tasks, etc are ignored for this demonstration, and the code focuses only on how to use the event system.  The mission outlined below benefits from using the event queue, both in efficiency and general neatness. */

/**  The outline of the mission is like so.  There are three starting objectives that involve planting explosives at three different sites.  The player can choose to detonate any number of the bombs at any time.  However, detonation means that no more bombs can be planted, so the player must decide how many objectives to do.  Each objective has a direct consequence after the bombs are detonated.  Based upon which objectives are destroyed, different things happen afterwards.  Using this system, there are several possible mission outcomes.  Coding each one separately would be a waste of time, and trying to detect which combination had occurred would be messy. */

 /**  The events allow you to specify what will happen in a simple cause and effect way.  You deal only with one cause and one effect at a time.  Then you can spawn all of the causes as threads or just list them together in a loop.  You can also chain events together, such that triggering one event queues another and creates the trigger for it. */

/**  Now we begin defining the functions called as events. When making your mission, it is best to just create empty functions here with the names you want.  Then use the events in your mission, and implement the functions later.  This prevents wasting time by having to redo things if you decide to do something differently.  Generally, there are two types of functions, triggers and actions.  The trigger functions are just proxy functions that help you call the right action.  They could be called or spawned; they could update or create the arguments for the action, or even trigger multiple actions.  Triggers are called by you in your code with whatever arguments you list.  Actions are typically the name of the events, as this is the code that is called; they always get their arguments from the global array. */

// This function is very simple and entirely hard-coded, except for the marker
f_EventAction_SpawnPatrols = {
    _groupArray = [];
    for "_i" from 1 to 3 do {
        _spawnPos = [_this] call Zen_FindGroundPosition;
        _group = [_spawnPos, east, "infantry", [2, 3]] call Zen_SpawnInfantry;
        0 = [_group, east] call Zen_GiveLoadout;
        0 = [_groupArray, _group] call Zen_ArrayAppend;
    };

    0 = [_groupArray, _this] spawn Zen_OrderInfantryPatrol;
};

// This should only be called by the player's detonate action
f_EventAction_Detonate = {
    (_this select 0) removeAction (_this select 2);

    // Destroy the objects with the bombs planted
    // A real explosion would be nice
    {
        _x setDamage 1;
    } forEach _this;
};

// _this == ["marker", "support"]
f_EventAction_FireSupport = {
    _pos = [(_this select 0)] call Zen_FindGroundPosition;
    0 = [_pos, (_this select 1)] call Zen_InvokeFireSupport;
};

// _this == array, object, group, side
f_EventAction_Rearm = {

    // Get the units array
    _units = _this call Zen_ConvertToObjectArray;

    // Define a partial list, and populate it with random units
    _sublist = [];
    for "_i" from 1 to (count _units / 3) do {
        0 = [_sublist, [_units] call Zen_ArrayGetRandom] call Zen_ArrayAppend;
    };

    // Remove duplicate units and give them an AT loadout
    // These soldiers will cause serious problems for Blufor armor
    _sublist = [_sublist] call Zen_ArrayRemoveDuplicates;
    0 = [_sublist, "AT Specialist"] call Zen_GiveLoadoutOpfor;
};

// _this == ["objective", "markers"]
f_EventAction_Heli = {

    // Calculate center of objectives where bombs were planted
    _center = _this call Zen_FindAveragePosition;

    // Create one marker covering the area around the given markers
    _marker = [_centerPos, "", "colorBlack", [1500, 1500], "ellipse", 0, 0] call Zen_SpawnMarker;

    // Spawn one Blufor attack helicopter
    // You should calculate a far away spawn position in a real mission
    _heli = [_center, "b_attack_heli_01_f"] call Zen_SpawnHelicopter;

    // Order the helicopter to patrol in the marker
    0 = [_heli, _marker] spawn Zen_OrderAircraftPatrol;
};

// This function is not strictly an event, it is just used with the bomb planting actions
f_BombPlanted = {
    (_this select 0) removeAction (_this select 2);

    // Instead of using a global variable,
    // We can use the event system's built-in checking
    if !("f_EventAction_Detonate" call f_EventIsQueued) then { // Queue to event and its args
        0 = [Event_Queue_Array, ["f_EventAction_Detonate", false]] call Zen_ArrayAppend;
        0 = [Event_Arguments_Array, ["f_EventAction_Detonate", (_this select 0)] call Zen_ArrayAppend;

        // Add the action to detonate to the player
        // Once activated, it will fire the event function
        player addAction ["Detonate Bombs", {0 = "f_EventAction_Detonate" call f_EventTrigger_Generic;}];
    } else { // update the args with the object
        _nestedArray = [Event_Arguments_Array, "f_EventAction_Detonate", 0] call Zen_ArrayGetNestedValue;
        _nestedArray set [1, (_nestedArray select 1) + [(_this select 0)]];
    };

    // Using the arguments for which objective this action was linked to
    // We can queue the resulting effect for later
    // Recall that switch statements are case sensitive for strings
    switch (toLower (_this select 3)) do {
        case "ammo": {
            0 = [Event_Queue_Array, ["f_EventAction_Rearm", false]] call Zen_ArrayAppend;
        };
        case "radio": {
            0 = "f_EventAction_FireSupport" call f_RemoveEvent;
        };
        case "aaa": {
            0 = [Event_Queue_Array, ["f_EventAction_Heli", false]] call Zen_ArrayAppend;
        };
    };

    // This is the objective where a bomb was just planted
    _nearestObj = [["mkObj1", "mkObj2", "mkObj3"], player] call Zen_FindMinDistance;

    // We now update the arguments to the Blufor helicopter support function
    // The helicopter will only patrol around areas were bombs went off
    // This is just an example of what you could do, and is not that significant
    _nestedArray = [Event_Arguments_Array, "f_EventAction_Heli", 0] call Zen_ArrayGetNestedValue;
    _nestedArray set [1, (_nestedArray select 1) + [_nearestObj]];

    // Now set the marker for the Opfor fire support to be the last objective marker where a bomb was planted
    // It is not necessary to check for this or the helicopter event before changing their arguments
    // That is another advantage to the event system
    _nestedArray = [Event_Arguments_Array, "f_EventAction_FireSupport", 0] call Zen_ArrayGetNestedValue;
    _argsArray = _nestedArray select 1;
    _argsArray set [0, _nearestObj];

    // The last part of planting a bomb is the Opfor calling for help
    // We now spawn enemy patrols between the players and the next objective

    // We remove this objective and choose between the other two
    _nextObj = [["mkObj1", "mkObj2", "mkObj3"] - [_nearestObj], player] call Zen_FindMinDistance;

    // Get the middle between the two markers
    _centerPos = [_nextObj, _nearestObj] call Zen_FindAveragePosition;

    // Create a marker dynamically to cover this patrol area
    _patrolMarker = [_centerPos, "", "colorBlack", [250, 250], "ellipse", 0, 0] call Zen_SpawnMarker;

    // Now we can call for another event from this one
    // There is no need to queue it or use a trigger, as this code can only execute one for each action
    0 = _patrolMarker call f_EventAction_SpawnPatrols;
};

// Pretend these three area markers delineate three general areas for some objectives
// Assume they exist a fair distance appear, about 2-3 times their radii, and are roughly circular
{_x setMarkerAlpha 0;} forEach ["mkObj1", "mkObj2", "mkObj3"];

// Let some players exist, their leader being X, a reasonable distance from the objective areas
_players = group X;

// Get the positions of the three objectives
_obj1Pos = ["mkObj1"] call Zen_FindGroundPosition; // This one shall be an ammo cache
_obj2Pos = ["mkObj2"] call Zen_FindGroundPosition; // This one a radio outpost
_obj3Pos = ["mkObj3"] call Zen_FindGroundPosition; // And this one a AAA site

sleep 1;

// Spawning the objectives is not the point here, so minimal effort is put in
_obj1Object = [_obj1Pos, east] call Zen_SpawnAmmoBox;
_obj2Object = [_obj2Pos, "O_mrap_02_f"] call Zen_SpawnVehicle;
_obj3Object = [_obj3Pos, "o_tank_aaa_02_f"] call Zen_SpawnVehicle;

/**  We could use an event system trigger, but the player selecting an action is its own kind of trigger.  If the order the bombs were planted in mattered, you could queue arguments for the same event several times, then use the actions to trigger the event.  We will use an event trigger for the detonate action, as its arguments must be updated dynamically, unlike the addAction arguments below.  The action arguments tell f_BombPlanted event to queue for later. */

// The action to detonate will be added by the first bomb being planted
// We also want to queue the event itself when the first bomb is planted
_obj1Action = _obj1Object addAction ["Plant Bomb", f_BombPlanted, "Ammo"];
_obj2Action = _obj2Object addAction ["Plant Bomb", f_BombPlanted, "Radio"];
_obj3Action = _obj3Object addAction ["Plant Bomb", f_BombPlanted, "AAA"];

/**  Some possible events could happen only if the objective is not completed.  We can cue these now, then remove them later.  This results in the same usage later, and makes more sense than using negative events (meaning that the presence of an event causes something not to happen).  However, as negative events are a possibility, they will be shown later in this mission. */

// Unless the player destroys the Opfor radio outpost, the Opfor will call in fire support once the bombs detonate
// This action could be removed later, and its arguments will be updated by the bomb planting actions
// The argument values are place-holders, "0" being the marker where fire support will be called in
// and "1" being the fire support template, we will create the template later only if the event is triggered
0 = [Event_Queue_Array, ["f_EventAction_FireSupport", false]] call Zen_ArrayAppend;
0 = [Event_Arguments_Array, ["f_EventAction_FireSupport", ["0", "1"]] call Zen_ArrayAppend;

// If the player destroys the Opfor AAA vehicle, the Blufor will give air support
// The arguments initialized here will also be updated by the bomb planting actions
// The event itself might be added later by an action
0 = [Event_Arguments_Array, ["f_EventAction_Heli", []] call Zen_ArrayAppend;

// Now we can queue up the possible spawning events
0 = [Event_Queue_Array, ["f_EventAction_SpawnPatrols@mkObj1$", false], ["f_EventAction_SpawnPatrols@mkObj2$", false], ["f_EventAction_SpawnPatrols@mkObj3$", false]] call Zen_ArrayAppend;

/**  We now use a slightly strange, but useful feature of the event queue.  Because each event is a function and we can have duplicates queued, we want to avoid calling the same event with the same arguments multiple times instead of multiple events with different arguments.  Therefore, the event queue offers the ability to qualify an event name with an extra identifier.  This text is delimited by a @ and a $.  Only one qualifier is allowed per event name, but is may be anywhere in the name.  Once the event is called, the qualifier is removed and the function is called normally.  The arguments are still retrieved using the unqualified name.  This allows a trigger function to differential between duplicate events, and it prevents you from having to create multiple identical functions. */

// Why repeat yourself if you don't have to
// This macro spans multiple lines using a ' \'
#define SPAWN_NEAR(MK) if (([player, MK] call Zen_Find2dDistance) < 700) then { \
    if (("f_EventAction_SpawnPatrols@" + MK + "$") call f_EventIsQueued) then { \
        0 = [Event_Arguments_Array, ["f_EventAction_SpawnPatrols", MK] call Zen_ArrayAppend; \
        0 = ("f_EventAction_SpawnPatrols@" + MK + "$") call f_EventTrigger_Generic; \
    }; \
}; \

// This mission has only two well-defined stages
    // When the player is planting bombs
    // After the bombs are detonated
// So we need one loop to wait for the detonate action
waitUntil {

    // Because the players could approach any objective, we will spawn guards there based upon the players being close
    // Using events and macros, we have greatly reduced the amount of coding work required
    {
        SPAWN_NEAR(_x)
    } forEach ["mkObj1", "mkObj2", "mkObj3"];

    // Instead of waiting for the detonate action itself, we can wait for its effect
    (!(alive _obj1Object) || !(alive _obj2Object) || !(alive _obj3Object))
};

// If the player did not get to some of the objectives, spawn the patrols for them now anyway
// We use the same syntax to get the qualified names as in the macro
// Using marker names makes the qualifiers easier, but you could use anything you want
{
    if (("f_EventAction_SpawnPatrols@" + _x + "$") call f_EventIsQueued) then {
        0 = [Event_Arguments_Array, ["f_EventAction_SpawnPatrols", _x] call Zen_ArrayAppend;
        0 = ("f_EventAction_SpawnPatrols@" + _x + "$") call f_EventTrigger_Generic;
    };
} forEach ["mkObj1", "mkObj2", "mkObj3"];

// Another macro to automate removing the actions, if they have not been destroyed already
#define RMV_ACT(OBJ, ACT) if (alive OBJ) then {OBJ removeAction ACT;};
RMV_ACT(_obj1Object, _obj1Action)
RMV_ACT(_obj2Object, _obj2Action)
RMV_ACT(_obj3Object, _obj3Action)

// We can pass the correct fire support template to the function indirectly
if ("f_EventAction_FireSupport" call f_EventIsQueued) then {

    // Create the Opfor fire support, which is called by their radio outpost
    // Give it a large radius to catch the player,
    // If they detonate the bombs from within the area where they just planted a bomb
    _fireSupport = ["r_80mm_he", 15, 2, 4, 10, 400, 20] call Zen_CreateFireSupport;

    // Then update the arguments for the event with the template name
    // The position of the fire support has already been set
    _nestedArray = [Event_Arguments_Array, "f_EventAction_FireSupport", 0] call Zen_ArrayGetNestedValue;
    _argsArray = _nestedArray select 1;
    _argsArray set [1, _fireSupport];

    // Trigger the event itself
    0 = "f_EventAction_FireSupport" call f_EventTrigger_Generic;
};

/**  Notice below the usage of !(f_EventIsQueued) to check if we should do something.  This, as mentioned before, is a negative event.  Generally, these are not as straightforward as adding the event first then use f_RemoveEvent, keeping all events positive.  This is necessary when event arguments are important.  Otherwise, negative events are basically boolean flags telling you to do something.  The code below does not really fit with the event system. */

if !("f_EventAction_Rearm" call f_EventIsQueued) then {
    0 = east call f_EventAction_Rearm;
};

// There's no need to check if the event even exists
// All the decisions about calling for Blufor air support are done
// And its arguments have already been set
0 = "f_EventAction_Heli" call f_EventTrigger_Generic;

// At this point the mission should spawn a Blufor armored platoon to attack the Opfor
// If the player did not take out the ammo cache, the Opfor will have access to lots of AT weapons
// As this is not a full mission, it is pointless to actually code the armored attack
// If you are interested in how to do this, see Zen_RandomBattle.Altis demonstration

/**  The event queue is not a complete replacement for functional mission-making.  It is also not exactly straightforward to use the events, as the execution of code jumps around during the mission.  However, as you can see above, they can greatly simplify your mission when used for what they do best.  The more complex your missions become, the less you can afford disorganization and unnecessary complications.  Once you have your events organized and implemented correctly, you can partition that code from your mission.  This makes calling for complex logic during execution very simple. */
