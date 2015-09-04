#include "Zen_FrameworkFunctions\Zen_InitHeader.sqf"

// <Your mission name here> by <your name here>
// Version = <the date here>
// Tested with ArmA 3 <version number>

// This will fade in from black, to hide jarring actions at mission start, this is optional and you can change the value
titleText ["Good Luck", "BLACK FADED", 0.2];
// SQF functions cannot continue running after loading a saved game, do not delete this line
enableSaving [false, false];
// All clients stop executing here, do not delete this line
if (!isServer) exitWith {};
// Execution stops until the mission begins (past briefing), do not delete this line
sleep 1;

// Enter the mission code here
