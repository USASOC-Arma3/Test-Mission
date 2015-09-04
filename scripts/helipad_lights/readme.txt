  ////////////////////////
  //Helipad Light Script// by JoeJoe
  ////////////////////////

	  ||Version: 0.4 (27.12.2013)
		--------------------------------------------------------------------------------------------------------------------
		
	  ||Description:
			Creates Lights around Helipads for better visibility and eyecandy at night
		--------------------------------------------------------------------------------------------------------------------
			
	  ||Contained Scripts:
			helipad_light.sqf
				changelog:
				v.1 initial release 
				v.2 
					bugs:
					- If vehicle is on the helipad the lights were not created correctly
					added:
					- showhint parameter is now optional
					- lightpoints created around the innerlights
					- added IR strobes as possible lights
					
				v.3
					added:
					- SHK_moveObjects Script to set the direction of the lights
					- new optional paramter: ScriptFolder
					- helipad_light_remove script to remove lights from a helipad
					- helipad_light_auto script to create lights for all helipads
				
				v.31
					added:
					- Helipad (Circle), Helipad (Civil) and Helipad (invisble) now have lights positioned as a circle around them
					
				v.32
					added:
					- isServer to prevent multiple clients call the script in mp
					- #lightpoints removed
					- vehicles on helipads do now stay there during the whole creation of the lights
					
				v.4
					added:
					- IR Strobes can now be deleted
					- changed classnames for IR Strobes from B_IRStrobe to NVG_TargetW, O_IRStrobe to NVG_TargetE, I_IRStrobe to NVG_TargetC
			
			helipad_light_auto.sqf
				changelog:
				v.1 initial release 
				
				v.11
					added:
					- isServer to prevent multiple clients call the script in mp
			
			helipad_light_remove.sqf
				changelog:
				v.1 initial release 
				
				v.11
					added:
					- isServer to prevent multiple clients call the script in mp
				
			SHK_moveObject.sqf by Shuko
		--------------------------------------------------------------------------------------------------------------------
			
	  ||Known Errors:
			- If there are other helipads close to the helipad the positions of the lights are messed up
			
			- Not fully tested in MP yet
		--------------------------------------------------------------------------------------------------------------------	
		
	  ||Contact:
			- JoeJoe87577 Bohemia Interactive Forums
			- JoeJoe87577 Armaholic
			- JoeJoe87577 hx3.de Forums (German Arma Forums)
		--------------------------------------------------------------------------------------------------------------------
			
	  ||Links:
			- Armaholic http://www.armaholic.com/page.php?id=23982
			- BI Forums http://forums.bistudio.com/showthread.php?170638-Helipad-Light-Script
		--------------------------------------------------------------------------------------------------------------------
		
	  ||Usage:
		
			Copy the Folder "helipad_lights" to your mission folder or mission script folder if you have one.
			Take a look at the example mission to see how to use this script.
		
		  ///////////////////
		  //Single Helipad://
		  ///////////////////
		
				null = [this, "yellow", "green", false, "scripts"] execVM "scripts\helipad_lights\helipad_light.sqf";
				
			Copy this into the init line of the helipad.
			The parameters are:
				helipad: helipad object (this or name of helipad)
				innerlightcolor: string innerlight color (red, green, yellow, blue(not recommended), white(not recommended), bir (blufor), oir (blufor), iir (resistance))
				outerlightcolor: string outerlight color (red, green, yellow, blue, white, bir (blufor), oir (blufor), iir (resistance))
				showhint (optional): boolean show a hint after creation
				scriptFolder (optional): string Foldername of Scripts
										 e.G.: missionfolder\scripts\helipad_lights	the parameter would be "scripts"
												
			!scriptFolder is very Important, always include this parameter if your script folder is not the mission root folder!
			--------------------------------------------------------------------------------------------------------------------
			
		  /////////////////
		  //All Helipads://
		  /////////////////
			
			if (isServer) then {
				null = [5, "scripts"] execVM "scripts\helipad_lights\helipad_light_auto.sqf";
			};
				
			Copy this into your init.sqf, if you do not have a init.sqf create one and copy it to your mission root folder.
			
			The parameters are:
				createType: number defines on which types of helipads the lights will be created
							1: Helipad (Circle)
							2: Helipad (Civil)
							3: Helipad (Rescue)
							4: Helipad (Square)
							5: all Helipads (excluding invisible Helipads)
				scriptFolder (optional): string Foldername of Scripts. 
										 e.G.: missionfolder\scripts\helipad_lights	the parameter would be "scripts"
							 
			!scriptFolder is very Important, always include this parameter if your script folder is not the mission root folder!
			--------------------------------------------------------------------------------------------------------------------
			
		  //////////////////
		  //Remove Lights://
		  //////////////////
		  
				null = [helipadName] execVM "helipad_lights\helipad_light_remove.sqf";
				
			Copy this into your trigger or script, where the lights should be deleted.
			--------------------------------------------------------------------------------------------------------------------
		--------------------------------------------------------------------------------------------------------------------