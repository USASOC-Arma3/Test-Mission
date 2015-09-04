// This file is part of Zenophon's ArmA 3 Co-op Mission Framework
// This file is released under Creative Commons Attribution-NonCommercial-NoDerivatives 4.0 International (CC BY-NC-ND 4.0)
// See Legal.txt

#include "Zen_FrameworkFunctions\Zen_InitHeader.sqf"

// This is an optimization trick, discussed later above the calls to Zen_ConfigGetVehicleClasses
#include "PrimeCfgGetVehicles.sqf"

// Random Combined Arms Battle by Zenophon
// Version = Final 4/22/14
// Tested with ArmA 3 1.16

/**  ArmA is well known for the sheer scale of its maps and combined arms battles.  Few other first person shooters can boast this level of realistic military mayhem.  I will now show you how the framework can quickly and easily generate any massive engagement that you can imagine.  The only limitation is your computer's processing power.  Contrary to the editor, the framework allows you to easily randomize and generate the battle, without the tedium of placing individual units and waypoints.  This demonstration does not include any triggers to declare that one side won, but the framework would also make that easier for you. */

titleText ["Good Luck", "BLACK FADED", 0.2];
enableSaving [false, false];

// Lots of area markers to define spawning and patrol areas
{_x setMarkerAlpha 0;} forEach ["mkBluforHeliSpawn", "mkOpforHeliSpawn", "mkBluforVehSpawn", "mkOpforVehSpawn", "mkAthira", "mkBluforInsertionAPCs", "mkAirspace", "mkGroundBattle"];

if (!isServer) exitWith {};

/**  Even more impressive, you can now directly use the framework's powerful config searching function, Zen_ConfigGetVehicleClasses.  This function is used internally by some spawning functions to provide defaults when no classnames are given.  The strength of this function is not its ability to list classnames, but that it automatically makes your mission use every vehicle available.  This function can get addon/modded vehicles and vehicles added in new ArmA patches or DLC without any change to your mission.  Instead of manually copying and listing the classnames your mission can use, you will allow the framework to read every config entry and find those that match your search terms. */

/**  Since the function's documentation does not tell you exactly what you can enter, this demonstration will show you what keywords to use to get what.  For the first argument, this is the primary type of the vehicle, similar to how it is categorized in the editor.  The main ones are:

air             all flying vehicles
ammo            ammunition boxes and supplies
armored         all armored land vehicles
autonomous      all unmanned vehicles
car             all soft and civilian vehicles
ship            all water vehicles
static          all fixed or mounted weapons
support         vehicles for resupply or battlefield repair

To clarify, this function will also get classnames for soldiers too.  These are the types for different soldiers:

men                standard soldiers
menDiver           divers
menSniper          snipers
menRecon           SOF soldiers

You can also combine multiple types:

_classNames = [["car", "armored"]] call Zen_ConfigGetVehicleClasses;

This is a valid input.  Adding more types expands the list of classnames returned, rather than restricting it.  The value you enter is directly compared to a value in the each vehicle's config.  Thus, you can look at the config files to determine what kinds of vehicles your arguments will return.  The value that the type is compared to is called: vehicleClass.  Note that many mods may have different values than these, for many of the other arguments as well. */

/**  The next argument, the side, is self-explanatory; it can also be civilian.  The third argument is also very important; it specifies to the function exactly what specific kinds of a type to include.  In general, the most useful ones are:

fast mover*         jets
uav*                UAVs
ugv                 UGVs
helicopter*         helicopters
mrap                MRAPs
tank                general armored vehicles
apc                 armored vehicles for carrying and supporting infantry
car                 soft/civilian vehicles
truck               large transport vehicles

* These are localized for your game language by using:
(localize "str_Zen_Jet"), (localize "str_Zen_UAV"), and (localize "str_Zen_Heli"), respectively

Other types are not localized because they are not used internally in the framework.  If you use them in your own scripts, you must make sure that they are correct for the language of your users.  You can also use the string table provided with the framework as a template to add your own localization.

Each of these only apply to a single type; which ones belong to which type should be obvious.  As with type, the subtype is directly compared to the config value: textSingular. */

/**  The fourth argument is the vehicle's faction.  There are only four vanilla factions in ArmA 3: BLU_F, BLU_G_F (FIA), OPF_F, and IND_F.  Thus, faction is not that useful for filtering vehicles, except to separate Blufor infantry from FIA infantry.  The config value this is compared to is called: faction. */

/**  The fifth argument is the vehicle's parent classes.  These are classes that the vehicle inherits properties from; they are listed in the config viewing window at the bottom.  Don't worry if you're not familiar with object-orient programming, all you need to do is enter the names of other classes for this parameter.

/**  The sixth argument is the armament state of the vehicle.  This is good for balancing a mission, such as not allowing a random transport vehicle to kill infantry.  Considering that MRAPs are almost bullet-proof (except for the tires), this could be important in a infantry-focused mission. */

/**  The final argument is the DLC of the vehicle, use "All" for both DLC and vanilla vehicles and "" (empty string) for no DLC vehicles.  The DLC config entry value is only guaranteed for official BI content and should be used for addon vehicles and soldiers only after checking the config value.

/**  There are two drawbacks to using this procedure search system.  Firstly, it takes time; there are hundreds of config entries that must be searched through for each different set of arguments.  To help prevent needless inefficiency, the function saves off the result of every search, pairing it with a composite string of its arguments.  This allows that function to return the value it previously found if those arguments are used again.  This greatly speeds up any repeated use of the function, such as in Zen_SpawnInfantry.  Otherwise, you would have to wait about 1 second every time you called Zen_SpawnInfantry instead of only once. */

/**  To prevent you from having to wait even once for Zen_ConfigGetVehicleClasses to search, you can use the PrimeCfgGetVehicles.sqf file included with this demonstration to call Zen_ConfigGetVehicleClasses with various arguments.  This 'primes' Zen_ConfigGetVehicleClasses, so that it returns a value instantly when you call Zen_SpawnInfantry or other spawning functions.  The calls in that primer script only cover internal uses of Zen_ConfigGetVehicleClasses.  To 'prime' the function or get values without having to wait in your mission, simply use Zen_ConfigGetVehicleClasses before the sleep command.  The extra processing power (higher framerate) during the 'Good Luck' screen make these computations almost instantaneous. */

/**  The second drawback to Zen_ConfigGetVehicleClasses is that config values are subject to change.  Whether you getting vehicles from vanilla ArmA or an addon, the exact values in the config could be changed without notice.  Every time BIS or the author decides to edit the config values, you need to fix every usage of Zen_ConfigGetVehicleClasses (and I need to fix this demonstration and every internal framework use).  All we can do about this is hope that BIS doesn't change config organization and vehicle subtypes.  If you use a vehicle or soldier addon a lot, ask the author to decide on a type, subtype, and faction for each class and stick to it.  It is generally a good idea to test run some Zen_ConfigGetVehicleClasses calls every time a new version arrives, just to make sure the return values are the same (and include any new vehicles). */

// Classnames
_bluforJetClasses = ["air", west, "fast mover"] call Zen_ConfigGetVehicleClasses;
_opforJetClasses = ["air", east, "fast mover"] call Zen_ConfigGetVehicleClasses;
_bluforHeliClasses = ["air", west, "gunship"] call Zen_ConfigGetVehicleClasses;
_opforHeliClasses = ["air", east, "gunship"] call Zen_ConfigGetVehicleClasses;
_bluforVehClasses =  ["armored", west] call Zen_ConfigGetVehicleClasses;
_opforVehClasses =  ["armored", east] call Zen_ConfigGetVehicleClasses;

sleep 1;

// Weather: night time, possibly rainy, high view distance to see the battle
0 = [["overcast", random 1], ["fog", 0], ["date", random 60, 22 + random 5]] spawn Zen_SetWeather;
0 = [4000] call Zen_SetViewDistance;
0 = [player, "recon"] call Zen_GiveLoadoutBlufor;

/**  This mission has six parts: the config searching done above and the labeled section below. */

///////////
// Spawning
///////////

/**  There is still some tedious work necessary to collect all the data of the spawning object.  This is much faster than naming them all in the editor though. */

// Spawned Object Data
_bluforJets = [];
_opforJets = [];
_bluforHelis = [];
_opforHelis = [];
_bluforVehs = [];
_opforVehs = [];
_bluforInf = [];
_opforInf = [];
_bluforInfAthira = [];
_opforInfAthira = [];
_bluforAPCs = [];

/**  Every spawning loop is labeled with the type and does basically the same thing.  Different area markers are used to position units. */

// Blufor Jets
for "_i" from 1 to 2 do {
    _spawnPos = ["mkBluforHeliSpawn"] call Zen_FindGroundPosition;
    _vehicle = [_spawnPos, _bluforJetClasses] call Zen_SpawnAircraft;
    0 = [_bluforJets, _vehicle] call Zen_ArrayAppend;
};

// Opfor Jets
for "_i" from 1 to 2 do {
    _spawnPos = ["mkOpforHeliSpawn"] call Zen_FindGroundPosition;
    _vehicle = [_spawnPos, _opforJetClasses] call Zen_SpawnAircraft;
    0 = [_opforJets, _vehicle] call Zen_ArrayAppend;
};

// Blufor Helicopters
for "_i" from 1 to 3 do {
    _spawnPos = ["mkBluforHeliSpawn"] call Zen_FindGroundPosition;
    _vehicle = [_spawnPos, _bluforHeliClasses] call Zen_SpawnHelicopter;
    0 = [_bluforHelis, _vehicle] call Zen_ArrayAppend;
};

// Opfor Helicopters
for "_i" from 1 to 3 do {
    _spawnPos = ["mkOpforHeliSpawn"] call Zen_FindGroundPosition;
    _vehicle = [_spawnPos, _opforHeliClasses] call Zen_SpawnHelicopter;
    0 = [_opforHelis, _vehicle] call Zen_ArrayAppend;
};

// Blufor Vehicles
for "_i" from 1 to 5 do {
    _spawnPos = ["mkBluforVehSpawn"] call Zen_FindGroundPosition;
    _vehicle = [_spawnPos, _bluforVehClasses] call Zen_SpawnGroundVehicle;
    0 = [_bluforVehs, _vehicle] call Zen_ArrayAppend;
};

// Opfor Vehicles
for "_i" from 1 to 5 do {
    _spawnPos = ["mkOpforVehSpawn"] call Zen_FindGroundPosition;
    _vehicle = [_spawnPos, _opforVehClasses] call Zen_SpawnGroundVehicle;
    0 = [_opforVehs, _vehicle] call Zen_ArrayAppend;
};

// Blufor Infantry
for "_i" from 1 to 3 do {
    _spawnPos = ["mkBluforVehSpawn"] call Zen_FindGroundPosition;
    _group = [_spawnPos, west, "infantry", 8] call Zen_SpawnInfantry;
    0 = [_group, west] call Zen_GiveLoadout;
    0 = [_bluforInf, _group] call Zen_ArrayAppend;
};

// Opfor Infantry
for "_i" from 1 to 3 do {
    _spawnPos = ["mkOpforVehSpawn"] call Zen_FindGroundPosition;
    _group = [_spawnPos, east, "infantry", 8] call Zen_SpawnInfantry;
    0 = [_group, east] call Zen_GiveLoadout;
    0 = [_opforInf, _group] call Zen_ArrayAppend;
};

// Blufor Athira Infantry
for "_i" from 1 to 2 do {
    _spawnPos = ["mkBluforInsertionAPCs"] call Zen_FindGroundPosition;
    _group = [_spawnPos, west, "infantry", 8] call Zen_SpawnInfantry;
    0 = [_group, west] call Zen_GiveLoadout;
    0 = [_bluforInfAthira, _group] call Zen_ArrayAppend;
};

// Opfor Athira Infantry
for "_i" from 1 to 4 do {
    _spawnPos = ["mkAthira"] call Zen_FindGroundPosition;
    _group = [_spawnPos, east, "infantry", 8] call Zen_SpawnInfantry;
    0 = [_group, east] call Zen_GiveLoadout;
    0 = [_opforInfAthira, _group] call Zen_ArrayAppend;
};

// Blufor Insertion APC's
for "_i" from 1 to 2 do {
    _spawnPos = ["mkBluforInsertionAPCs"] call Zen_FindGroundPosition;
    _vehicle = [_spawnPos, "B_APC_Wheeled_01_cannon_F"] call Zen_SpawnGroundVehicle;
    0 = [_bluforAPCs, _vehicle] call Zen_ArrayAppend;
};

// AAA protection
_spawnPos = ["mkBluforInsertionAPCs"] call Zen_FindGroundPosition;
_vehicle = [_spawnPos, "B_APC_Tracked_01_AA_F"] call Zen_SpawnGroundVehicle;

///////////////
// Fire Support
///////////////

/**  A simple use of the framework's fire support system, just to add more chaos to the mission. */

_bluforArty = ["R_230mm_HE", 25, 3, 1, 5, 450, 25] call Zen_CreateFireSupport;
0 = ["mkAthira", _bluforArty] spawn Zen_InvokeFireSupport;

///////////
// Tracking
///////////

/**  To help you see what is going on. */

0 = [[_bluforJets, _opforJets, _bluforHelis, _opforHelis, _bluforVehs, _opforVehs]] call Zen_TrackVehicles;
0 = [[_bluforInf, _opforInf, _bluforInfAthira, _opforInfAthira], "none"] call Zen_TrackGroups;

/////////
// Patrol
/////////

/**  This is where the framework really helps you.  Using the editor, you would have to create several waypoints that cycle back on each other for every single vehicle and infantry group.  Even if the waypoints where random within a radius, they would still be fixed points once the mission began.  No one wants to click hundreds of times to get all their unit and vehicles patrolling the combat zone.  The framework does even better than that using only four lines.  Each list of vehicles or infantry will patrol the given area using constantly procedurally generated random waypoints forever.  The area marker can be any shape or size, allowing patrols to fit in any area.  You also have the option of changing who patrols where by managing the threads (see Zen_MultiThreadManagement.sqf demonstration). */

0 = [[_bluforJets, _opforJets, _bluforHelis, _opforHelis], "mkAirspace"] spawn Zen_OrderAircraftPatrol;
0 = [[_bluforVehs, _opforVehs], "mkGroundBattle"] spawn Zen_OrderVehiclePatrol;
0 = [[_bluforInf, _opforInf], "mkGroundBattle", [], 0, "full"] spawn Zen_OrderInfantryPatrol;
_h_patrolAthira = [_opforInfAthira, "mkAthira"] spawn Zen_OrderInfantryPatrol;

////////////
// Insertion
////////////

/**  This is a more advanced insertion, where the infantry groups and their vehicle patrol an area after the infantry dismount.  This emulates real mechanized infantry tactics. */

// The insertion threads
_h_insertions = [];

// Insertions
{
    // Standard code for an insertion using a randomized location, the infantry were spawned above
    _insertionPos = ["mkAthira", 220, 0, 1, [2, 0], [150, 180]] call Zen_FindGroundPosition;
    0 = [_x, (_bluforAPCs select _forEachIndex)] call Zen_MoveInVehicle;
    _h_thread = [(_bluforAPCs select _forEachIndex), _insertionPos, _x] spawn Zen_OrderInsertion;

    // This keeps track of the insertion function threads, so that we can determine when the infantry have exited
    0 = [_h_insertions, _h_thread] call Zen_ArrayAppend;
} forEach _bluforInfAthira;

// Wait for the insertions to finish, this will work for an array of any number of threads
waitUntil {
    sleep 10;
    (({!(scriptDone _x)} count _h_insertions) == 0)
};

// Update infantry patrols in Athira, adding in the blufor infantry, and having their APC's patrol with them
// Once again, updating patrol threads is covered in more detail in the Zen_MultiThreadManagement.sqf demonstration
terminate _h_patrolAthira;
0 = [[_bluforInfAthira, _opforInfAthira], "mkAthira", [], 0, "normal"] spawn Zen_OrderInfantryPatrol;
0 = [_bluforAPCs, "mkAthira", [], 0, "limited"] spawn Zen_OrderVehiclePatrol;
