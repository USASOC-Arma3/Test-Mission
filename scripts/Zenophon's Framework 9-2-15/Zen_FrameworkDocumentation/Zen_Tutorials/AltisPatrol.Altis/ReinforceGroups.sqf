
// This function will be called on each client
f_joinSwitchable = {
    private ["_units", "_leader"];
    _units = [(_this select 0)] call Zen_ConvertToObjectArray;
    _leader = _this select 1;

    _units join _leader;
    {
        addSwitchableUnit _x;
    } forEach _units;
};

// Join new units to there groups and synchronize server and clients
f_syncReinforcements = {
    private ["_reinforcementGroup", "_existingGroup", "_h_insertion", "_insertionHeli"];

    _reinforcementGroup = _this select 0;
    _existingGroup = _this select 1;
    _h_insertion = _this select 2;
    _insertionHeli = _this select 3;

    waitUntil {
        sleep 5;
        (isTouchingGround (leader _reinforcementGroup))
    };

    // wait for all other units to be on ground
    sleep 10;

    // see Zen_MPRemoteExecution demonstration
    0 = [_x, (leader _existingGroup)] call f_joinSwitchable;
    Zen_MP_Closure_Packet = ["f_joinSwitchable", [_x, (leader _existingGroup)]];
    publicVariable "Zen_MP_Closure_Packet";

    waitUntil {
        sleep 5;
        (scriptDone _h_insertion)
    };

    // garbage collect heli
    {
        deleteVehicle _x;
    } forEach (crew _insertionHeli + [_insertionHeli]);
};

// Public function
f_sendReinforcements = {
    private ["_groupsArray", "_groupUnitsMaxArray", "_group", "_landPos", "_heliSpawnPos", "_reinforceHeli", "_maxCount", "_replaceCount", "_reinforceGroup", "_h_insertion"];

    _groupsArray = _this select 0;
    _groupUnitsMaxArray = _this select 1;

    {
        // for readability
        _group = _x;
        _count = count units _group;

        // we need how many units to replenish group
        _maxCount = _groupUnitsMaxArray select _forEachIndex;
        _replaceCount = _maxCount - _count;

        if (_replaceCount > 0) then { // else no reinforcements

            // get point for helicopter to land, roads are easy to land on
            _landPos = [_group, [25, 200], [], 1, [1, 200]] call Zen_FindGroundPosition;

            // get heli start position, change 'b_heli_transport_01_f' to any heli you want
            _heliSpawnPos = [_landPos, [900, 1300], [], 0] call Zen_FindGroundPosition;
            _reinforceHeli = [_heliSpawnPos, "b_heli_transport_01_f"] call Zen_SpawnHelicopter;

            // standard spawning and equipping functions
            _reinforceGroup = [_heliSpawnPos, west, "infantry", _replaceCount] call Zen_SpawnInfantry;
            0 = [_reinforceGroup] call Zen_GiveLoadoutBlufor;
            0 = [_reinforceGroup] call Zen_AddGiveMagazine;
            0 = [_reinforceGroup] call Zen_AddRepackMagazines;
            0 = [_reinforceGroup, _reinforceHeli] call Zen_MoveInVehicle;

            // fastrope insertion and retreat, recall that _h_insertion is finished when heli is at [0,0,0]
            _h_insertion = [_reinforceHeli, [_landPos, [0,0,0]], _reinforceGroup, "normal", 30, true] call Zen_OrderInsertion;

            // open new thread to wait for landing, join reinforcements, then garbage collect heli
            0 = [_reinforceGroup, _group, _h_insertion, _reinforceHeli] spawn f_syncReinforcements;
        };
    } forEach _groupsArray;
};
