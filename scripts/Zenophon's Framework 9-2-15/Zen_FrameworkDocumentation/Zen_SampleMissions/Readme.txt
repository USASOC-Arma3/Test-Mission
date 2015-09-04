This file is part of Zenophon's ArmA 3 Co-op Mission Framework
This file is released under Creative Commons Attribution-NonCommercial-NoDerivatives 4.0 International (CC BY-NC-ND 4.0)
See Legal.txt

Sample Missions

To round off the selection of material using the framework, the sample missions provide several full missions with all parts included.  The tutorials are meant for beginners, to guide you through simple mission making and show you the ease of the framework.  The demonstrations are mean to spotlight some technique or aspect of the framework for your learning, and they are not full missions (except for two).

The sample missions are not meant to showcase something in particular; they are how I would implement a mission using the framework.  There are some comments to help you read the code (but not like the demonstration missions), and you should be able to see what is going on by looking at the function names.  All of them are playable in multiplayer as-is, just copy in the framework code and export them to multiplayer from the editor.

Mostly, they are meant to advertise what the framework can do by showing how a complex mission can be created without frustration over details.  They also serve as a reference, if you want to see how many common parts of missions are done.  They show you the end product of using the framework and why I have put so much effort into it.

Included below is a table of contents for the sample missions, organized by subjective difficulty, and including a short description of each.

Table of Contents

Zen_StealtheCar.Altis
    Difficulty Level: I
    Description: A classic reborn, a short mission featuring random patrols, functional organization, and handling tasks.

Zen_CleanSweep.Altis
    Difficulty Level: I
    Description: A classic reborn, a straightforward mission using a combined extraction-insertion, using an editor placed vehicle, and advancing the mission based upon other threads running.

Zen_SecureCompound.Altis
    Difficulty Level: II
    Description: Large combined arms battle mission, using fire support and insertions for both players and AI.  Also shows managing friendly AI to do objectives like humans would.  Also includes a little fun with cfgIdentities and shuffling groups between insertion points randomly.

Zen_AirbaseAssault.Stratis
    Difficulty Level: II
    Description: The definition of co-op, you need multiple people to do this mission right.  Shows how to split tasks across two groups of players, such that they see and do different things, while all working towards the final objective.  Also features at lot waiting for milestones in the mission and alternate endings.

Zen_Survive.Altis
    Difficulty Level: II
    Description: A 2-man co-op mission placing players in the middle of a Blufor vs. Opfor battle.  Shows sector style takeover objective, custom loadouts, fire support, and simple CAS covering a retreat.

Zen_AssaultFrini.Altis
    Difficulty Level: III
    Description: A short, simple clear-the-town combined arms mission.  However, it deals with respawn and JIP when there are no friendly AI.  Some remote execution and JIP knowledge from the demonstrations is recommended.

Zen_InfantryPatrol.Altis
    Difficulty Level: IV
    Description: Shows infinite spawning of random objectives and patrols, how to spawn and insert friendly AI reinforcements, incorporating your own custom objectives, and JIP compatibility in a medium-sized mission.

Zen_RespawnPatrol.Altis
    Difficulty Level: IV
    Description:  Alternate version of Zen_InfantryPatrol with respawn, including vehicles and a parachute insertion.  Shows manually managing respawn using eventhandlers.  It uses the the same objective and enemy generator and JIP logic as Zen_InfantryPatrol.
