// This file is part of Zenophon's ArmA 3 Co-op Mission Framework
// This file is released under Creative Commons Attribution-NonCommercial-NoDerivatives 4.0 International (CC BY-NC-ND 4.0)
// See Legal.txt

#include "Zen_FrameworkFunctions\Zen_InitHeader.sqf"

// Infantry Showcase Remake Demonstration by Zenophon
// Version = Final 3/14/14
// Tested with ArmA 3 1.12

/**  You may have noticed that I have made a big deal about how the framework is better than the editor.  If you don't like generalizations about the benefits of functions and the framework API or you just can't see how to transition from the editor to using the framework, this demonstration will provide a lot of these details.  The goal of this demonstration is to provide a before/after picture of a mission originally created in the editor and then recreated using the framework.  I will prove that not only can the framework do anything the editor can with ease, it will also allow many more features to be added with almost no extra effort. */

/**  I would be pointless to remake a random mission, so I have chosen a mission that almost everyone should be familiar with: BIS's Infantry Showcase.  You can view BIS's mission in the editor if you open the right .pbo and find it, but just having played it is enough to understand this demonstration (I didn't open it).  As you read through the demonstration, look at how the events in the mission are done in the framework.  Aside from the dialog (which I put my own spin on), the framework is able to handle almost everything with a few function calls. */

/**  Regardless of the details of BIS's work, you can be sure that it took them a lot longer to make the mission in the editor.  Using the framework, I created the init you see here in about 7 hours (that includes testing the mission numerous times).  This seems unfair, as I created the framework and know how to use it, but consider if any level of skill in the editor could produce a similar mission in the same time.  I know that new users of the framework will face difficulties using the framework API.  I can only assure you that once you learn just dozen functions at a basic level, your missions will be much easier to create. */

// Typical use of preprocessor macro, aka manifest constant.  Using this means you don't have to keep track of a variable later.
#define AI_SKILL "infantry"

// The text here can say anything you want, use \n for newline, \t for tab
titleText ["Stratis\nBlufor UAV over Girna", "BLACK FADED", 0.175];
enableSaving [false, false];

/**  I have not recreated the infantry showcase word for word and action for action.  That would be rather boring.  Instead, having played it several times in the last year, I have kept the basic mission the same while changing lots of little things. */ 
player createDiaryRecord ["Diary", ["Execution", "Exit the insertion vehicle, callsign Wagon, at the marked point on the map.<br/><br/>Rendezvous with your squad leader in the woods to the north<br/><br/>Assault and secure Girna and the valley to the east.<br/><br/>Assist and protect Bravo team.<br/><br/>Establish a defense of Girna and the surrounding area."]];
player createDiaryRecord ["Diary", ["Mission", "Corporal, you will lead a three-man team to rendezvous with your Sergeant and more men in the woods west of the town.  Once your entire team, callsign Alpha, is assembled, you will move through the woods and valley east of Girna to assault the town.  Expect Opfor patrols on the hill to your north as well as some infantry already in the town.  You must expedite the assault before the Opfor surround and annihilate Bravo.  Once you have linked up with Bravo, coordinate with Charlie to set up a firm defense of the town and valley."]];
player createDiaryRecord ["Diary", ["Situation", "Following a major assault on the south of Stratis, Blufor forces have pushed north and captured several key positions, including Air Station Mike-26.  Unfortunately, the Opfor have regained the initiated and are attacking our positions from Camp Tempest.  In an attempt to flank our main position, they are moving south along the west coast of Stratis.  HQ has decided to stop them at the small hamlet of Girna, before they can threaten our supply lines from the coast to Mike-26.<br/><br/>The first squad sent to defend Girna, callsign Bravo, took heavy casualties in the first assault.  A recon team assisting in the defense, callsign Charlie, reports that they are trapped in the town by a second Opfor attack.  It is only a matter of time before the Opfor clear the town building by building, and Charlie is too outgunned to fight."]];

/**  Tasks, including child tasks, are simple to create both before and during the mission.  Zen_InvokeTaskBriefing is a special variant of Zen_InvokeTask meant to function only before the mission begins.  Due to engine limitations, it requires that provide a literal name for the task and does not allow it to be set current.  However, a task created in this way is exactly the same as a task created after the mission starts.  This is not a different kind of task, it just must be created and synch'd differently.  Once 'sleep 1;' has executed, you can use any Task System function with the literal name as an argument */
0 = [X, "Defeat the Opfor counter-attack on the town of Girna.  Opfor infantry are attacking from the north, and have pinned down Bravo squad in the town.", "Retake Girna", "Task_SecureGirna", "mkGirnaIcon"] call Zen_InvokeTaskBriefing;
0 = [X, "Bravo squad are trapped in Girna.  Charlie is in the woods to the south, providing overwatch.  Your team needs to get to Girna and rescue Bravo.", "Save Bravo", "Task_SaveBravo", "mkBravo", "Task_SecureGirna"] call Zen_InvokeTaskBriefing;

// Area markers provide easy randomization, but must be hidden from players
{_x setMarkerAlpha 0;} forEach ["mkSpotters", "mkHill", "mkValley", "mkGirna"];

if (!isServer) exitWith {};
sleep 1;

// Random weather is not possible in the editor, add random time to that and you can let your mission's atmosphere change drastically
// The difference between a sunny evening and a foggy morning makes a mission play very differently
// Here the weather remains cloudy, with no fog, in the morning
// For those not fluent with the 'random' command, you could also use Zen_FindInRange to get the random values
_h_weather = [["overcast", random 0.7, random 0.5, 60*60], ["fog", random 0.1], ["date", random 60, (9 + random 4)]] spawn Zen_SetWeather;

// Zen_SetWeather must change the time, or BIS_fnc_establishingShot will print the wrong time of day
// This is fairly minor, and only applies when you are using a random time and are a perfectionist
// Because I run BIS_fnc_establishingShot after the mission starts, the title text is left in above
waitUntil {
    sleep 0.2;
    scriptDone _h_weather;
};

// Just like the BIS version, this mission features a UAV opening scene
// The framework is entirely compatible with other functions and features that you want to add
0 = [(getMarkerPos "mkGirna"), "Girna"] spawn BIS_fnc_establishingShot;

/**  The framework allows you to quickly do things that would be a significant obstacle without it.  You should never waste time getting something like a helicopter insertion to work, and you should be free to use small pieces like that with just a few lines.  You can make use of this to improve your mission with minimal extra work, as the APC insertion below shows. */

// Spawn a blufor APC, using X (the player) directly will spawn the vehicle next to him, not on top of him
_b_apc_insert = [X, "B_APC_Wheeled_01_cannon_F", 270] call Zen_SpawnGroundVehicle;

// Move X and the 2 AI into the vehicle
0 = [(group X), _b_apc_insert] call Zen_MoveInVehicle;

// Give random loadouts and skill
0 = [(group X)] call Zen_GiveLoadoutBlufor;
0 = [(group X), AI_SKILL] call Zen_SetAISkill;

// To improve the mission, the player must meet his squad leader in the valley
// This provides a slight randomization of the position, so the rendezvous is different each time
_b_leaderPos = ["mkBluforPoint"] call Zen_FindGroundPosition;
_leadGroup = [_b_leaderPos, west, AI_SKILL, 4] call Zen_SpawnInfantry;
0 = [_leadGroup] call Zen_GiveLoadoutBlufor;

// This is just to keep the original squad leader alive and in command for the entire mission
// I could allow him to die, but the mission is more fun if the player has friendly units to fight alongside
// This reduces lone-wolf type of missions, but is only recommended for singleplayer
(leader _leadGroup) setRank "SERGEANT";
(leader _leadGroup) allowDamage false;

// For better looking dialog later
(group driver _b_apc_insert) setGroupID ["Wagon"];
(group X) setGroupID ["Alpha-2"];
_leadGroup setGroupID ["Alpha-1"];

// This is the easiest way to detect that the opening scene has ended
waitUntil {
    sleep 0.2;
    !(BIS_fnc_establishingShot_playing);
};

// Now order the player's vehicle to move, this will be audible for the player
_h_insert = [_b_apc_insert, "mkInsert", (group X), "full"] spawn Zen_OrderInsertion;

// It is the mission-maker's decision about how detailed tasks should be
// You could assign a separate task for almost everything, or only provide a few overall mission goals
// Using a task makes it easier to use Trigger Functions to detect when the player has advanced
// You always want to avoid a situation where it is unclear what to do next, that is not very fun for players
_reachSarge = [X, "Your squad leader and the rest of your team are in the woods north of the insertion point.  Rendezvous with them and proceed to the objective.", "Regroup", "mkBluforPoint", true] call Zen_InvokeTask;

// A simple distance check to complete the task
// In general, you don't want to make trigger conditions too complicated, as a simple check usually works
// Triggers in the editor evaluate their condition every frame, Zen_TriggerAreNear checks every 5 seconds
// The increase in performance is worth a slight delay, and you could always change '20' to account for that delay
0 = [X, _reachSarge, "succeeded", _leadGroup, "one", 20] spawn Zen_TriggerAreNear;

// This loop continues when the APC has stopped, we can't check if Zen_OrderInsertion is done, as it only stops executing when the passengers get out
waitUntil {
    sleep 2;
    (([X, "mkInsert"] call Zen_Find2dDistance) < 10)
};

// This dialog also helps the players know what is going on
// It adds immersion, while gently urging players to do what you want
(driver _b_apc_insert) sideChat "Alright, this is as far as we go, good luck out there, Corporal.";
sleep 6;
X groupChat "Go, go, go!  The faster we link up with the Sarge, the faster we get to Bravo.";
sleep 10;
X sideChat "Alpha-1, Alpha-2 Actual, we are inbound on your position, ETA 2 mikes, over.";
sleep 7;
(leader _leadGroup) sideChat "Alpha-2, Alpha-1, roger, out.";

// The mission continues when the player meets his sergeant
waitUntil {
    sleep 5;
    ([_reachSarge] call Zen_AreTasksComplete)
};

// The framework does not manage advancing the mission for you; you need to update tasks accordingly unless you use a trigger
// Setting a task current is mostly fluff, but it never hurts to take advantage of the fancy task notifications to make your mission look polished
// This is also the first use of a task name literal, this task was created during the briefing, so we can simply use its name
// The regular Zen_InvokeTask also allows you to provide a name for the task, but generates one for you by default
0 = ["Task_SecureGirna"] call Zen_SetTaskCurrent;

// Here we are copying BIS's version, where the pointman is picked off by the Opfor, by
// creating a new group with spawn infantry and joining its leader (the pointman) to the main group
// 'doStop' is important, so he does not run back to the group
// The position of the marker is exact, you could make it random in an area marker
_alphaPoint = ["mkAlphaPoint", west, AI_SKILL, 1] call Zen_SpawnInfantry;
_pointMan = leader _alphaPoint;
(units _alphaPoint) joinSilent _leadGroup;
doStop _pointMan;

// Join the player and the 2 AI to the main group, then change the group names to keep the dialog correct
// The dialog here is just simple chat commands, but you can use sideChat, groupChat, and globalChat to show different types of communication
// The dialog itself follows this pattern, where side chats are formal radio messages, and group chats are akin to shouting at your teammates
(units group X) join _leadGroup;
_leadGroup setGroupID ["Alpha"];
// Suggestion for dialog: Give AI units names, so that the text is clearer and players are not confused
// You can called the pointman anything you want, giving a name makes the characters feel more human
(leader _leadGroup) groupChat "Good to see you here Corporal, Edwards is on point watching the valley.";
sleep 7;
(leader _leadGroup) groupChat "We will move up to him, then move through the woods on the south of the valley.  That will put us in a better position to deal with Opfor reinforcements from the north.";

// We will control where the main group goes for the whole mission using the 'move' command
// No triggers and waypoints required, so you can see when everything happens
// The entire init is a timeline of your mission, if you add some comments when waiting to advance, you can see at a glance how the mission will proceed
// Technically, 'move' creates a real waypoint, but you don't have to worry about its properties or which waypoint is current
sleep 13;
_leadGroup move (["mkAlphaPoint", 5 + random 5, 245 + random 30] call Zen_ExtendPosition);
_leadGroup setSpeedMode "normal";
sleep 2;

// More dialog, this mission contains over 40 lines of dialog, and 40 sleep commands to time them correctly
(leader _leadGroup) groupChat "Edwards, sitrep, over.";
sleep 4;
_pointMan groupChat "Sarge, multiple hostiles moving into the valley.  Eyes on...";
sleep 7;
_pointMan setDamage 1;
(leader _leadGroup) groupChat "Edwards, report, over.";
sleep 6;
(leader _leadGroup) groupChat "Private Edwards, status, over.";
sleep 5;
(leader _leadGroup) groupChat "Man down, change of plans, move to secure Edwards position.";

// With many AI in the mission, you must consider how AI in the player's group will behave if the player is not the leader
// This command will make the AI more aggressive
_leadGroup setCombatMode "red";

// Note that this is the first time spawning Opfor in the mission, there have been no enemies up until this point
// This familiar block of code spawns the Opfor team that killed the pointman
// It then gives them loadouts and orders them to patrol in sight of the pointman
_opforSpawnPos = ["mkValley"] call Zen_FindGroundPosition;
_opforPatrol = [_opforSpawnPos, east, AI_SKILL, [3, 4]] call Zen_SpawnInfantry;
0 = [_opforPatrol] call Zen_GiveLoadoutOpfor;
0 = [_opforPatrol, "mkValley"] spawn Zen_OrderInfantryPatrol;

// Another intermediate task created on the fly, if you have never played the BIS version, you would want to know how to react to the pointman's death
// Tasks also clarify details in writing that players can read any time, sometimes dialog is missed for some reason
_clearValley = [X, "Opfor patrols east of Girna have taken out your point man.  Move to his position and secure the area.", "Clear the Valley", "mkValley", true] call Zen_InvokeTask;

// Another simple trigger, using Zen_TriggerAreDead is preferable to Zen_TriggerAreaClear here, it is simpler and works the same way
_h_destroy = [_opforPatrol, _clearValley, "succeeded"] spawn Zen_TriggerAreDead;

// Now that some combat can occur, we can use Zen_MultiplyDamage
// There have been a lot of complaints about the damage model in ArmA, and BIS has made some progress
// However, some people may prefer more lethal combat (or less lethal), so this function is provided
// See Zen_MultiplyDamage's documentation for a full explanation
// The advantage to a scripting solution is that players do not need any mods to run this mission
// and you can change the multiplier during the mission
0 = [allUnits, true] call Zen_MultiplyDamage;

// Waiting for functions to be done is standard fair in a framework mission
// It seems like a strange construct to be used so often, but recall that the work is being done for you elsewhere
// Every function that can be spawned tells you when it will stop executing, so you can use it as a cue to advance your mission
waitUntil {
    sleep 5;
    (scriptDone _h_destroy)
};

// In the BIS version, the medic treats the pointman with a fancy animation
// In my version, I am lazy and just tell the player to do it
// Some players will role play along and look at the body
// Even if the player does nothing, the mission advances fine
sleep 5;
(leader _leadGroup) groupChat "Valley looks clear, but there will be more Opfor in the town.  Corporal, check on Edwards.";
sleep 7;

// Now the real combat starts, adding in 9-12 Opfor to attack the valley, just as in the BIS version
// This pattern of position, spawn, loadout, append is extremely common
// You can create a very flexible spawning function quickly by just changing the number of groups and the units per group
_opforPatrolArray = [];
for "_i" from 0 to 2 do {
    _opforSpawnPos = ["mkHill"] call Zen_FindGroundPosition;
    _opforPatrol = [_opforSpawnPos, east, AI_SKILL, [3,4]] call Zen_SpawnInfantry;
    0 = [_opforPatrol] call Zen_GiveLoadoutOpfor;
    0 = [_opforPatrolArray, _opforPatrol] call Zen_ArrayAppend;
};

0 = [_opforPatrolArray, "mkValley", [], 0, "full"] spawn Zen_OrderInfantryPatrol;

// Each time new units are spawned, you must apply Zen_MultiplyDamage to then
// These arguments make that simpler by reapplying the effect to all units in the game
// By removing previous event handler, there is no decrease in performance.
0 = [allUnits, true] call Zen_MultiplyDamage;

// More dialog, the player is probably distracted right now with shooting, but there's nothing we can do about that
sleep 13;
X groupChat "It's no use, he's gone, Sarge.";
sleep 7;
X groupChat "Sarge, contact west, half a dozen Opfor moving into the valley!";
(leader _leadGroup) reveal [(leader _opforPatrol), 3];
sleep 7;
(leader _leadGroup) groupChat "Engage the Opfor, suppressive fire on that hill!";
sleep 7;
(leader _leadGroup) sideChat "HQ, Alpha Actual, we are outnumbered and pinned down at the east end of the valley.  Request support to break through to Bravo, over.";
sleep 11;
[west, "base"] sideChat "Alpha, HQ, no support available, if you can push through the valley, Charlie will assist in the assault, over.";
sleep 10;
[west, "base"] sideChat "Charlie, HQ, maintain overwatch on Girna, hold your fire until Alpha reaches Girna, then give them support, out.";
sleep 9;

// Spawn Charlie, but don't allow them to enter combat yet
_charliePos = ["mkCharlie"] call Zen_FindGroundPosition;
_charlieGroup = [_charliePos, west, "SOF", 2] call Zen_SpawnInfantry;
0 = [_charlieGroup, "recon"] call Zen_GiveLoadoutBlufor;

// This sets up Charlie for dialog and attacking the town, 'blue' mode means hold fire
(leader _charlieGroup) allowDamage false;
_charlieGroup setGroupId ["Charlie"];
_charlieGroup setBehaviour "combat";
_charlieGroup setCombatMode "blue";

// This is the easiest way to make units go unnoticed
// Combined with hold fire, Charlie now plays the role of spotter very well
{
    _x setCaptive true;
} forEach (units _charlieGroup);

(leader _charlieGroup) sideChat "Alpha, Charlie Actual, we have eyes on the town, holding our position, out.";
sleep 10;
(leader _leadGroup) groupChat "Listen up, if we rendezvous with Charlie, the Opfor will surround our position.";
sleep 8;
(leader _leadGroup) groupChat "We are going onto the north ridge instead, keep watch for Opfor to the north, but focus your fire into the valley and town.";
sleep 3;

// The player group continues towards the town
// Another random position makes the path slightly different each time, but the player is free to go were they want
_hillPos = ["mkSpotters"] call Zen_FindGroundPosition;
_leadGroup move _hillPos;
_leadGroup setSpeedMode "normal";

// Now the Opfor in the town itself are created
// There was no need to create them earlier, as the player could not have seen them
// Once the player group is on the hill, they will begin attacking the patrols in the town as well
_opforPatrolArray = [];
for "_i" from 1 to 3 do {
    _opforSpawnPos = ["mkGirna"] call Zen_FindGroundPosition;
    _opforPatrol = [_opforSpawnPos, east, AI_SKILL, [2, 3]] call Zen_SpawnInfantry;
    0 = [_opforPatrol] call Zen_GiveLoadoutOpfor;
    0 = [_opforPatrolArray, _opforPatrol] call Zen_ArrayAppend;
};

_h_patrolGirna = [_opforPatrolArray, "mkGirna"] spawn Zen_OrderInfantryPatrol;
0 = [allUnits, true] call Zen_MultiplyDamage;

// This waits for the group to arrive at their destination
waitUntil {
    sleep 5;
    (unitReady (leader _leadGroup));
};

// The group attacks Girna itself, you can reuse variable names, even if they don't make sense
// This reduces mistakes of using the wrong variable, which would be hard to find if it was also a position
_hillPos = ["mkGirna"] call Zen_FindGroundPosition;
_leadGroup move _hillPos;
_leadGroup setSpeedMode "normal";

(leader _charlieGroup) sideChat "Alpha, Charlie Actual, have eyes on your position.  We are assaulting Girna in 1 mike, over.";
sleep 6;
X sideChat "Charlie, Alpha, roger that, moving to hit Girna from the north, out.";
sleep 8;

// Charlie is now engaging the enemy
_charlieGroup setCombatMode "red";
{
    _x setCaptive false;
} forEach (units _charlieGroup);

// This is a useful trick, there is no need to make Charlie patrol separately from the Opfor in the town
// Zen_OrderInfantryPatrol can handle groups from any side
// To increase performance, try to run as few threads as possible
terminate _h_patrolGirna;
_h_patrolGirna = [[_opforPatrolArray, _charlieGroup], "mkGirna"] spawn Zen_OrderInfantryPatrol;

// These functions also use the literal task names
// You can name all of your tasks if you prefer to use strings instead of variables
0 = ["Task_SecureGirna"] call Zen_SetTaskCurrent;
0 = [east, west, "Task_SecureGirna", "succeeded", "mkGirna"] spawn Zen_TriggerAreaSecure;

// Now we will spawn Bravo, they were not needed before
// Another advantage of the framework it that it lets you know exactly what exists in your mission at any time
_bravoPos = ["mkGirna"] call Zen_FindGroundPosition;
_bravoGroup = [_bravoPos, west, AI_SKILL, [2,3]] call Zen_SpawnInfantryGarrison;

// Protect Bravo from attack
{
    _x disableAI "MOVE";
    _x setCaptive true;
} forEach (units _bravoGroup);

// Another loop to wait for the trigger function
waitUntil {
    sleep 5;
    (["Task_SecureGirna"] call Zen_AreTasksComplete)
};

// We did not give the save Bravo task to Zen_TriggerAreaSecure, so we need to update it manually
// You could have just listed both, but this is included as an example
// Using Zen_UpdateTask to succeed a task is the manual approach; a trigger just executes this code for you
0 = ["Task_SaveBravo", "succeeded"] call Zen_UpdateTask;

// We want the player out of Girna, you will see why soon
sleep 5;
X groupChat "Looks all clear, Sergeant.";
sleep 7;
(leader _leadGroup) groupChat "Good work, rendezvous outside Girna, near the chapel on the hill.";
sleep 9;
_leadGroup move (getMarkerPos "mkRV");
_leadGroup setSpeedMode "normal";
(leader _leadGroup) sideChat "HQ, Alpha Actual, Girna is clear, request extraction for Bravo and their wounded, over.";
sleep 7;
[west, "base"] sideChat "Wagon, HQ, move into Girna along the road from the south to extract Bravo team, over.";
sleep 7;
(driver _b_apc_insert) sideChat "HQ, Wagon, roger, moving now, out.";

{
    _x setCaptive false;
    _x enableAI "MOVE";
} forEach (units _bravoGroup);

sleep 1;
(leader _bravoGroup) move (getMarkerPos "mkGirnaIcon");

// If you thought I made a mistake and forgot to garbage collect the APC, I did not
// The same APC is now used to extract Bravo team
_h_extract = [_b_apc_insert, ["mkExtractBravo", "mkInsert"], _bravoGroup] spawn Zen_OrderExtraction;

// This task is expected, based upon reading the briefing, but I create it now to prevent cluttering the task list earlier
_defendGirna = [X, "The Opfor could attack again at any moment, you must prepare a defense.", "Defend Girna", 0, true] call Zen_InvokeTask;

// Bravo are now on their way out safely
waitUntil {
    sleep 5;
    ([_bravoGroup] call Zen_AreInVehicle)
};

// Get Charlie out of Girna, they are the last group the is being managed by Zen_OrderInfantryPatrol (all the others are dead)
terminate _h_patrolGirna;
[west, "base"] sideChat "Charlie, HQ, you have been retasked to patrol near Camp Maxwell.  Recon in force from Girna to Maxwell, we can't let another Opfor counter-attack surprise us, over.";
_charlieGroup move (getMarkerPos "mkMaxwell");
_charlieGroup setBehaviour "aware";
_charlieGroup setSpeedMode "full";
sleep 10;
(leader _charlieGroup) sideChat "HQ, Charlie Actual, roger, Oscar Mike, out.";

// Just as in the BIS version, mortar fire!
_mortars = ["r_80mm_he", 2, 10, 5, 10, 80, 5] call Zen_CreateFireSupport;
0 = ["mkGirna", _mortars] spawn Zen_InvokeFireSupport;

sleep 3;
(leader _leadGroup) groupChat "We don't have much time before the Opfor come back.  Holding this hill will cut them off from directly attacking the town.";
sleep 10;
X groupChat "We still need to hold the valley, Charlie can warn us of incoming Opfor.";
sleep 15;
[west, "base"] sideChat "Alpha, HQ, Opfor mortars are firing on Girna, get out of there now!";
sleep 8;
[west, "base"] sideChat "Alpha, HQ, the Opfor must have spotters on the hill.  We have lost contact with Charlie.  Find an eliminate those spotters, out.";
sleep 20;
_eliminateSpotters = [X, "Eliminate the Opfor spotters on the hill.", "Eliminate Spotters", "mkSpotters", true] call Zen_InvokeTask;
sleep 2;

// Create the spotters, this is also done on-the-fly in the BIS version, you can watch them spawn if you know where to look
// This version prevents that by spawning them immediately and slightly out of sight from the chapel
// Both Charlie and these spotter start in a slightly random position, to prevent the monotony of seeing them in the same place every time
_opforSpottersPos = ["mkSpotters"] call Zen_FindGroundPosition;
_opforSpotters = [_opforSpottersPos, east, AI_SKILL, 2] call Zen_SpawnInfantry;
0 = [_opforSpotters] call Zen_GiveLoadoutOpfor;

_h_spotters = [_opforSpotters, _eliminateSpotters, "succeeded"] spawn Zen_TriggerAreDead;

sleep 5;

// Don't forget to keep applying Zen_MultiplyDamage throughout your mission, you don't want some units to be unfairly tough
0 = [allUnits, true] call Zen_MultiplyDamage;

// More dialog, a long-winded version of forcing the player group to retreat
(leader _leadGroup) sideChat "HQ, Alpha Actual, Opfor mortar fire is all over Girna, and reinforcements could attack at any minute.  Request infantry support or we will be forced to retreat, over.";
sleep 10;
[west, "base"] sideChat "Alpha, HQ, wait one, a UAV is about to recon your AO, over.";
sleep 20;
[west, "base"] sideChat "Alpha, HQ, Opfor are preparing helicopters and attack boats at Camp Tempest.  Wagon has already diverted to Mike-26.  Orders are to retreat on foot east from Girna, over.";
sleep 15;
(leader _leadGroup) sideChat "HQ, Alpha Actual, acknowledge, out.";
sleep 6;
(leader _leadGroup) groupChat "Corporal, take out those spotters if you can, then link up at Hill 144 southeast of Girna, out.";
sleep 5;

// Hopefully they don't walk into mortar fire
_leadGroup move (getMarkerPos "mkH144");
_leadGroup setSpeedMode "full";
0 = [_defendGirna, "canceled"] call Zen_UpdateTask;

// Don't end the mission until the player kills the spotters
waitUntil {
    sleep 2;
    (scriptDone _h_spotters)
};

sleep 5;
X groupChat "Sergeant, spotters eliminated, Oscar Mike to the RV now, out.";

// This assumes that the player is running for the hills after killing the spotters
// The threats mentioned in the dialog don't exist, so there is no danger
// No matter what the player does, they have completed the mission at this point
_retreat = [X, "Retreat to the southeast with your squad.", "Retreat", 0, true] call Zen_InvokeTask;
sleep 30;
0 = [_retreat, "succeeded"] call Zen_UpdateTask;

// One of the few BIS functions I can truly recommend, this presents a nice screen upon mission end and allows for alternate endings
// See the description.ext file for the text that BIS_fnc_EndMission uses
sleep 5;
0 = "End" call BIS_fnc_EndMission;

/** 460 lines later, this remake of the infantry showcase is complete.  This includes about 85 lines for dialog, 140 lines of comments, and 80 blank lines.  The mission itself is about 160 lines and plays for about 15-20 minutes.  One of the strengths of the framework's API in mission design is is that the mission creates everything as it needs to.  Using the framework, you create your mission in its logical order, so that it is organized chronologically (and functionally if you choose to use separate your code into functions).

/**  In the editor, you are forced to place and set up everything from the start.  For example, if you wanted create a trigger to clear Girna, you need to put down the correct triggers and modules in the editor, then synch them correctly.  You now have to place units in Girna, or the trigger would complete immediately.  All this now has a performance impact and could interfere with other parts of the mission in some way (probably not in this mission, but in general). */

/**  When you use the framework, the mission starts with the potential of an objective in Girna, but you are not forced to have one there.  You could make a mission where you decide where the next objective will be randomly, or based upon some event.  All you place in the editor are a few markers that allow you to implement anything using the framework.  If you decided to change the Opfor to Indfor, you only need to change a few Zen_SpawnInfantry lines (a find/replace is perfect for this).  In the editor, you would need to delete and recreate every single Opfor unit, keeping all their properties the same.  The framework allows you to do 1/100 of the work for the same result. */

/**  Finally, a mission of this kind cannot demonstration the true power of the framework.  The usage of framework functions can be altered and organized any way that you can imagine, to create a single mission that will play as though it is a different mission every time.  That mission can then be altered to provide another set of infinite possibilities.  The ability to procedurally generate a mission using the framework API puts you, as user of the framework, at a higher level of efficiency, quality, and possibility than anyone using the editor. */
