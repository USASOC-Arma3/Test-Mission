// This file is part of Zenophon's ArmA 3 Co-op Mission Framework
// This file is released under Creative Commons Attribution-NonCommercial-NoDerivatives 4.0 International (CC BY-NC-ND 4.0)
// See Legal.txt

#include "Zen_FrameworkFunctions\Zen_InitHeader.sqf"

// Demonstration of HC by Zenophon
// Version = Final 3/10/15
// Tested with ArmA 3 1.40

/**  A headless client is tool used in mission-making to improve the performance of a dedicated server.  It is called headless because no graphics or sound is output to it, and no input is accepted from it.  The HC uses a separate process (running .exe) to handle AI (or really anything you want) in the mission.  This alleviates a caveat in ArmA 3's engine: a lack of modern concurrent processing for AI.  To dispel misconceptions, the engine does use multiple threads; I am referring to concurrent problem solving, in which a single problem or task (like AI) is divided up to many different threads (threads that belong to one process).

To make better use of modern CPU's, which can operate on 4, 8, or even 16 logical threads (here threads refers to literal hardware activity and fundamental BIOS operations) very quickly (3 to 5 trillion simple operations per second per thread), we start another .exe (what Windows calls a process) that will contain more threads.  Simply put, we want to increase the number of software AI threads that the CPU hardware threads can process (ideally, so no CPU cores go idle). */

titleText ["Good Luck", "BLACK FADED", 0.2];
enableSaving [false, false];

/**  Although there are many resources on using HC's, few of them are written from the perspective using only SQF code to create a mission.  Most try to compromise with the editor when it comes to using the HC.  As with everything in my framework, this HC guide will show you it is much easier to integrate a HC into your mission if it's already all in SQF code.

As a general external resource, you can look at this guide, but I'm not going to follow it exactly:
https://community.bistudio.com/wiki/Arma_3_Headless_Client
*/

/**  Having a working dedicated server is necessary to use a HC, and this demonstration assumes you can setup a dedicated server on your computer.  Renting an external server is unnecessary for testing this demonstration.  I will only discuss the particulars of dedicated servers that apply directly to using an HC.  There are slightly different ways to setup a server, so I will say what works for me.  Also note, I'm only running a LAN server, as I only need to connect from my own computer.

First, you must configure your dedicated server and HC.  In server.cfg add this code:
// define allowed HC machine IP's
// 127.0.0.1 is a special IP address pointing to the local host (your machine)
headlessClients[]={127.0.0.1};

I use .bat files for the server and HC; they are located in the install directory.  There is no issue (technical or legal) with running a server, HC, and regular client at once on the same machine and steam account.
Here we have ArmA3HC.bat:
@echo off
START arma3.exe -noSplash -noPause -noBenchmark -client -port=2302 -cpuCount=8 -exThreads=7 -maxMem=4092 -maxVram=2048 -localhost=127.0.0.1 -connect=127.0.0.1 -nosound -profiles=HC -name=HC
exit

And here we have ArmA3Server.bat:
@echo off
START arma3server.exe -cpuCount=8 -exThreads=7 -maxMem=4092 -maxVram=2047 -port=2302 -config=Server.cfg -cfg=Arma3.cfg -name=Server -profiles=Server -world=empty -noBenchmark -noPause -noSplash -showScriptErrors
exit

This concludes the setup of the server.  If you have everything else right, you can now run missions that use a HC.
*/

/**  The last thing before getting to the mission code is a very short setup in the editor.  You need to put a HC logic object in the mission.  Basically, it goes like:
Place a player unit (I named him X)
Place a playable HC logic (named HC), (that's Game Logic >> Virtual Entities >> Headless Client)

Nothing else is needed in the editor.  In the old days, the HC object would have been a person (e.g. a civilian on a small island).  However, BIS now provides a HC logic that is integrated more smoothly in the game engine.
*/

// Now we begin with the mission itself
// This function is quite straightforward
// You will see spawning code like this many more times if you keep using the framework
F_SpawnOpfor = {
    private ["_center", "_groupsCount", "_range", "_groupsArray", "_spawnPos", "_group"];
    diag_log ("F_SpawnOpfor called with " + str _this + " at " + str time);

    _center = [(_this select 0)] call Zen_ConvertToPosition;
    _groupsCount = _this select 1;
    _range = _this select 2;

    _groupsArray = [];
    for "_i" from 1 to _groupsCount do {
        _spawnPos = [_center, [1, _range]] call Zen_FindGroundPosition;
        _group = [_spawnPos, east, "infantry", [6, 8]] call Zen_SpawnInfantry;
        _groupsArray pushBack _group;
    };

    0 = [_groupsArray] call Zen_GiveLoadoutOpfor;
    0 = [_groupsArray, _center, [1, _range]] spawn Zen_OrderInfantryPatrol;

    if (true) exitWith {};
};

if (!isServer) exitWith {};
sleep 1;

// Recall the names of the two objects we placed in the editor
_objPos = [X, [300, 500]] call Zen_FindGroundPosition;

/** This code actually supports both a HC being present and no HC.  You don't have to have the HC running and connected to the server for this mission to work.  Determining which is the case is done below.  It also involves some remote execution to make the HC process the AI.  If you haven't seen this before, it simply tells the HC to execute the code.  Otherwise, the server will have to take over and execute the code locally. */

_args = [_objPos, 3, 200];
if (isMultiplayer && !(isNil "HC") && {isPlayer HC}) then {
    diag_log "RE spawn";
    ZEN_FMW_MP_REClient("F_SpawnOpfor", _args, HC)
} else {
    _args call F_SpawnOpfor;
};

// The usual pleasantries of a mission
// This (by not completing the task) will prove the AI spawned
_taskClearArea = [X, "Clear the area of all Opfor patrols", "Clear Area", _objPos] call Zen_InvokeTask;
_h_areaClear = [east, _taskClearArea, "succeeded", _objPos, [225, 225], 0, "ellipse"] spawn Zen_TriggerAreaClear;

ZEN_STD_Code_WaitScript(_h_areaClear)
// ...End Mission

/**  And that's the mission.  Due to the peculiarities of Steam you must run your normal client (with an interface) first, then the server and HC.  It is also important that you wait for the HC client to be ready during the mission's briefing (box next to name fills in).  Otherwise, the HC isn't really connected to the mission.

You may have noticed the diag_log in the code.  This makes the log files for the server and HC (in their profile folders in install directory for me) reflect that the server handed of execution of F_SpawnOpfor to the HC.  Thus, the Zen_OrderInfantryPatrol thread is also running on the HC.  Also note, F_SpawnOpfor is defined above the clients exiting so it can be run on any machine.
*/
