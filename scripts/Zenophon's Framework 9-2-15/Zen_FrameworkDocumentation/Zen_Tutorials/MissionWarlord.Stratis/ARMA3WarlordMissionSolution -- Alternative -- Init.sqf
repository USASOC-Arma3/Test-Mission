#include "Zen_FrameworkFunctions\Zen_InitHeader.sqf"
titleText ["Good Luck", "BLACK FADED", 0.3];
enableSaving [false, false];
player creatediaryRecord["Diary", ["Warlord Tutorial", "An evil warlord must be killed.<br/>A handful of squads protect the warlord. One patrols nearby, the others within a range of 100 to 250 meters.<br/>"]];
if (!isServer) exitWith {};
sleep 1.5;

_objectivePos = ["WarlordMissionOpfor"] call Zen_FindGroundPosition;
_yourObjective = [_ObjectivePos, (group X11), east, "Officer","eliminate"] call Zen_CreateObjective;

_innerGuardsGroupArray = [];
_outerGuardsGroupArray = [];

// compact version of sqf for loop -- spawns two squads
for "_i" from 0 to 1 do {
    _innerPos = [_objectivePos, [90,160]] call Zen_FindGroundPosition;
    _innerGuard = [_innerPos, east, "infantry", [2,3]] call Zen_SpawnInfantry;
    _innerGuardsGroupArray set [(count _innerGuardsGroupArray), _InnerGuard];
};

0 = [_innerGuardsGroupArray, _objectivePos, [70,180]] spawn Zen_OrderInfantryPatrol;

// verbose version of sqf for loop -- spawns four squads
// compact version is preferred - it is faster and ultimately more flexible
for [{_i=0}, {_i<4}, {_i=_i+1}] do {
    _outerPos = [_objectivePos, [170,250]] call Zen_FindGroundPosition;
    _outerGuard = [_outerPos, east, "infantry", [2,3]] call Zen_SpawnInfantry;
    _outerGuardsGroupArray set [(count _outerGuardsGroupArray), _outerGuard];
};

// opening multiple threads of patrol and tracking scripts wastes resources
// consolidate all data into an array an create only one thread
0 = [_outerGuardsGroupArray, _objectivePos, [180,230]] spawn Zen_OrderInfantryPatrol;
_returnArray = [(_innerGuardsGroupArray + _outerGuardsGroupArray), "group"] call Zen_TrackInfantry;

waituntil {
    sleep 5; 
    ([(_yourObjective select 1)] call Zen_AreTasksComplete)
};

endMission "end1";
