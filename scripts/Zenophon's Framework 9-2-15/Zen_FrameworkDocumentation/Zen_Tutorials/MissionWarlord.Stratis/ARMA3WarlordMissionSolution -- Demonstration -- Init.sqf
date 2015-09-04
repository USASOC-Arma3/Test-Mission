#include "Zen_FrameworkFunctions\Zen_InitHeader.sqf"
titleText ["Good Luck", "BLACK FADED", 0.3];
enableSaving [false, false];
player creatediaryRecord["Diary", ["Warlord Tutorial", "An evil warlord must be killed.<br/>A handful of squads protect the warlord. One patrols nearby, the others within a range of 100 to 250 meters.<br/>"]];
if (!isServer) exitWith {};
sleep 0.5;

_objectivePos = ["WarlordMissionOpfor"] call Zen_FindGroundPosition;
_yourObjective = [_ObjectivePos, (group X11), east, "Officer","eliminate"] call Zen_CreateObjective;

_groupArray = [];
	
// Spawn, distribute and track multiple squads around a single point
for [{_i=0}, {_i<3}, {_i=_i+1}] do {

	for [{_j=0}, {_j<=_i}, {_j=_j+1}] do {
	
		// Within the range of "i * 50" to "i * 50 + 50" generate a random position
	    _groupPos = [_objectivePos, [_i*100,_i*100+100]] call Zen_FindGroundPosition;
		
		// Spawn a squad at that position
		_groupEAST = [_groupPos, east, "infantry", [2,3]] call Zen_SpawnInfantry;
		
		// Order it to patrol within that range
		0 = [_groupEAST, _objectivePos, [(_i*100) + 1,(_i*100+100)]] spawn Zen_OrderInfantryPatrol;
		
		// Add squad to array of EAST squads
		_groupArray set [(count _groupArray), _groupEAST];
	
	};
};

// Track all EAST squads
_returnArray = [_groupArray, "group"] call Zen_TrackInfantry;

// Track player	
_returnArray = [[(group X11)], "name"] call Zen_TrackGroups;

waituntil {
    sleep 5; 
    ([(_yourObjective select 1)] call Zen_AreTasksComplete)
};

endMission "end1";
