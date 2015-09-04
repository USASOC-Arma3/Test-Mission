// This file is part of Zenophon's ArmA 3 Co-op Mission Framework
// This file is released under Creative Commons Attribution-NonCommercial-NoDerivatives 4.0 International (CC BY-NC-ND 4.0)
// See Legal.txt

#include "Zen_FrameworkFunctions\Zen_InitHeader.sqf"

// Demonstration of Stack Tracing by Zenophon
// Version = Final 2/23/2014
// Tested with ArmA 3 1.10

/*  SQF has no integral stack trace feature built into the engine.  If something goes wrong, the error message shows the exact location of the problem and nothing else.  This also applies to function calls; there is no simple command to know what called what.  In order to print out a stack trace, you must store data yourself and know when to print it out.  I have done just that, allowing any framework error message to show you the stack.*/

enableSaving [false, false];
if !(isServer) exitWith {};
sleep 1;

/**  Before looking at the functions that do this, I will discuss a feature of SQF that makes this possible.  This is discussed in more detail in SQFOverview.txt.  Variables in sqf belong to namespaces, and local variables in a function belong to the function's namespace.  A special feature of function namespaces it that they are inherited by a lower scope.  If Function1 calls Function2, Function2 now has access to all of Function1's local variables.*/

/**  This means that called functions could unintentionally modify a value in the calling function.  This is prevented by the 'private' command, which declares a variable to belong to the current scope, thus discarding any value from a higher scope.*/

/**  If we do not take advantage of private statements, we can create a variable that is shared by all functions called from one function.  The one function we start with is the init.  A series of function calls is a stack.  Thus, the stack has a variable local to itself.*/

/**  We start by declaring the variable to hold the data of the stack.  This must be an array, so that it can be modified by reference, and it makes sense that functions on the stack are elements in an array.  The stack starts with 'Init', as that is where the mission begins executing.*/
_Zen_stack_Trace = ["Init"];

/**  This function is called at the beginning of every function that uses the stack trace.  It simply places what the function tells in into the stack variable.  However, it must also make sure the variable exists, for reasons discussed later.*/
Zen_StackAdd = {
    (if (isNil "_Zen_stack_Trace") then {
        ([[(_this select 0), (_this select 1), time]])
    } else {
        _Zen_stack_Trace pushBack [(_this select 0), (_this select 1), time];
        (_Zen_stack_Trace)
    })
};

/**  In order to have a reliable stack trace, every function that puts itself on the stack must also remove itself from the stack.  Thus, this function must always run before the function exits.  If a function can stop executing before it reaches the bottom of its code, every possible exit point must contain a call to the removal function.  Functions do not check what they are is removing; it is safe to assume that that function is the last element in the stack array.*/
Zen_StackRemove = {
    _Zen_stack_Trace resize ((count _Zen_stack_Trace) - 1);
};

/**  Every time an error occurs, we must print out the stack below the error message from the function.  This function automates printing the stack in the correct ascending order.*/
Zen_StackPrint = {
    for "_i" from (count _Zen_stack_Trace - 1) to 0 step -1 do {
        if (Zen_Print_All_Errors) then {
            systemChat str (_Zen_stack_Trace select _i);
        };
        diag_log (_Zen_stack_Trace select _i);
    };
};

/** Below we can see three functions, simply differentiated as A, B, and C, used to test a simple stack trace.  If the tests on these functions work, the stack trace will work for all other functions that implement this same method, regardless of how complex they are.  Each function does nothing but manage the stack and print things.  FunctionA has no errors in it, and it calls FunctionB.  FunctionB has an error, and it calls FunctionC.  FunctionC also has an error.  Both FunctionB and FunctionC print out their stack trace.  You could modify this to print errors from any function.*/

FunctionA = {
    _Zen_stack_Trace = ["FunctionA", _this] call Zen_StackAdd;

    diag_log "FunctionA runs fine";
    0 = [] call FunctionB;

    call Zen_StackRemove;
    if (true) exitWith {};
};

FunctionB = {
    _Zen_stack_Trace = ["FunctionB", _this] call Zen_StackAdd;

    0 = ["FunctionB", "Error", _this] call Zen_PrintError;
    call Zen_StackPrint;

    0 = [] call FunctionC;

    call Zen_StackRemove;
    if (true) exitWith {};
};

FunctionC = {
    _Zen_stack_Trace = ["FunctionC", _this] call Zen_StackAdd;

    0 = ["FunctionC", "Error", _this] call Zen_PrintError;
    call Zen_StackPrint;

    call Zen_StackRemove;
    if (true) exitWith {};
};

/**  After defining those functions, we test the stack trace by calling FunctionA with an argument of [1].*/
0 = [1] call FunctionA;

/**  This is what should print out in the log:
    "FunctionA runs fine"
    "-- FunctionB Error --"
    "Error"
    1.006
    []
    ["FunctionB",[],3.006]
    ["FunctionA",[1],3.006]
    "Init"
    "-- FunctionC Error --"
    "Error"
    1.006
    []
    ["FunctionC",[],3.006]
    ["FunctionB",[],3.006]
    ["FunctionA",[1],3.006]
    "Init"
*/

// We then make sure that each function removed itself from the stack correctly.
diag_log _Zen_stack_Trace;

/** This prints out:
    ["Init"]
*/

/**  The key to making the stack trace work is that every function takes care of adding and removing itself from the stack.  Regardless of what the function does when it executes, it must be on the stack for that entire time, then remove itself just before exiting.*/

/**  This stack trace system works well when calling functions from the init, but there is a problem when we use the 'spawn' command.  This command opens a new thread, and a new thread is not a lower scope of the calling function.  Thus, each thread runs separately with its own stack.*/

/**  Every function must allow for the chance that it is the top of a new stack in a new thread.  That is why Zen_StackAdd checks to see if the local variable exists.  This is the only way to know if a function has been spawned.*/

/**  We now test the stack trace feature using 'spawn'.*/
0 = [6] spawn FunctionB;

/**  This is what should print out in the log:
    "-- FunctionB Error --"
    "Error"
    3.017
    [6]
    ["FunctionB",[6],3.017]
    "-- FunctionC Error --"
    "Error"
    3.017
    []
    ["FunctionC",[],3.017]
    ["FunctionB",[6],3.017]
*/

/**  This stack trace, although it functions the same as the previous one, is an entirely different variable in a different thread.  Although the variable has the same name, the functions in a different thread see a different value.  Because of this, it is very preferable to use 'call' instead of 'spawn' wherever possible.  This makes errors much easier to fix.*/

/**  Now that we only need to set up a few simple calls in each method, it just takes some copy-pasting to make any function work with this system.  This makes the tracing automatic every time you use any functions in any order.  However, if not all of the functions you call implement this stack trace, results will be inconsistent.  If a function is skipped, it appears as though it was never called on the stack.  All 150 public framework functions, and some of the private ones, use this stack trace system.*/
