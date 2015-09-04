// This file is part of Zenophon's ArmA 3 Co-op Mission Framework
// This file is released under Creative Commons Attribution-NonCommercial-NoDerivatives 4.0 International (CC BY-NC-ND 4.0)
// See Legal.txt

#include "Zen_FrameworkFunctions\Zen_InitHeader.sqf"

// Demonstration of AI Shared Target Info by Zenophon
// Version = Final at 8/22/2013
// Tested with ArmA 3 -- Beta -- 0.76

/*  There are many fancy AI mods and scripts that make the AI communicate and coordinate with each other.  While this is not as feature-packed or amazing, it is intended to show that you can get similar behavior that looks fairly convincing quite easily.  Having the AI hunt down the players adds a lot of tension to a mission and allows for diversionary tactics by human players to work realistically.  This also takes care of the AI reinforcing each other and reacting to an attack as though they were all under the command of another AI.  A smaller, similar algorithm to this demonstration has been incorporated into Zen_OrderInfantryPatrol, allowing individual patrolling groups to detect and chase down spotted enemies.  This demonstration would interfere with that functionality, nevertheless it remains an explanation of how that behavior is achieved.*/

enableSaving [false, false];
if !(isServer) exitWith {};

// Make the marker invisible, this will take effect during the briefing, as it is before 'sleep 1;'
"mkOPFORPatrolStatic" setMarkerAlpha 0;

sleep 1;

// Create an array of the playable blufor soldiers, this way you only need to name one person in the group
_players = units group X11;

// Give each player a random loadout, mark them on the map, and let them repack and give magazines
0 = [_players] call Zen_GiveLoadoutBlufor;
0 = [_players] call Zen_TrackInfantry;
0 = [_players] call Zen_AddGiveMagazine;
0 = [_players] call Zen_AddRepackMagazines;

// Declare array to be set later with all squads that are patrolling
_opforPatrolGroupsArray = [];

for "_i" from 1 to 5 do {

    // Calculate a random position in the marker
    _opforPatrolSpawnPos = ["mkOPFORPatrolStatic"] call Zen_FindGroundPosition;

    // Spawn a 2-3 man Opfor squad
    _opforPatrolGroup = [_opforPatrolSpawnPos, east, "infantry", [2,3]] call Zen_SpawnInfantry;

    // Give them random kits, giving the group name directly works fine
    0 = [_opforPatrolGroup] call Zen_GiveLoadoutOpfor;

    // Update the array of all groups
    0 = [_opforPatrolGroupsArray, _opforPatrolGroup] call Zen_ArrayAppend;
};

// Make all of the groups patrol in the marker
0 = [_opforPatrolGroupsArray, "mkOPFORPatrolStatic"] spawn Zen_OrderInfantryPatrol;

// Mark the leaders of the groups so that we can see then and their destination
0 = [_opforPatrolGroupsArray, "group", true] call Zen_TrackGroups;

/*  This infinite loop continues to determine if any AI group has detected the player.  If so, other groups are informed about the player group and ordered to attack them.  This continues to provide the AI with information if the player is still known to a group even after other groups get the order to attack.  This simulates one group continually guiding the other groups to the enemy.*/
while {true} do {
    { // forEach _opforPatrolGroupsArray
        // If all the units in the group are dead, set that index in the array to zero
        if (({alive _x} count (units _x)) == 0) then {
            _opforPatrolGroupsArray set [_forEachIndex, 0];
        } else {
            _man = leader _x;

            /*  Get all of the possible targets that the squad leader knows about.  These targets may have been spotted by his men.  This returns an array of arrays that contain the name of the target as the fourth element of each nested array.*/
            _opforTargets = _man nearTargets 500;

            {
                /*  We could also use findNearestEnemy, but that may not be a player.  This is a demonstration of hunting down a specific group of people, thus we must examine all targets.*/
                _target = _x select 4;

                /*  Check that one of the players is the target and that the AI has sufficient knowledge about the target.  The () && {} syntax is lazy evaluation.  exitWith will act similarly to an if-then statement, but it will break out of the forEach loop without looping through the rest of the elements.*/
                if ((_target in _players) && {((_man knowsAbout _target) >= 2)}) exitWith {

                    /*  Tell each group to move to the spotted player's position; they will return to their patrol areas once they are done with moving to the players or hunting them down.  This move order appears to interfere with Zen_OrderInfantryPatrol, but you can give orders in parallel, as Zen_OrderInfantryPatrol will simply give an order and then wait for the group to be ready regardless of where they are.*/
                    {
                        // Use Zen_ExtendPosition to generate some error in the move order, it will convert the object to a position for you
                        _x move ([_target, (random 100), (random 360)] call Zen_ExtendPosition);

                        // Reveal this player to the AI group, how they act on this info is up to them, reveal scales from 0 to 4
                        _x reveal [_target, (2 + random 1)];
                    } forEach _opforPatrolGroupsArray;
                };
            } forEach _opforTargets;
        };
        sleep 2;
    } forEach _opforPatrolGroupsArray;

    /*  Remove from the array all of the elements replaced with a 0.  This cannot be done inside the forEach loop because it would throw off the count of the array and the loop would try to access an element that does not exist, thus giving a 'zero divisor' error aka 'out of bounds' exception.*/
    _opforPatrolGroupsArray = _opforPatrolGroupsArray - [0];

    // Alternatively, you could do this to remove all groups with no units
    // You would then switch the if statement to the following, then make the else block the then block
    // (({alive _x} count (units _x)) != 0)
    _opforPatrolGroupsArray = [_opforPatrolGroupsArray] call Zen_ArrayRemoveDead;
};
