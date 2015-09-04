#include "Zen_FrameworkFunctions\Zen_InitHeader.sqf"

// <Your mission name here> by <your name here>
// Version = <the date here>
// Tested with ArmA 3 -- <version number>

// This will fade in from black, edit the number to change the length of the fade
titleText ["Good Luck", "BLACK FADED", 0.3];
// SQF functions cannot continue running after loading a saved game, do not delete this line
enableSaving [false, false];

Player creatediaryRecord["Diary", ["Multi-Squad Co-op Tutorial", "Two BLUFOR squads are tasked with the goal of eliminating a recently arrived enemy unit. Local friendly units have assisted with the stockpiling of various advanced weapons. After the enemy vehicle is clearly identified, choose a loadout and eliminate the vehicle.<br/>"]];

// All clients stop executing here, do not delete this line
if (!isServer) exitWith {};

// Execution stops until the mission begins (past briefing), do not delete this line 
sleep 1.5;

// Enter the mission code here

// Add these actions for all playable units
0 = [[(group X11),(group Y11)]] call Zen_AddGiveMagazine;
0 = [[(group X11),(group Y11)]] call Zen_AddRepackMagazines;

0 = [["date", 18, 8, 10, 3, 2035]] spawn Zen_SetWeather;
0 = [["overcast",0.6]] spawn Zen_SetWeather;

_PlayerPosition = getPosATL X11;

// Generate a random spawn position
_Xsquad_boat_SpawnPos = [_PlayerPosition, [100,200],[],2,[0,0],[120,160]] call Zen_FindGroundPosition;
// Create a boat for X Squad
_Xsquad_boat = [_Xsquad_boat_SpawnPos, "b_boat_transport_01_f"] call Zen_SpawnBoat;
// Call for insertion of X Squad by boat
0 = [_Xsquad_boat, ["XSquadBeachhead", _Xsquad_boat_SpawnPos], (group X11), "normal"] spawn Zen_OrderInsertion;
// Move X squad into boat
0 = [(group X11), _Xsquad_boat] call Zen_MoveInVehicle;

// Generate a random spawn position
_Ysquad_heli_SpawnPos = ["YSquadBeachhead", [600,800],[],2,[0,0],[90,120]] call Zen_FindGroundPosition;
// Create a helicopter
_Ysquad_helicopter = [_Ysquad_heli_SpawnPos, "b_heli_light_01_f", 80] call Zen_SpawnHelicopter;
// Call for insertion by helicopter
0 = [_Ysquad_helicopter, ["YSquadBeachhead", _Ysquad_heli_SpawnPos], (group Y11), "normal", 80] spawn Zen_OrderInsertion;
// Move Y squad into helicopter
0 = [(group Y11), _Ysquad_helicopter] call Zen_MoveInVehicle;

// Loadout options
0 = [BLUFORLoadouts,["AA Specialist","AT Rifleman","AT Specialist","Grenadier"],-1] call Zen_AddLoadoutDialog;

// Give squads time to land and gather
sleep 120;

// Create a custom mission using a randomly generated target
_vehicleArray = ["O_APC_Tracked_02_cannon_F","O_MBT_02_cannon_F","O_Heli_Attack_02_F","O_Heli_Light_02_F"];
_selectedVehicle = [_vehicleArray] call Zen_ArrayGetRandom;

_yourObjective = ["OPFORPatrolOne", [(group X11),(group Y11)], east, "Custom", "Eliminate", _selectedVehicle] call Zen_CreateObjective;
_objectiveVehicle = ((_yourObjective select 0) select 0);
0 = [_objectiveVehicle, east] call Zen_SpawnVehicleCrew;

// Control target behavior based on type of vehicle
if (_objectiveVehicle isKindOf "Air") 
then {[_objectiveVehicle, "OPFORPatrolOne"] spawn Zen_OrderAircraftPatrol;}
else {[_objectiveVehicle, "OPFORPatrolOne"] spawn Zen_OrderVehiclePatrol;};

// If a squad is not player controlled then issue some reasonable commands and outfit some units
// with weapons that help complete the objective
if (!isplayer X11) then{
	0 = [(group X11), _objectiveVehicle,[50,200],[0,360],"normal"] spawn Zen_OrderInfantryPatrol;
	_returnArray = [[(group X11)],"name",west] call Zen_TrackInfantry;
	if (_objectiveVehicle isKindOf "Air") 
	then {[[X11,X12], "AA Specialist"] call Zen_GiveLoadoutBlufor;}
	else {[[X11,X12], "AT Specialist"] call Zen_GiveLoadoutBlufor;};
};

if (!isplayer Y11) then{
	0 = [(group Y11), _objectiveVehicle,[50,200],[0,360],"normal"] spawn Zen_OrderInfantryPatrol;
	_returnArray = [[(group Y11)],"name",west] call Zen_TrackInfantry;
	if (_objectiveVehicle isKindOf "Air") 
	then {[[Y11,Y12], "AA Specialist"] call Zen_GiveLoadoutBlufor;}
	else {[[Y11,Y12], "AT Specialist"] call Zen_GiveLoadoutBlufor;};
};

waituntil { sleep 5; [(_yourObjective select 1)] call Zen_AreTasksComplete };

endMission "end1"
