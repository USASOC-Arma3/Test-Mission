This file is part of Zenophon's ArmA 3 Co-op Mission Framework
This file is released under Creative Commons Attribution-NonCommercial-NoDerivatives 4.0 International (CC BY-NC-ND 4.0)
See Legal.txt

Demonstration Missions

The scripts in this folder are commented mission files that demonstrate intermediate level scripting, mission design, and some part of the framework.  The mission.sqm is not provided for some, while others are given as a complete mission.  This is based upon if there is anything to really observe in the mission.  They are intended for people who want to start learning more advanced scripting techniques and see more of what the framework can do.

The comments may seem ridiculous at times, but they assume that the reader has only completed the beginner tutorials given with the framework.  Some of the longer demonstrations do not comment on every line, to not overwhelm the reader.  If you are not familiar with the framework, start by looking at the shorter tutorials, as they give more detail about what each function call does.

You can read most of them in any order or not at all; however, some of the comments will repeat.  Some more advanced demonstrations assume that you know more about the framework and SQF, so look at each one and start with those that don't seem too difficult.  Included below is a table of contents for the demonstrations, organized by subjective difficulty, and including a short description of each.

Table of Contents

Zen_DynamicPatrolMarkers
    Difficulty Level: I
    Description: Simple spawning and patrolling of infantry in a marker.  Modifying object-like marker properties to affect a function's behavior.

Zen_HC
    Difficulty Level: I
    Description: Simple, working example of how to use a headless client in a framework mission.  Ability to set up and run a dedicated server is a prerequisite.  Some understanding of remote execution and locality recommended.

Zen_RandomPositions
    Difficulty Level: I
    Description: Exhaustive exposition of Zen_FindGroundPosition's filters and their results.  Shows typical uses for each filter.

Zen_SpawningDemonstration
    Difficulty Level: I
    Description: Straightforward spawning of various soldiers and vehicles.  Shows common practice for procedural spawning.

Zen_AIShareInfo
    Difficulty Level: II
    Description: Standard infantry patrol augmented by an AI controller.  Discusses AI knowledge of targets and shows a simple implementation of goal-oriented behavior.

Zen_CustomLoadout
    Difficulty Level: II
    Description: Exhaustive explanation of every part of the custom loadout system.  Shows typical uses and randomization.  Required for creating your own custom loadouts.

Zen_MiscDemo
    Difficulty Level: II
    Description: A combined implementation of intermediate techniques to create a short mission.  Shows parachute insertion, simple functional organization, thread updating, and dynamically directing AI patrols.

Zen_MPRemoteExecution
    Difficulty Level: II
    Description: Very detailed intro to executing code on other machines in multiplayer.  Mostly conceptual outline of the process, showing basic syntax.  No practical implementation.

Zen_MultiThreadManagement
    Difficulty Level: II
    Description: Intro to multiple threads and simple thread updating.  Detailed short mission implementation showing an example usage.

Zen_InfantryShowcaseV2
    Difficulty Level: III
    Description: Complete mission implementation of a framework adaptation of BIS's Infantry Showcase.  Shows every part of the entire mission in detail.

Zen_RandomBattle
    Difficulty Level: III
    Description: Advanced randomized procedural spawning on a large scale.  Best practice for spawned object data structures.  Detailed explanation and usage of Zen_ConfigGetVehicleClasses, required to generate class lists dynamically.

Zen_StackTrace
    Difficulty Level: III
    Description: Conceptual discussion and practice usage of the framework's internal stack trace.  Discussion of SQF stack implementation and SQF concepts.

Zen_EventQueue
    Difficulty Level: IV
    Description: Presentation of an alternate mission-making style using an SQF adaption of event handling.  Designed for complex non-linear singleplayer missions.  Example implementation shown.

Zen_JIP
    Difficulty Level: IV
    Description: Discussion and solution of JIP concerns for framework-driven missions.  Prior knowledge of or experience with remote execution recommended.  Short example mission using the JIP template.  Required for making framework missions JIP-compatible.

Zen_MPRemoteAction
    Difficulty Level: IV
    Description: Full mission using remote execution on a large scale.  Discussion of linear event-driven mission design in multiplayer.  Best practice in client-server interactions.  Thorough understanding of locality and remote execution strongly recommended.
