// This file is part of Zenophon's ArmA 3 Co-op Mission Framework
// This file is released under Creative Commons Attribution-NonCommercial-NoDerivatives 4.0 International (CC BY-NC-ND 4.0)
// See Legal.txt

{
    [["air", "autonomous"], _x, [(localize "str_Zen_UAV"), (localize "str_Zen_Jet")]] call Zen_ConfigGetVehicleClasses;
    ["ship", _x] call Zen_ConfigGetVehicleClasses;
    [["car", "armored"], _x] call Zen_ConfigGetVehicleClasses;
    ["air", _x, [(localize "str_Zen_Heli")]] call Zen_ConfigGetVehicleClasses;
    ["men", _x, "All", "All"] call Zen_ConfigGetVehicleClasses;
    ["ammo", _x] call Zen_ConfigGetVehicleClasses;
} forEach [east, west, resistance];

["ship", civilian] call Zen_ConfigGetVehicleClasses;
["car", civilian] call Zen_ConfigGetVehicleClasses;
