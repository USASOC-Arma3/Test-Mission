This file is part of Zenophon's ArmA 3 Co-op Mission Framework
This file is released under Creative Commons Attribution-NonCommercial-NoDerivatives 4.0 International (CC BY-NC-ND 4.0)
See Legal.txt

Version    : Full 9/2/15
Tested With: 1.50 Stable

Contact the author:
ZenophonArmAFramework@gmail.com


Contents:
    Readme.txt
        This file

    Zen_FrameworkDocumentation (Directory):
        Changelog.txt
            The history of the framework
        FAQ.txt
            Common concerns or questions not addressed elsewhere
        FrameworkIntroduction.txt
            A complete overview of the framework, with various considerations addressed
        HowToDebug.txt
            A detailed guide to errors and debugging
        HowToUseDocumentation.txt
            A detailed guide to the framework's documentation style
        Index.txt
            A full list of all public functions organized alphabetically under their respective categories
        KnownIssues.txt
            A complete list of all known bugs and issues, including notes on solutions, hotfixes, and workarounds
        Legal.txt
            The full legal contract that accompanies this framework, READ THIS
        SQFOverview.txt
            A short tutorial and demonstration on some interesting features of the SQF language
        Zen_*Functions.txt
            The full documentation of all functions contained in that category, see Index.txt

        Zen_Demontrations (Directory):
            Readme.txt
            Zen_InfantryShowcaseV2.Stratis (Directory)
            Zen_MiscDemo.Altis (Directory)
            Zen_RandomBattle.Altis (Directory)
            Zen_RandomPositions.Altis (Directory)
            Zen_SpawningDemonstration.Altis (Directory)
            Readme.txt
            Zen_AIShareInfo.sqf
            Zen_CustomLoadout.sqf
            Zen_DynamicPatrolMarkers.sqf
            Zen_EventQueue.sqf
            Zen_HC.sqf
            Zen_JIP.sqf
            Zen_MPRemoteAction.sqf
            Zen_MPRemoteExecution.sqf
            Zen_MultiThreadManagement.sqf
            Zen_StackTrace.sqf

        Zen_Diagrams (Directory):
            Zen_CreateObjective (Directory):
            Zen_FindGroundPosition (Directory):
            Zen_OrderInfantryPatrol (Directory):
            Zen_SpawnInfantry (Directory):
            Readme.txt

        Zen_Misc (Directory):
            Plugins (Directory)
            Readme.txt
            sqf_black.xml
            sqf_white.xml

        Zen_SampleMissions (Directory):
            Zen_AirbaseAssault.Stratis (Directory)
            Zen_AssaultFrini.Stratis (Directory)
            Zen_CleanSweep.Altis (Directory)
            Zen_InfantryPatrol.Altis (Directory)
            Zen_RespawnPatrol.Altis (Directory)
            Zen_SecureCompound.Altis (Directory)
            Zen_StealtheCar.Altis (Directory)
            Zen_Survive.Altis (Directory)
            Readme.txt

        Zen_Tutorials (Directory):
            AltisPatrol.Altis (Directory)
            ChainedObjectives.Altis (Directory)
            ChainedObjectivesRandom.Altis (Directory)
            CustomObjectives.Altis (Directory)
            MissionAssassination.Stratis (Directory)
            MissionAssassinationRandom.Stratis (Directory)
            MissionBriefing.Stratis (Directory)
            MissionBriefingRandom.Stratis (Directory)
            MissionFireSupport.Altis (Directory)
            MissionHelicopter.Stratis (Directory)
            MissionHelicopterRandom.Altis (Directory)
            MissionHelicopterRandom.Stratis (Directory)
            MissionPOW.Stratis (Directory)
            MissionPOWCoOp.Stratis (Directory)
            MissionPOWRandom.Stratis (Directory)
            MissionWarlord.Stratis (Directory)
            MissionWarlordRandom.Stratis (Directory)
            MultiSquadObjectives.Altis (Directory)
            Readme.txt
            TutorialIntroduction.pdf
            TutorialSchema.pdf

    Shell.Stratis:
        Zen_FrameworkFunctions (Directory)
        Description.ext
            A sample file containing necessary framework commands
        Init.sqf
            A sample file containing necessary framework commands
        Mission.sqm
            Blank mission
        StringTable.xml
            Required localization table


Step-wise Installation:

The framework must be installed separately for every mission that uses it.  It is easiest to install the framework first before creating your mission.  See FrameworkIntroduction.txt for details.  This process is also covered in the tutorials.

1: Start ArmA, open the editor, create a new (blank) mission on any map, save it with any name
2: Navigate to (Windows 7) C:\Users\<userName>\My Documents\Arma 3 - Other Profiles\<profileName>\missions
3: Open the directory with your mission name
4: From the sample mission, Shell.Stratis, copy Zen_FrameworkFunctions, Init.sqf, Description.ext, and StringTable.xml into your mission directory
    If you already have a mission with an Init.sqf, Description.ext, or StringTable.xml:
        Open each file in Shell.Stratis and copy ALL of the code to the TOP of your corresponding file
5. Do not place the Zen_FrameworkDocumentation folder in your mission folder.
6: Go back to the editor, save (ctrl+s) your mission
7: Continue to create your mission, coding what you want in the init.sqf, (fullscreen windowed mode is recommended for alt-tabbing)


What to do First:

If you are not sure what you have just downloaded, take a look at FrameworkIntroduction.txt to see what the framework is all about.

Even if you know what you want, I suggest reading FrameworkIntroduction.txt and FAQ.txt soon.  FrameworkIntroduction.txt is the full version of the abridged text used for the framework's forum thread.  Before you begin making missions on your own with the framework, I advise reading HowToDebug.txt, HowToUseDocumentation.txt, and KnownIssues.txt.  You can also see the readme specific to each subfolder for more about its contents.  If you want to just dive in, here are some suggestions based upon relative experience level.

For all experience levels, I have packaged some sample missions I have made.  These are full missions you can export and play in singleplayer or multiplayer, but you might just want to preview them in the editor to see the code in action.  Even if you don't understand all the code, these missions contain various common techniques I use repeatedly to make missions.  The piece-wise design of framework functions means that doing certain common actions in a mission follow a simple, logical pattern that is easy to remember.

If you have little to no experience with the sqf scripting and the editor, I strongly advise that you start with the first tutorial.  Open the Zen_Tutorials folder and read the readme file there.  You probably have a slight advantage in that you don't have any misconceptions about sqf.

If you have experience with the editor but little with sqf, I strongly advise that you start with first tutorial.  The tutorials assume you do not know the editor, but they focus almost exclusively on using the framework.  Using the framework is a lot different from the editor, and I hope that you will see that the framework is a better way to create missions.  Once you get the hang of coding missions using the framework, it gets easier to put together more functions.

For those doing the tutorials, after about the fifth tutorial, you should know enough to look at some of the easier demonstration missions.  At this point you can feel free to switch between demonstrations and tutorials, or start making simple missions of your own.

If you have intermediate experience with sqf (or know a real programming language), feel free to skim through the tutorials and see what is done.  Each tutorial becomes increasingly complex, and each one offers a 'technical corner' that is more advanced.  I suggest that you look at the code in later tutorials to see what the framework can do at an intermediate level.  Also, I suggest you read some or all of the demonstration missions (Zen_Demontrations folder).  Some might seem too easy or too hard, but they will help you get more out of using the framework.  If you are serious about learning sqf, invest some time practicing and studying example code (you can look at framework source code too).  You don't need to be a professional programmer (I'm not) to be really good with sqf.

Finally, if you are an advanced scripter (hundreds of hours coding complex functions and systems and/or professional programmer in real life), you probably already know what you want out of a function library.  I suggest looking through the index and documentation files for functions that interest you.  Also, see the demonstration missions for some common ways to use framework functions and an explanation of some framework data structures.  You are free to look through all the source code for the framework and edit it for your personal use (be sure to update the documentation too).  However, please read the Legal.txt file and understand what is said there.


Legal Considerations

Please read and understand the Legal.txt file in its entirety.  Implicit agreement to those terms is a part of using the framework.  This is not meant to scare anyone or restrict what you can create with the framework.  I simply have every intention of maintaining my IP rights as the author of the framework (you should know your rights too).

Of particular concern to some modders is the Steam Subscriber Agreement for the Steam Workshop.  I am confident that the terms of my legal agreement are strong enough to defeat the statements of Valve's lawyers.  I suggest that you read section 6.A of the Steam Subscriber Agreement and understand what it means about the content you release on the workshop.

I am no lawyer, but have written the Legal.txt as close to legal speak as I can, to prevent loopholes.  In common speech, the terms are basically so:

I, Zenophon, am the sole author and owner of the framework source code and documentation.
I am not responsible for any result of your (mis)use of the framework, nor do I offer any legal warranties about the framework.
You cannot publish any part of the framework as part of another framework, on Steam or elsewhere.
You can use the framework in your mission and release that mission on Steam or any way you choose.
You must credit me clearly if you use any part of this framework in your mission.
It is my sole right to agree to the Steam Subscriber Agreement for my framework.
Thus, even though you agree to the Steam Subscriber Agreement to release your mission, my framework is not subject to its terms (your mission is).
All work you do using the framework is your property.
I also release my framework under the Creative Commons Attribution-NonCommercial-NoDerivatives 4.0 International (CC BY-NC-ND 4.0) license.
You must release the legal agreement with the code (see below).
You agree to the full legal terms by using the framework.

Be advised, none of the statements above constitute a legal agreement, they are just an informal outline.  All legal statements in Legal.txt still apply.  The Legal.txt file is included in the Zen_FrameworkFunctions folder (don't remove it), to make sure it is distributed with every mission.  If you are not familiar with Creative Commons, see this:

http://creativecommons.org/licenses/by-nc-nd/4.0/
