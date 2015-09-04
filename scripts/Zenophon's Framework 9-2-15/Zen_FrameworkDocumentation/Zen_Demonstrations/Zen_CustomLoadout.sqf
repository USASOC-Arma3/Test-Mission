// This file is part of Zenophon's ArmA 3 Co-op Mission Framework
// This file is released under Creative Commons Attribution-NonCommercial-NoDerivatives 4.0 International (CC BY-NC-ND 4.0)
// See Legal.txt

#include "Zen_FrameworkFunctions\Zen_InitHeader.sqf"

// Demonstration of Framework Custom Loadouts by Zenophon
// Version = Final 2/1/14
// Tested with ArmA 3 1.10

/** Equipping your character is of particular interest to some players, and a mission designer could leave some ammo boxes around or set up VAS and let players do what they want.  However, to make sure players have mission-critical equipment, don't become a sniper-diver-AT soldier, and to equip friendly and enemy AI in a style that fits the mission (irregulars, SOF, etc.), the framework's loadout functions and sub-system offers almost every possible feature for the mission-maker.  Using the loadout presets is fairly simple and covered multiple times in the tutorials, but setting up a custom loadout requires a knowledge of the correct structure.  This demonstration will cover every aspect of the custom loadout system, including how to create, get, set, delete, update, and invoke your custom loadout data.*/

enableSaving [false, false];
if (!isServer) exitWith {};

/** Before you can make use of a custom loadout in any way, you have to create it first.  There is only one function that does this, and two ways to give it the data that it needs.  The first way is to simply enumerate every aspect of the loadout, as shown below.  The data is organized to cover every possible part of a unit's equipment and to prevent unnecessary pedantries such as if a magazine is in the vest or backpack.  This just leaves putting the right classnames in the right categories.*/

/**  Each nested array is a name-value pair, naming what equipment is being described and the data to use.  This allows you to list the data in any order or not at all.  For most categories, the order of items listed does not matter.  You must still know if something is a magazine, an item, a weapon, etc., so this method can be fairly daunting if you aren't familiar with the config files or don't have organized lists of the many classnames.*/

/**  Nevertheless, this method allows randomization controls.  There are four types of categories.  The first includes 'uniform', 'vest', 'backpack', 'headgear', and 'goggles' categories.  Multiple classnames listed will be chosen from randomly (a unit cannot have more than one vest etc.).  The second type includes 'weapons', 'assignedItems', 'primaryAttachments', 'secondaryAttachments', and 'handgunAttachments'.  Each classname listed is given to the unit, and any nested arrays of classnames are chosen from randomly.  The next type is the 'magazines' category.  That data is nested again with pairs of classname and quantity, making it simple to give many magazines or change the number quickly.  You can nest arrays of nested pairs, to choose from randomly.  Finally, the 'items' category can give a classname multiple times like a magazine, select randomly from multiple classnames, or give a random classname multiple times.  The first option is used below; the last option is used in the second loadout. */

/** To review all of that, the loadout example below presents the four different syntax types.  This loadout, when invoked, will:
    Give the unit a 'U_B_SpecopsUniform_sgg' uniform
    Give the unit one random vest from the list
    Give the unit one random backpack from the list
    Give the unit one random hat or helmet from the list
    Assign all five listed items to an inventory slot
    Give one of the rifles at random and a handgun and rangefinder
    Give 9 rifle mags, 2 pistol mags, 2 grenades, and either 4 white or 4 blue smoke grenades
    Give two first aid kits
    Attach a suppressor, laser pointer, and either a scope or red dot sight to the weapon
    Not give any goggles or handgun attachments
*/

// In multiplayer missions, Zen_CreateLoadout must be used after sleep 1 for clients to get the data.
sleep 1;

_loadout = [
    [["uniform", "U_B_SpecopsUniform_sgg"],
    ["vest", ["V_Chestrig_khk", "V_Chestrig_rgr", "V_Chestrig_blk", "V_Chestrig_oli", "V_TacVest_khk", "V_TacVest_oli", "V_TacVest_camo"]],
    ["backpack", ["B_AssaultPack_mcamo", "B_OutdoorPack_blk", "B_Kitbag_mcamo", "B_Bergen_mcamo", "B_Bergen_blk", "B_TacticalPack_mcamo", "B_TacticalPack_rgr"]],
    ["headgear", ["H_MilCap_mcamo", "H_Cap_tan_specops_US", "H_Watchcap_sgg", "H_Bandanna_sgg", "H_HelmetB_light_grass", "H_HelmetB_light_snakeskin", "H_HelmetB_light_desert", "H_HelmetB_light_black", "H_HelmetB_light_sand"]],
    ["assignedItems", ["ItemMap","ItemCompass","ItemWatch","ItemRadio","ItemGPS","NVGoggles"]],
    ["weapons", [["arifle_MX_Black_F", "arifle_MXC_Black_F"],"hgun_Pistol_heavy_01_F","Rangefinder"]],
    ["magazines", [["30Rnd_65x39_caseless_mag", 9], ["11Rnd_45ACP_Mag", 2], ["HandGrenade", 2], [["SmokeShell", 4], ["SmokeShellBlue", 4]]]],
    ["items", [["FirstAidKit", 2]]],
    ["primaryAttachments", ["muzzle_snds_H","acc_pointer_IR",["optic_Hamr", "optic_aco"]]]
    // ["goggles",""],
    // ["secondaryAttachments",[]],
    // ["handgunAttachments",[]]
]] call Zen_CreateLoadout;

/**  There is one last, powerful randomization feature of this structure.  Every nested array of weapons could contain weapons that uses different ammo.  Instead of creating a whole new loadout just to change weapons, you can tell the function what ammo goes with what weapon.*/

/**  Every nested weapon array is paired, in order, with a nested magazine array.  So, when the function sees multiple weapons nested together, it looks for the first nested list of magazines.  It selects matching weapon and magazine pair from their positions in the nested arrays.  Each weapon you list in the nested array pairs up sequentially with a nested magazine; it is important you place them in this correct order.  The nested arrays themselves must line up in pairs based upon how you want them to match.  So, the first nested weapons array pairs with the first nested magazines array, then the second, and so on, even if there other elements in between them.  When the function cannot find a matching pair it gives a weapon or magazine randomly, without attempted to match them.*/

/**  Below, this feature is shown, allowing this loadout to give 3 different weapons with the correct magazines, and also provides random smoke grenades.  The loadout still gives other weapons and magazines normally.  You could add any number of matching pairs, and then add any number of nested arrays of either weapons or magazines.  Unfortunately, every nested array that has a matching nested array will be considered together.  To get around this, you can create a nested array with the same elements, so that the matching process has no effect.*/

/**  Finally, there is the option to place multiple magazines or weapons inside an array for the matching magazine or weapon.  All of the magazines or weapons listed in this (nested) nested nested array will be given.  This option is used when 'srifle_EBR_F' is selected to give a rangefinder and two extra pistol magazines.  You can also use an empty array, [], to skip a matching magazine section.  This feature is not shown below. */

_loadout2 = [
    [["uniform", "U_B_SpecopsUniform_sgg"],
    ["vest", "V_TacVest_camo"],
    ["backpack", "B_AssaultPack_mcamo"],
    ["headgear", ["H_MilCap_mcamo", "H_Cap_tan_specops_US", "H_Watchcap_sgg", "H_Bandanna_sgg", "H_HelmetB_light_grass", "H_HelmetB_light_snakeskin", "H_HelmetB_light_desert", "H_HelmetB_light_black", "H_HelmetB_light_sand"]],
    ["assignedItems", ["ItemMap","ItemCompass","ItemWatch","ItemRadio","ItemGPS","NVGoggles"]],
    ["weapons", [["arifle_MX_Black_F", ["srifle_EBR_F","Rangefinder"], "LMG_Zafir_F"],"hgun_Pistol_heavy_01_F"]],
    ["magazines", [[["30Rnd_65x39_caseless_mag", 9], [["20Rnd_762x51_Mag", 8], ["11Rnd_45ACP_Mag", 2]], ["150Rnd_762x51_Box", 4]], ["11Rnd_45ACP_Mag", 2], ["HandGrenade", 4], [["SmokeShell", 2], ["SmokeShellBlue", 2]]]],
    ["items", [["FirstAidKit", "Medikit", 2]]],
    ["primaryAttachments", ["acc_pointer_IR",["optic_Hamr", "optic_aco"]]]
]] call Zen_CreateLoadout;

/** An easier way to get the correct data, or at least a decent starting point, is to use Zen_GetUnitLoadout.  This function compiles a unit's equipment in the meticulous format above for you.  The data it returns is usable in Zen_CreateLoadout directly.  However, there are limited number of uses for copying a unit's equipment exactly during a mission.  Instead, Zen_GetUnitLoadout is most useful as a mission development tool to quickly get a loadout you want by equipping your character in-game as desired, calling the function, copying the data to the clipboard, and pasting into the init.sqf for review and editing.  An easy way of doing that whenever you want is to simply put the line below into your init.sqf.*/

player addAction ["Store Loadout Data", {copyToClipboard str ([(_this select 0)] call Zen_GetUnitLoadout);}];

/** Every loadout is stored globally (and publicly for all clients in MP as well) in an array of name-value pairs.  Each loadout has a unique name, either specified by you or randomly generated.  This name is returned by Zen_CreateLoadout.  If you specified a name, you can just use that literal to refer to it later, but, in this example, '_loadout' holds the name.  There are several functions that can manipulate this stored data to accommodate any mission.  The first is Zen_GetLoadoutData, which will return all of the data stored for that loadout.*/

player sideChat str ([_loadout] call Zen_GetLoadoutData);

/** To make use of your loadout in a mission, you can use three functions: Zen_GiveLoadout, Zen_GiveLoadoutCustom, and Zen_GiveLoadoutCargo.  Zen_GiveLoadoutCustom directly indicates that the loadout is custom, while Zen_GiveLoadout has options for pointing to both custom and preset loadouts for all sides.  The advantage of Zen_GiveLoadout appears when you need to decide loadout type and side based upon arguments or some mission condition.  However, for normal use, Zen_GiveLoadoutCustom is simpler. */ 

0 = [player, "custom", _loadout] call Zen_GiveLoadout;
0 = [player, _loadout] call Zen_GiveLoadoutCustom;

/** Zen_GiveLoadout and Zen_GiveLoadoutCustom also offer a parameter for additive giving.  This means that they do not remove any existing equipment before adding new gear.  Magazines and items will be added directly, and items like uniforms, weapons, etc. will replace the current item in that slot.  Zen_GiveLoadoutCustom will attempt to replace everything stored in or on the old item for the new one.  However, this may fail if the new item has less room in the case of a backpack, vest, or uniform, or if a weapon is not compatible with the old attachments. */

_loadout3 = [
    [["assignedItems", ["ItemMap","ItemCompass","ItemWatch","ItemRadio","ItemGPS","NVGoggles"]],
    ["items", ["FirstAidKit", "FirstAidKit"]]
]] call Zen_CreateLoadout;

0 = [player, "custom", _loadout3, "additive"] call Zen_GiveLoadout;
0 = [player, _loadout3, "additive"] call Zen_GiveLoadoutCustom;

/**  Zen_GiveLoadoutCargo gives all the equipment to a vehicle's cargo rather than a person; it is additive, meaning that is does not remove anything from the vehicle. It leaves nothing out, and does not put anything into the uniform, vest, etc.  Each item is placed by itself into the vehicle.*/

// Assume car exists
0 = [car, _loadout] call Zen_GiveLoadoutCargo;

/**  You might have noticed a drawback to this: preset loadouts cannot be added to a vehicle.  Zen_GiveLoadoutCargo cannot detect a preset loadout and do it for you because they are stored in a different format then custom loadouts.  Instead, you can add a preset loadout to a vehicle manually by transforming a preset into a custom loadout.  This procedure will also allow you to use a preset loadout like a custom loadout, except all the randomization is gone.  Every time you transform an instance of a preset loadout into a custom loadout, you have a static version of that preset that can be used anywhere.*/

// Create a dummy unit, we must have someone to give a loadout to
_tempGroup = [[0,0,0], "b_soldier_f"] call Zen_SpawnGroup;
_tempUnit = (units _tempGroup) select 0;

// Give the dummy a loadout, this could be any preset for any side, then save that data
0 = [_tempUnit, "recon"] call Zen_GiveLoadoutBlufor;

// This is one of the few on-the-fly uses of Zen_GetUnitLoadout
_customReconData = [_tempUnit] call Zen_GetUnitLoadout;

// Create a new custom loadout using that data, then give it to the car
_customReconLoadout = [_customReconData] call Zen_CreateLoadout;
0 = [car, _customReconLoadout] call Zen_GiveLoadoutCargo;

// Cleanup by removing the custom loadout and deleting the dummy
// It is not necessary to delete the custom loadout if you want to use it later
0 = [_customReconLoadout] call Zen_RemoveLoadout;
deleteVehicle _tempUnit;
deleteGroup _tempGroup;

/** To strike a balance between letting players pick any equipment they want (VAS) and forcing a single loadout on them (editor), the function Zen_AddLoadoutDialog allows players to select from a list of preset loadouts (and choose for their AI too).  You can include your custom loadouts in this list, allowing the mission-maker to set the style of the players' equipment for a mission.  It is highly recommended that you name your loadout when using Zen_CreateLoadout for this; otherwise, no one will know which loadout is which.  You need to assign this dialog menu to an object (similar to VAS); this can be a box, a car, or any object.*/

// This assumes that _loadout1, _loadout2, and box exist
0 = [box, [_loadout, _loadout1, _loadout2], 2] call Zen_AddLoadoutDialog;

/** The next function, Zen_UpdateLoadout, rewrites the loadout data to a new value.  This can only be done on the whole, small changes to the data cannot be made.  It would be too tedious for the user to figure out how to select and change tiny parts of the data.  This function has few uses (you could just create a new loadout); it would only be useful in the rare case that you cannot change the name of the loadout being given in some repeating function.  You can also use this function and Zen_GetLoadoutData to switch the data associated with two loadout names, as shown below.*/

// This assumes that _loadout1 and _loadout2 exist
_loadoutData1 = [_loadout1] call Zen_GetLoadoutData;
_loadoutData2 = [_loadout2] call Zen_GetLoadoutData;

0 = [_loadout1, _loadoutData2] call Zen_UpdateLoadout;
0 = [_loadout2, _loadoutData1] call Zen_UpdateLoadout;

/** Lastly, Zen_RemoveLoadout will erase the loadout entirely.  Using the loadout name after this will result in an error.  Both this and Zen_UpdateLoadout are not going to be used very often, but they round out your access to the loadout data structure.*/

0 = [_loadout] call Zen_RemoveLoadout;

/**  All that is left now is for you to explore the numerous equipment options in the game and become familiar with creating loadouts.  You can find equipment lists in the config viewer, on the official forums, or just with a google search.  With a good resource, it only takes a few minutes of copy-pasting to create interesting and unique loadouts.  Fun fact, there are about 1,505,129,472,000 (that's 1.5 trillion) possible loadouts in ArmA 3 as of version 1.10, not including weapon attachments, grenades, explosives, mines, and ammunition types and amounts.  Also of note, the data structure used by custom loadouts that allows for updating, removing, etc. is similar to that of the Fire Support and Task systems, which are more complex. */
