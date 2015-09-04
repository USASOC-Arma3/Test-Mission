// This file is part of Zenophon's ArmA 3 Co-op Mission Framework
// This file is released under Creative Commons Attribution-NonCommercial-NoDerivatives 4.0 International (CC BY-NC-ND 4.0)
// See Legal.txt

#include "Zen_FrameworkFunctions\Zen_InitHeader.sqf"

// Demonstration of Spawning Functions by Zenophon
// Version = Final 3/2/14
// Tested with ArmA 3 1.10

/**  The spawning functions allow you to place any object you need in your mission, and provide different levels of detail for your implementation.  Some functions use small, simple templates, like Zen_SpawnCamp.  Others provide extra features to automatic very common actions; e.g., Zen_SpawnHelicopter spawns a helicopter and places a crew of the correct side in it for you.  The last level of functions allow the most detailed control, without directly using SQF commands; e.g., Zen_SpawnVehicle can be used to place any vehicle in the game. */

/**  Because no spawning function could anticipate your exact needs, most functions return the spawn object(s), allowing you to modify them further to fit your mission.  You could alter their inventory, change their texture, or anything else that's possible in ArmA.  This mission is accompanied by a map file, so you can see the placement of cars in the nearby town of Gravia and other random effects. You can just study the script or preview the mission multiple times to see how things are different. */

titleText ["Good Luck", "BLACK FADED", 0.2];
enableSaving [false, false];

player creatediaryRecord["Diary",
["Spawn Units, Vehicles and Objects Demonstration", "Call Zen_Spawn... with different parameters.
<br/>
<br/>Spawn eight civilian automobiles in Gravia.
<br/>Add weapons and ammo to the automobiles
<br/>
<br/>Spawn a small camp
<br/>
<br/>Spawn a convoy and attach the units to the player
<br/>
<br/>Spawn a fortification
<br/>
<br/>Spawn an armored vehicle 25 meters northeast of fortification
<br/>
<br/>Spawn a recon unit inside the fortification
<br/>
<br/>Spawn an empty vehicle and load with a crew and passengers
<br/>
<br/>Spawn a group inside a nearby house
<br/>"
]];

/**  Macros are a benefit of preprocessed languages, such as C/C++.  They can be useful to prevent repeating code without using loops or functions, and they can define constants without using a variable for them.  You can go further by allowing a macro to accept arguments.  When the macro is invoked with certain arguments, it copies the value exactly as it appears in the definition.  This can be used to create function-like macros, without any of the overhead of calling a function.  They can also be used to replace text that cannot be passed to a function, such as an SQF command. */

// Gratuitous use of macro
#define _MARKERALPHA(ARG1) ARG1 setMarkerAlpha 0;
_MARKERALPHA("Zen_Spawn_Marker_One");
//"Zen_Spawn_Marker_One" setMarkerAlpha 0;

if (!isServer) exitWith {};
sleep 1;

/** Using framework spawning functions is preferable to the editor for several reasons.  First, you can randomize object placement using the ubiquitous Zen_FindGroundPosition, allowing the mission to play differently every time.  Beating a mission by learning exactly where enemies are is not a fun way to play, and the framework makes a significant effort to discourage that kind of mission. */

/**  Second, functions allow randomization in the type of vehicles, or even their crew and passengers.  In the editor, you know the exact vehicle that will be there, but the framework gives you an easy way to surprise players with a tank instead of an APC.  Zen_SpawnConvoy is a good example of this, there are three random vehicles every time, but each one still fits its role (lead vehicle, troop transport, etc). */

/**  Third, functions allow you to manipulate the spawned objects quickly and efficiently (using more functions).  Instead of having to name every object you place in the editor, which can quickly become tedious and difficult to keep track of, everything that spawns can be concisely collected into an array and modified in a few lines of code.  Other demonstrations and the sample missions contain various examples of spawning things in a loop and appending them to an array.  This demonstration shows some functions that already return an array of objects.*/

/**  Finally, spawning many vehicles and soldiers in your the mission decreases performance.  In the editor, everything that is placed exists from the mission start, until it is deleted.  Using the framework allows you to put your spawning into stages, and as the mission advances, you spawn what you need to keep the mission going.  You can also take advantage of those milestones to clean up previously spawned objects because all the names are returned.  This contributes to making a framework mission run much more effeciently. */

// Spawn 8 vehicles in all towns within 600 meters of the marker, the only one being Gravia
// If the position is between several towns, allow enough distance to make sure the town will be included
// Zen_SpawnAmbientVehicles decides where to spawn vehicles based upon the center position of a town,
// which is not shown exactly on the map
_ambientvehicleArray = ["Zen_Spawn_Marker_One", 600, 8] call Zen_SpawnAmbientVehicles;

// Each vehicle can now be modified, this example places some weapons and ammo in each one
// You could do could also place things in/around one or two random vehicles (like secret documents or an IED)
{
    _x addWeaponCargo ["arifle_MX_F",2];
    _x addMagazinecargo ["30Rnd_65x39_caseless_mag", 20];
} forEach _ambientvehicleArray;

// Spawn a small camp
// This camp is a set-piece template, letting you add a little ambiance to your mission easily
// It is probably best not to overuse it, as all the camps look very similar
0 = ["Zen_Spawn_Marker_One"] call Zen_SpawnCamp;

// Spawn a convoy and join all the units in the vehicles to the player
{
    (crew _x) join player;
} forEach (["Zen_Spawn_Marker_Two", west] call Zen_SpawnConvoy);

// Spawn a fortification, this is similar the Zen_SpawnCamp
0 = ["Zen_Spawn_Marker_Three", 10] call Zen_SpawnFortification;

// Spawn a vehicle near the fortification
_newPosition = ["Zen_Spawn_Marker_Three", 25, 0] call Zen_ExtendPosition;
_spawnedGroundVehicle = [ _newPosition,"B_APC_Wheeled_01_cannon_F", 45] call Zen_SpawnGroundVehicle;

// Spawn a group inside the fortification
// You can dynamically create a manned defensive position using only this function and Zen_SpawnFortification
_spawnedGroup = ["Zen_Spawn_Marker_Three", ["B_recon_M_F", "B_recon_F"]] call Zen_SpawnGroup;

// Spawn a vehicle, its crew and some passengers separately
// As mentioned above, different spawning functions give you different levels of control
// By combining lower level functions here, you can spawn a Blufor vehicle with an Independent crew
_newPosition = ["Zen_Spawn_Marker_Three", 25, 90] call Zen_ExtendPosition;
_spawnedVehicle = [_newPosition, "B_APC_Wheeled_01_cannon_F"] call Zen_SpawnVehicle;
0 = [ _spawnedVehicle, resistance] call Zen_SpawnVehicleCrew;

// A crew for the vehicle only includes the necessary people (driver, gunner, etc)
// You can now add some passengers with only 2 more functions
_spawnedSquad = [ "Zen_Spawn_Marker_Three", resistance, "Infantry", 4, "Men", "IND_F"] call Zen_SpawnInfantry;
0 = [_spawnedSquad, _spawnedVehicle] call Zen_MoveInVehicle;

// The vehicle is now fully loaded and ready for an insertion, or command by a player
// It will surprise the enemy to see Independent forces getting out of a Blufor APC

// Spawn a garrison in nearby house
// This is another example of a higher level function that automates something for you
// Because you have chosen Zen_SpawnInfantryGarrison instead of Zen_SpawnInfantry, 
// the framework handles detecting the nearest building and placing units there
_spawnedGarrison = ["Zen_Spawn_Marker_Four", west, "Infantry", 4, "Men", "BLU_F"] call Zen_SpawnInfantryGarrison;

// Typical debug logic
// There are a lot of ways that you can test functions beyond just watching your mission
// Here, we can be certain than 4 units will spawn, but if that number was a variable, 
// you might want to make sure that something didn't assign it the wrong number
if (count units _spawnedGarrison != 4) then { player sidechat "Failure in Spawn Garrison" };

/**  This demonstration shows only a few of the possibilities of the spawning functions.  You can use them with precise arguments to get the same behavior every time, or you can allow them to be completely random.  This lets you control what could change in your mission, and even react to events in the mission dynamically by randomly spawning things.  There are no limitations to what you can spawn using framework functions, and you can manipulate the spawned objects in a easier, more organized way in your init with a few commands, then by dealing with init fields in the editor. */
