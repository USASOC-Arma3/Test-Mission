// This file is part of Zenophon's ArmA 3 Co-op Mission Framework
// This file is released under Creative Commons Attribution-NonCommercial-NoDerivatives 4.0 International (CC BY-NC-ND 4.0)
// See Legal.txt

#include "Zen_FrameworkFunctions\Zen_InitHeader.sqf"

// Demonstration of Zen_MP_Closure_Packet and Remote Execution by Zenophon
// Version = Final at 9/14/2013
// Tested with ArmA 3 1.0

/*  There are several systems for remotely executing code on other client machine in a network.  Things like BIS_fnc_MP and CBA events serve a lot of people's needs, but I prefer a system that is more transparent, less automated, and simpler.  Therefore, the framework uses a Public Variable Event Handler (PVEH) system based upon the global variable Zen_MP_Closure_Packet.  In computer science, a closure is a reference to a function, in this case by using a string instead of the actual code, and its arguments, which are local to script that defines the closure or global, that can be executed outside the immediate scope it was defined in.  A packet is a small piece of data send across the network.  This demonstration shows how to easily interact with clients' machines from the server, and it explains some the technical knowledge for creating and using this system.  Code that is in a block comment is for visual reference only and is not necessary to running this demonstration.*/

/*  The format of Zen_MP_Closure_Packet (shown below) is an array containing a string, the reference name of the function, and anything, the arguments of the function.  You must use 'publicVariable "Zen_MP_Closure_Packet";' to send the data stored in Zen_MP_Closure_Packet across the network.  This causes the PVEH to fire on all machines except the machine that public variabled (PV'd) Zen_MP_Closure_Packet.  You may also use 'publicVariableClient' and 'publicVariableServer' for more control, and you can delay using the PV command after defining Zen_MP_Closure_Packet, to avoid repeating code or some other reason.  Be warned that this variable is used by all scripts, so its value may be overwritten by another thread if you wait several seconds.  If you want to see the code of the PVEH, look in Zen_InitHeader.sqf.*/

/*
Zen_MP_Closure_Packet = ["", []];
publicVariable "Zen_MP_Closure_Packet";
*/

/*  The PVEH determines what code is executed based upon the given string, which is the name of a function.  It gets the value of the global variable that has the same name as the string.  Any function defined on a machine can be remotely executed there, including framework functions and BIS functions, and you can use your own functions by simply declaring them on all machines.*/

Zen_TestFunction = {
    hint format ["Hello %1", (name player)];
};

if !(isServer) exitWith {};

/*  The strength of this system of references is that no code is ever sent over the network.  Instead of sending dozens or hundreds of lines of code or a very long string that is compiled to code, only a short string and a few arguments are send over the network, thus keeping network traffic minimal.  Below you can see a technically correct use of Zen_MP_Closure_Packet, in which code is directly sent over the network and executed.  This is inefficient and inelegant, as your mission would be faster and better organized if you first defined that code as a function (like the one above).*/

/*
Zen_MP_Closure_Packet = [{
    hint format ["Hello %1", (name player)];
};, []];
publicVariable "Zen_MP_Closure_Packet";
*/

/*  Due to engine limitations and netcode quirks, you cannot use a PVEH before the mission fully initializes (past the map and briefing screen).  There is no solution or workaround to this, you must wait for some amount of time before you use Zen_MP_Closure_Packet.  A sleep of one second is probably a little long, but gives higher ping clients time to get all the data they need to put their character down in-game.*/
sleep 1;

/*  This is the correct way to use Zen_MP_Closure_Packet.  This code would show the text "Hello Zenophon" if I joined this mission as a client.  This example is extremely simple, but you can see that getting around any locality limitation is now possible.  This is how the framework is able to run entirely on the server and manage the clients, even though all clients stop executing at the beginning of the init.  The arguments array is optional, so it is left off here, as there are no arguments.  On the client machine, the code that is executed looks like this: '0 = [] spawn Zen_TestFunction;' */
Zen_MP_Closure_Packet = ["Zen_TestFunction"];
publicVariable "Zen_MP_Closure_Packet";

/*  This example assumes you ran this from a dedicated server, as a local host would not see this message because his machine is both a client and the server.  The machine that PV'd Zen_MP_Closure_Packet does not execute the code, this is a drawback to such a simple system as this.  Therefore, if you want to show the hint to a local host as well, the below code will do that.  It will also show the code in singleplayer and the editor, but will not run on a dedicated server.*/
if !(isDedicated) then {
    0 = [] call Zen_TestFunction;
};

/*  It is important to note that none of this can be tested in singleplayer or the editor, as a PVEH has no effect there.  The easiest way to test this is to launch a dedicated LAN server from your machine and connect to it from in-game on the same machine.  This allows you to test as though you were just another client (and is not considered cheating or piracy etc.). */

/*  This system is certainly not an original idea (others used a PVEH before me) but is entirely my own design and execution.  It does not support JIP players automatically, nor does it manage the storing or calling of functions with proxy functions.  It also cannot control which clients execute the function unless you code that in the called function.  All of the code is in Zen_InitHeader.sqf for you to see or edit.  If you don't like this very manual, bare-bones approach don't worry about it or think that this is only correct way.  This demonstration is just to show that BIS_fnc_MP et al. do not use magic or something, they are just a PVEH with lots of fluff over it.*/
