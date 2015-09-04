// This file is part of Zenophon's ArmA 3 Co-op Mission Framework
// This file is released under Creative Commons Attribution-NonCommercial-NoDerivatives 4.0 International (CC BY-NC-ND 4.0)
// See Legal.txt

#include "Zen_FrameworkFunctions\Zen_InitHeader.sqf"

// Demonstration of Zen_FindGroundPosition by Zenophon
// Version = Final 2/17/14
// Tested with ArmA 3 1.10

/** The most powerful tool for random missions in the framework is Zen_FindGroundPosition.  This function allows you to generate random points based upon various filters.  You have probably already seen this system used a lot, but this demonstration will showcase some more advanced parameters.  Although most examples only make use of a few filtering options, you can see how you could combine many such filters to find points that fit your exact needs, while maintaining unpredictability in your mission.  This mission is best previewed in the editor to see its full effect, so the mission.sqm is included with this demonstration.*/

titleText ["Good Luck", "BLACK FADED", 0.5];
enableSaving [false, false];

Player creatediaryRecord["Diary", ["Find Ground Position Demonstration", "Call Zen_FindGroundPosition with different parameters.
<br/>
<br/>Neochori Red: Random within Area Marker; land only.
<br/>Neochori Yellow: Random within ring having inner radius of 400 meters; land only.
<br/>Neochori Blue: Random within Area Marker; land and sea permitted.
<br/>
<br/>Pyrgos Red: Random around Icon Marker; 0-200 meters and land only.
<br/>Pyrgos Yellow: Random within ring having inner radius of 200 and outer radius of 400 meters; land only.
<br/>Pyrgos Blue:  Random around Icon Marker; 0-500 meters and land and sea permitted.
<br/>
<br/>Orino North Red: Random within Area Marker; move to road if within 100 meters.
<br/>Orino North Yellow: Random within Area Marker; generate on roads only.
<br/>Orino South Green: Random around Icon Marker; 0-400 meters and exclude Orino North.
<br/>
<br/>Poliakko: Random around Icon Marker; 0-200 meters and avoid (blacklist) Area Alpha and Area Beta.
<br/>Poliakko: Random around Icon Marker; 0-200 meters and be in both Area Alpha and Area Beta.
<br/>
<br/>Xirolimni Dam: Random around Icon Marker; 0-200 meters and avoid (blacklist) Area Alpha.
<br/>Xirolimni Dam: Random around Icon Marker; 0-200 meters and be in either Area Alpha or Area Beta.
<br/>
<br/>Therisa North Red: Random within Area Marker between angles 180 and 360.
<br/>Therisa North Yellow: Random within Area Marker between angles 60 and 120.
<br/>
<br/>Factory Red: Random around Factory Icon Marker; avoid Factory buildings by 50 meters.
<br/>Factory Yellow: Random around Factory Icon Marker; avoid Factory buildings by 50 meters; avoid 200 meters around two icon markers.
<br/>
<br/>Water Avoidance Shoreline Red: Random near Shoreline; more than 200 meters from ocean.
<br/>Water Avoidance Shoreline Yellow: Random near Shoreline; less than 100 meters from ocean.
<br/>
<br/>Rugged Terrain: Random in rugged terrain; avoid slopes more than 5 degrees.
<br/>
<br/>Avoid Cluttered Terrain: Random in mix of cluttered and open terrain; avoid any rock, tree or shrub by 25 meters.
<br/>Avoid Cluttered Terrain: Random in mix of cluttered and open terrain; create tent city on flat open land."]];

if (!isServer) exitWith {};
sleep 1;

"Zen_FGP_One" setMarkerAlpha 0;

// Spawn red chemlights randomly around Neochori
for [{_i=0}, {_i<21}, {_i=_i+1}] do {
    _signalPos = ["Zen_FGP_One"] call Zen_FindGroundPosition;
    _rChemlight = [_signalPos, "chemlight_red"] call Zen_SpawnVehicle;
    0 = [_rChemlight,"", "colorred",[1,1],"mil_dot"] call Zen_SpawnMarker;
};

// Spawn yellow chemlights randomly around Neochori
for [{_i=0}, {_i<21}, {_i=_i+1}] do {
    _signalPos = ["Zen_FGP_One",400] call Zen_FindGroundPosition;
    _yChemlight = [_signalPos, "chemlight_yellow"] call Zen_SpawnVehicle;
    0 = [_yChemlight,"", "coloryellow",[1,1],"mil_box"] call Zen_SpawnMarker;
};

// Spawn blue chemlights randomly around Neochori
for [{_i=0}, {_i<21}, {_i=_i+1}] do {
    _signalPos = ["Zen_FGP_One",0,0,0] call Zen_FindGroundPosition;
    _bChemlight = [_signalPos, "chemlight_blue"] call Zen_SpawnVehicle;
    0 = [_bChemlight,"", "colorblue",[1,1],"mil_triangle"] call Zen_SpawnMarker;
};


// Spawn red chemlights randomly around Pyrgos
for [{_i=0}, {_i<21}, {_i=_i+1}] do {
    _signalPos = ["Zen_FGP_Two",[0,200]] call Zen_FindGroundPosition;
    _rChemlight = [_signalPos, "chemlight_red"] call Zen_SpawnVehicle;
    0 = [_rChemlight,"", "colorred",[1,1],"mil_dot"] call Zen_SpawnMarker;
};

// Spawn yellow chemlights randomly around Pyrgos
for [{_i=0}, {_i<21}, {_i=_i+1}] do {
    _signalPos = ["Zen_FGP_Two",[200,400]] call Zen_FindGroundPosition;
    _yChemlight = [_signalPos, "chemlight_yellow"] call Zen_SpawnVehicle;
    0 = [_yChemlight,"", "coloryellow",[1,1],"mil_box"] call Zen_SpawnMarker;
};

// Spawn blue chemlights randomly around Pyrgos
for [{_i=0}, {_i<21}, {_i=_i+1}] do {
    _signalPos = ["Zen_FGP_Two",[0,500],0,0] call Zen_FindGroundPosition;
    _bChemlight = [_signalPos, "chemlight_blue"] call Zen_SpawnVehicle;
    0 = [_bChemlight,"", "colorblue",[1,1],"mil_triangle"] call Zen_SpawnMarker;
};


// Spawn red chemlights randomly around Orino North
for [{_i=0}, {_i<21}, {_i=_i+1}] do {
    _signalPos = ["Zen_FGP_Orino",0,0,1,[1,100]] call Zen_FindGroundPosition;
    _rChemlight = [_signalPos, "chemlight_red"] call Zen_SpawnVehicle;
    0 = [_rChemlight,"", "colorred",[1,1],"mil_dot"] call Zen_SpawnMarker;
};

// Spawn yellow chemlights randomly around Orino North
for [{_i=0}, {_i<21}, {_i=_i+1}] do {
    _signalPos = ["Zen_FGP_Orino",0,0,1,[2,0]] call Zen_FindGroundPosition;
    _yChemlight = [_signalPos, "chemlight_yellow"] call Zen_SpawnVehicle;
    0 = [_yChemlight,"", "coloryellow",[1,1],"mil_box"] call Zen_SpawnMarker;
};

// Spawn green chemlights randomly around Orino South
for [{_i=0}, {_i<21}, {_i=_i+1}] do {
    _signalPos = ["Zen_FGP_Orino_South",[0,400],["Zen_FGP_Orino"]] call Zen_FindGroundPosition;
    _gChemlight = [_signalPos, "chemlight_green"] call Zen_SpawnVehicle;
    0 = [_gChemlight,"", "colorgreen",[.5,.5],"mil_circle"] call Zen_SpawnMarker;
};

// Spawn red chemlights randomly around Poliakko
for [{_i=0}, {_i<21}, {_i=_i+1}] do {
    _signalPos = ["Zen_FGP_Poliakko",0,[["Zen_Poliakko_Alpha","Zen_Poliakko_Beta"],[],[]]] call Zen_FindGroundPosition;
    _gChemlight = [_signalPos, "chemlight_red"] call Zen_SpawnVehicle;
    0 = [_gChemlight,"", "colorred",[.5,.5],"mil_circle"] call Zen_SpawnMarker;
};
// Spawn green chemlights randomly around Poliakko
for [{_i=0}, {_i<21}, {_i=_i+1}] do {
    _signalPos = ["Zen_FGP_Poliakko",0,[[],["Zen_Poliakko_Alpha","Zen_Poliakko_Beta"],[]]] call Zen_FindGroundPosition;
    _gChemlight = [_signalPos, "chemlight_green"] call Zen_SpawnVehicle;
    0 = [_gChemlight,"", "colorgreen",[.5,.5],"mil_circle"] call Zen_SpawnMarker;
};

// Spawn red chemlights randomly around Dam
for [{_i=0}, {_i<21}, {_i=_i+1}] do {
    _signalPos = ["Zen_FGP_Xirolimni_Dam",[0,200],[["Zen_XDam_Alpha"],[],[]]] call Zen_FindGroundPosition;
    _gChemlight = [_signalPos, "chemlight_red"] call Zen_SpawnVehicle;
    0 = [_gChemlight,"", "colorred",[.5,.5],"mil_circle"] call Zen_SpawnMarker;
};
// Spawn green chemlights randomly around Dam
for [{_i=0}, {_i<21}, {_i=_i+1}] do {
    _signalPos = ["Zen_FGP_Xirolimni_Dam",[0,200],[[],[],["Zen_XDam_Alpha","Zen_XDam_Beta"]]] call Zen_FindGroundPosition;
    _gChemlight = [_signalPos, "chemlight_green"] call Zen_SpawnVehicle;
    0 = [_gChemlight,"", "colorgreen",[.5,.5],"mil_circle"] call Zen_SpawnMarker;
};

// Spawn red chemlights randomly around Therisa
for [{_i=0}, {_i<21}, {_i=_i+1}] do {
    _signalPos = ["Zen_FGP_Four",0,0,1,0,[180,360]] call Zen_FindGroundPosition;
    _rChemlight = [_signalPos, "chemlight_red"] call Zen_SpawnVehicle;
    0 = [_rChemlight,"", "colorred",[1,1],"mil_dot"] call Zen_SpawnMarker;
};

// Spawn yellow chemlights randomly around Therisa
for [{_i=0}, {_i<21}, {_i=_i+1}] do {
    _signalPos = ["Zen_FGP_Four",0,0,1,0,[60,120]] call Zen_FindGroundPosition;
    _yChemlight = [_signalPos, "chemlight_yellow"] call Zen_SpawnVehicle;
    0 = [_yChemlight,"", "coloryellow",[1,1],"mil_box"] call Zen_SpawnMarker;
};

// Spawn red chemlights randomly around the Factory
for [{_i=0}, {_i<21}, {_i=_i+1}] do {
    _signalPos = ["Zen_FGP_Factory",[0,500],0,1,0,0,[1,0,50]] call Zen_FindGroundPosition;
    _rChemlight = [_signalPos, "chemlight_red"] call Zen_SpawnVehicle;
    0 = [_rChemlight,"", "colorred",[1,1],"mil_dot"] call Zen_SpawnMarker;
};

// Spawn yellow chemlights randomly around the Factory
for [{_i=0}, {_i<21}, {_i=_i+1}] do {
    _signalPos = ["Zen_FGP_Factory",[0,500],0,1,0,0,[1,0,50],[1,["Zen_FGP_IconExclusion1","Zen_FGP_IconExclusion2"],200]] call Zen_FindGroundPosition;
    _yChemlight = [_signalPos, "chemlight_yellow"] call Zen_SpawnVehicle;
    0 = [_yChemlight,"", "coloryellow",[1,1],"mil_box"] call Zen_SpawnMarker;
};

// Spawn red chemlights randomly near a shore
for [{_i=0}, {_i<21}, {_i=_i+1}] do {
    _signalPos = ["Zen_FGP_Shoreline",0,0,1,0,0,0,0,[1,200]] call Zen_FindGroundPosition;
    _rChemlight = [_signalPos, "chemlight_red"] call Zen_SpawnVehicle;
    0 = [_rChemlight,"", "colorred",[1,1],"mil_dot"] call Zen_SpawnMarker;
};

// Spawn yellow chemlights randomly near a shore
for [{_i=0}, {_i<21}, {_i=_i+1}] do {
    _signalPos = ["Zen_FGP_Shoreline",0,0,1,0,0,0,0,[2,100]] call Zen_FindGroundPosition;
    _yChemlight = [_signalPos, "chemlight_yellow"] call Zen_SpawnVehicle;
    0 = [_yChemlight,"", "coloryellow",[1,1],"mil_box"] call Zen_SpawnMarker;
};

// Spawn red chemlights randomly in rugged terrain
for [{_i=0}, {_i<21}, {_i=_i+1}] do {
    _signalPos = ["Zen_FGS_Rugged",0,0,1,0,0,0,0,0,[1,5,20]] call Zen_FindGroundPosition;
    _rChemlight = [_signalPos, "chemlight_red"] call Zen_SpawnVehicle;
    0 = [_rChemlight,"", "colorred",[1,1],"mil_dot"] call Zen_SpawnMarker;
};

// Spawn red chemlights randomly around a wooded area
for [{_i=0}, {_i<16}, {_i=_i+1}] do {
        _signalPos = ["Zen_FGS_ClutterExclusion",0,0,1,0,0,0,0,0,0,[1,[0,0,0],25]] call Zen_FindGroundPosition;
    _rChemlight = [_signalPos, "chemlight_red"] call Zen_SpawnVehicle;
    0 = [_rChemlight,"", "colorred",[1,1],"mil_dot"] call Zen_SpawnMarker;
};

// Spawn tents randomly around a mildly crowded area; place on level land away from houses, trees, rocks and shrubs
for [{_i=0}, {_i<21}, {_i=_i+1}] do {
    _signalPos = ["Zen_FGS_TentCity",0,0,1,0,0,[1,0,10],0,0,[1,5,5],[1,[0,0,0],10]] call Zen_FindGroundPosition;
    _rChemlight = [_signalPos, "Land_TentA_F"] call Zen_SpawnVehicle;
    0 = [_rChemlight,"", "colorred",[1,1],"mil_dot"] call Zen_SpawnMarker;
};
