#include "Zen_FrameworkFunctions\Zen_InitHeader.sqf"

// Clean Sweep by Zenophon
// Version = Final 6/12/14
// Tested with ArmA 3 1.20

// This mission is inspired by the classic Operation Flashpoint mission 'Clean Sweep'.  A bit of nostalgia for those who remember the old days.

titleText ["Good Luck", "BLACK FADED", 0.2];
enableSaving [false, false];

player createDiaryRecord ["Diary", ["Mission", "You are part of a special forces team tasked with swiftly clearing the town of Katalaki.  You will insert by MRAP along the road west of the town.  Hit the Opfor hard and fast, make sure all Opfor patrols are eliminated.  Once the town is clear, you will extract by AH-9 east of the town.  Be sure to get out of there fast, before Opfor reinforcements show up."]];

{_x setMarkerAlpha 0;} forEach ["mkKatalaki"];

if (!isServer) exitWith {};
sleep 1;

// Very standard start to a mission, these 5 functions are the staple of a framework SP or co-op mission
_players = group X;

0 = [["date", random 60, 9 + random 6], ["overcast", random 0.5], ["fog", 0.2]] spawn Zen_SetWeather;

0 = [_players] call Zen_AddGiveMagazine;
0 = [_players] call Zen_AddRepackMagazines;
0 = [_players, ["Recon", "Rifleman", "Marksman", "Auto Rifleman"]] call Zen_GiveLoadoutBlufor;
0 = [_players, "SOF"] call Zen_SetAISkill;

// these tasks will appear as the 'Good Luck' screen disappears
_task_getIn = [_players, "A Hunter MRAP will arrive shortly.  Get in the insertion vehicle.", "Get In MRAP", X, true] call Zen_InvokeTask;
sleep 3;
_task_clearTown = [_players, "Sweep and clear the town quickly, eliminating all Opfor patrols.", "Clear Katalaki", "mkKatalaki"] call Zen_InvokeTask;

_h_insert = [B_MRAP, [X, [0,0,0]], _players] spawn Zen_OrderExtraction;

waitUntil {
    sleep 2;
    ([_players] call Zen_AreInVehicle)
};

// manually updating a task is easy
0 = [_task_getIn, "succeeded"] call Zen_UpdateTask;

// now combine the extraction logic with insertion, this looks seamless for players
terminate _h_insert;
_h_insert = [B_MRAP, ["mkInsertion", B_MRAP], _players] spawn Zen_OrderInsertion;

waitUntil {
    sleep 2;
    ([_players] call Zen_AreNotInVehicle)
};

0 = [_task_clearTown] call Zen_SetTaskCurrent;

// procedural spawning when we need AI
_groupArray = [];
for "_i" from 1 to (3 + round random 1.5) do {
    _spawnPos = ["mkKatalaki"] call Zen_FindGroundPosition;
    _group = [_spawnPos, east, "militia", [2, 3]] call Zen_SpawnInfantry;
    0 = [_groupArray, _group] call Zen_ArrayAppend;
};

// just change east here and in Zen_SpawnInfantry to resistance and instantly have a different enemy
0 = [_groupArray, east] call Zen_GiveLoadout;

// multiple threads keeping things going...
0 = [_groupArray, "mkKatalaki"] spawn Zen_OrderInfantryPatrol;
_h_clear1 = [_groupArray, _task_clearTown, "succeeded"] spawn Zen_TriggerAreDead;
_h_clear2 = [_groupArray, _task_clearTown, "succeeded", "mkKatalaki"] spawn Zen_TriggerAreaClear;

// ...so the init does no work
waitUntil {
    sleep 3;
    ((scriptDone _h_clear1) || (scriptDone _h_clear2))
};

// very standard extraction with a task, just to look polished
_task_Extract = [_players, "Get to the extraction point.", "Extract", "mkExtraction", true] call Zen_InvokeTask;
_h_extract = [B_Heli, ["mkExtraction", B_Heli], _players] spawn Zen_OrderExtraction;

waitUntil {
    sleep 2;
    ([_players] call Zen_AreInVehicle)
};

sleep 5;

0 = [_task_Extract, "succeeded"] call Zen_UpdateTask;

sleep 5;

// see the description.ext for endWin config
0 = "endWin" call BIS_fnc_EndMission;
