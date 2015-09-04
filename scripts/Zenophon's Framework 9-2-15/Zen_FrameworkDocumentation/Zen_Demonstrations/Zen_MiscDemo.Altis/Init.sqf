// This file is part of Zenophon's ArmA 3 Co-op Mission Framework
// This file is released under Creative Commons Attribution-NonCommercial-NoDerivatives 4.0 International (CC BY-NC-ND 4.0)
// See Legal.txt

#include "Zen_FrameworkFunctions\Zen_InitHeader.sqf"

// Miscellaneous Demonstration by Zenophon
// Version = Final 5/12/14
// Tested with ArmA 3 1.18

/**  If you are just starting out making missions, it can be hard to remember how to do some things, even if you have seen them before.  It is even more daunting when you are not aware of the various tricks and algorithms that accomplish common operations.  This mission is a general review of some of the easier demonstrations and the tutorials, designed give you more example usages of these concepts.  All of the missions included in the framework's documentation are meant to show you as much about mission making as possible.  Some comments are just about SQF and coding style in general, which is boring if you only want to make mission.  However, just using the basic constructs modified for your mission will give you a huge advantage over diving in blind.  Having the framework's function index open while you code is also a good idea, often there is a function that does want you want, you just need to find it. */

titleText ["Good Luck", "BLACK FADED", 0.4];
enableSaving [false, false];

player creatediaryRecord["Diary", ["Parachute Demonstration", "Drop to lit field. Equip available rifle. Contact Friendly civilians. Complete the first objective.<br/>"]];

if (!isServer) exitWith {};

// Delaying code to be executing after some point in the mission is easy to do by spawning another thread
// Once this is called, the engine will continue executing other code and get to deleting the objects 60 seconds later
f_deleteObjects = {
    private ["_pObjectArray"];
    _pObjectArray = _this select 0;
    sleep 60;
    {
        deleteVehicle _x;
    } forEach _pObjectArray;
    if (true) exitWith {};
};

// This function accepts a reference to an array, _this, which it updates as it runs
// Instead of returning a value, the array given as an argument is now modified
// This saves time and space by not creating a new array, then assigning it
// The three marker areas have centers at 315, 270 and 225 degrees in relaton to X11
// Then the areas are rotated 45, 0 and -45 degrees.
f_generateOPFORpatrolareas = {
    for "_i" from 1 to 3 do {
        _mkPatrolCenter = [X11, [690,700], 0, 0, 0, [315 - (45 * _i), 315 - (45 * _i)]] call Zen_FindGroundPosition;
        _mkPatrolArea = [_mkPatrolCenter, "", "colorBlack", [600,200], "rectangle", 45 - (45 * _i), 1] call Zen_SpawnMarker;
        0 = [_this, _mkPatrolArea] call Zen_ArrayAppend;
    };
};

sleep 1;

// This demonstration has multiple elements:
//  - Insertion by helicopter and parachute
//  - Modify aircraft patrol orders
//  - Change loadout at ammo box
//  - Join FIA to player
//  - Remove items placed in game world
//  - Generate and rotate area markers in-line
//  - Assign OPFOR squads to patrol these areas
//  - Move area markers and modify their size

// Give the player a civilian loadout, a parachute, and make him captive
// The action simulates the character waiting patiently for an hour
0 = [X11, "Civilian"] call Zen_GiveLoadoutBlufor;
X11 setCaptive true;
X11 addBackpack "B_Parachute";
X11 addAction ["Skip Ahead One Hour", {skipTime 1}, [], 6, false, false, ""];

// Concatenate all playable units into single array of objects
_allplayersArray = [X11, Kostas];

// Helper functions
0 = [_allplayersArray] call Zen_AddGiveMagazine;
0 = [_allplayersArray] call Zen_AddRepackMagazines;

// Set units in playable groups to infantry skill level
0 = [_allplayersArray, "infantry"] call Zen_SetAISkill;

// Generate the helicopter's initial position
// Using a marker in the editor specifically for this purpose makes it easier to change the start point later
// Rather than calculating the point based upon the landing point, which would require changing the angles in code
_heliSpawnPos = ["BLUFORInsertionPoint", [50,100],[],0] call Zen_FindGroundPosition;

// Spawn a helicopter, making it face the right direction makes it appear the it was already flying towards the insertion
_helicopter = [_heliSpawnPos, "b_heli_light_01_f", 400, 180] call Zen_SpawnHelicopter;

// Move operative into helicopter
0 = [X11, _helicopter] call Zen_MoveInVehicle;

// Slightly cloudy, using 60*45 works fine and makes it easier to see the number of minutes
0 = [["overcast", 0.3, 0.5, 60*45], ["date", random 60, 3]] spawn Zen_SetWeather;

// Move south
_moveorders = [_helicopter,"BLUFORStrikingPoint","full",400] spawn Zen_OrderVehicleMove;

// After nearing Striking zone pass to the next statement
waitUntil {
    sleep 2;
    (([_helicopter, "BLUFORStrikingPoint"] call Zen_Find2dDistance) < 200)
};

// Move West to rendezvous point
// It is good practice to terminate any Orders function before spawning another one
// This avoids all conflicts in AI behavior, and you don't have to worry about what the function is doing
terminate _moveorders;
_patrolorders = [_helicopter, "BLUFORPatrolZone",200,0,"full",400] spawn Zen_OrderAircraftPatrol;

// FIA operative throws down some chemlights
_lightArray = [];
for "i" from 1 to 2 do {
    _signalPos = ["WeaponCache", [10,15]] call Zen_FindGroundPosition;

    // You can make code very compact if you choose
    // Here the call to Zen_SpawnVehicle acts the same way, and its return value is evaluated and place in _lightArray
    // This saves a little space by not storing a reference, but reducing codes readability
    _lightArray set [count _lightArray, ([_signalPos, "chemlight_blue"] call Zen_SpawnVehicle)];

    // You could go one step further and put the call to Zen_FindGroundPosition instead of _signalPos
    // Chaining many functions together will always be handled in the right order by the engine
    //_lightArray set [count _lightArray, ([["WeaponCache", [10,15]] call Zen_FindGroundPosition, "chemlight_blue"] call Zen_SpawnVehicle)];
};

// Wait until the player exits the helicopter
waitUntil {
    sleep 2; 

    // For multiple units, you want to take advantage of the ease of using Zen_AreNotInVehicle
    ([(group player), _helicopter] call Zen_AreNotInVehicle)
    
    // If you have only want unit, and really want to be efficient, you can just use this
    // !(player in _helicopter)
};

// Order helicopter to nearby airport
terminate _patrolorders;
0 = [_helicopter, "MolosAirfield", "full", 200, true] spawn Zen_OrderHelicopterLand;

// Upon approaching ammo box switch loadout to sniper
waitUntil {
    sleep 2;

    // The 'distance' command is a 3d command, this prevents the player 
    // from getting ammo e.g. through the floors of a building
    // If you want a 2d distance, use Zen_Find2dDistance
    ((X11 distance BLUFORAmmo) < 5)
};

// A preset loadout makes this step easy, don't forget to set the player not captive if you give him a weapon
0 = [X11, "Sniper"] call Zen_GiveLoadoutBlufor;
X11 setCaptive false;

// Remove chemlights
// f_deleteObjects can work for any number of any kind of objects
// This sort of encapsulation and generalization with functions allows you to reuse your code quickly
0 = [_lightArray] spawn f_deleteObjects;

// Group up, and give the FIA soldier NVG's
[Kostas] join X11;
Kostas linkItem "NVGoggles";

// Track all units in playable groups
0 = [_allplayersArray] call Zen_TrackInfantry;

// Set up three areas with patrolling squads. These areas are created in relationship to the position
// of player. Consider this 'soft' or cautious AI. OPFOR doesn't know the exact location of player
// and the strength of BLUFOR so they set up some patrols along the margin of probable location of player.

// We have to initialize the array to be empty before we pass it to f_generateOPFORpatrolareas
// If we already had an array with some elements, that would word fine too
_patrolAreas = [];

// Center of first area is 315 degrees from X11, who is near the ammo box
// The center of 2nd and 3rd areas are 270 and 225 degrees
// Because the angles are 45 degrees apart, a loop will be applied
// In general, always try to loop through something multiple times, it saves coding and makes changing things easier
0 = _patrolAreas call f_generateOPFORpatrolareas;

// Spawn one squad for each generated marker area and give them patrol orders
_patrolGroups = [];
_patrolThreads = [];

{
    // Here _x is a marker
    // For clarity, you can assign a variable to _x, e.g. _marker = _x;
    _randomPosition = [_x] call Zen_FindGroundPosition;
    _opforPatrolGroup = [_randomPosition, east, "militia", [2,5]] call Zen_SpawnInfantry;
    _h_patrols = [_opforPatrolGroup, _x, [], 0, "normal"] spawn Zen_OrderInfantryPatrol;

    // Simple debug statements, making sure that your variables have the correct value
    // player sidechat ("OPFOR Group " + str _opforPatrolGroup);
    // player sidechat ("OPFOR Orders " + str _h_patrols);
    
    0 = [_patrolGroups, _opforPatrolGroup] call Zen_ArrayAppend;
    0 = [_patrolThreads, _h_patrols] call Zen_ArrayAppend;
} forEach _patrolAreas;

// Track squads for demonstration and debug purposes
0 = [_patrolGroups, "group"] call Zen_TrackInfantry;

// Create the first objective
_vehiclePosition = ["OPFORMotorPool"] call Zen_FindGroundPosition;
_OpsObjective = [_vehiclePosition, (group X11), east, "Wreck","eliminate"] call Zen_CreateObjective;

// Wait for the wreck to be destroyed
waituntil {
    sleep 5;
    ([(_OpsObjective select 1)] call Zen_AreTasksComplete)
};

// Opfor is more urgent now to locate and confront Blufor.
// Reposition the area markers so that their edges touch the 
// vehicle location. All squads assigned to patrol in these areas will continue
// to patrol in their assigned area. The area is also decreased in size.
{
    _x setMarkerSize [400,200];

    // As with f_generateOPFORpatrolareas, a loop can be used to change multiple values in code
    // We use a factor of 45 to advance the angles for the position
    // The angles of the areas remain 315,270 and 225; they are only moved
    // Recall that a forEach loop is basically a for loop, _forEachIndex is an integer
    _x setMarkerPos ([_vehiclePosition, [390,400], 0, 0, 0, [315 - 45 * _forEachIndex, 315 - 45 * _forEachIndex]] call Zen_FindGroundPosition);
} forEach _patrolAreas;

// Order infantry to patrol with greater urgency
// Here we modify the array during the loop, this is fine, because we do not change how many elements it has
// After each iteration, the value at that index has changed, but the next iteration is not affected
// We could also have used a forEach loop here, the syntax is almost always interchangeable
for "_i" from 0 to 2 do {
    terminate (_patrolThreads select _i);
    _h_patrols = [_patrolGroups select _i, _patrolAreas select _i, [], 0, "full"] spawn Zen_OrderInfantryPatrol;
    _patrolThreads set [_i,_h_patrols];
};

sleep 600;
endMission "end1";

/** This mission is an amalgamation of various techniques, much like any real mission is.  The code is kept relatively easy to follow, while discussing many common ideas and coding practices.  Compare this soft AI to the more direct AI in the Zen_AIShareInfo demonstration. In that demonstration, the Opfor share information among themselves using the commands 'nearTargets', 'knowsAbout' and 'reveal'.  You can combine soft and hard AI to put the squeeze on mission players.  See the Zen_DynamicPatrolMarkers demonstration for another demonstration on moving markers, and also Zen_MultiThreadManagement for a more complete discussion of spawning and terminating threads. */
