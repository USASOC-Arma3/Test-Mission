This file is part of Zenophon's ArmA 3 Co-op Mission Framework
This file is released under Creative Commons Attribution-NonCommercial-NoDerivatives 4.0 International (CC BY-NC-ND 4.0)
See Legal.txt

Notepad++ SQF Resources

If you use Notepad++ to code, you can make use of two of the three files included with this document to make scripting a lot easier.  The language file itself contains syntax highlighting for all sqf commands, keywords, and operators.  Two versions are offered, sqf_black, which is best used with a black background, and sqf_white, which is best for a white background.  The autocompletion file works regardless of the colors, so long as any sqf custom language is installed and running properly.  The autocompletion file contains all SQF commands and all framework functions, with function hints.  No BIS functions are included.

To install the sqf language file:
    Open Notepad++
    Navigate to Language>>Define your language...
    Select Import.. from the top of the dialog box
    Navigate to the folder containing this document
    From this directory, select sqf_black.xml or sqf_white.xml, depending on your background color preference, and click open
    You should get a message saying the import was successful
    Restart Notepad++
    Every .sqf file you open with Notepad++ will now open with sqf as the language
        Note: You can import both language versions, but I cannot say which one Notepad++ will default to when opening an SQF file
    Navigate to Settings>>Style Configurator..
    Choose a theme from the drop down list that you like, in accordance with your selection of language file
        Note: You can choose any font you want, or modify various colors in the style, styles are entirely separate from the SQF custom language
        Note: I recommend checking the boxes 'Enable global' for 'background color', 'font', and 'font size'

To install the sqf autocompletion file:
    Navigate to the folder containing this document
    Copy the folder 'plugins' from this directory to your Notepad++ install directory
    No files should be overwritten, unless there is an old version of the autocompletion file
    Restart Notepad++
    Navigate to Settings>>Preferences>>Auto-Completion
    Enable the option 'Enable auto-completion on each input'
    Select the radio button 'Function completion' or 'Function and word completion'
    Enable the option 'Function parameters hint on input'
    Whenever you open a file with sqf as the language, autocompletion and function hints will be available

To use the autocompletion and hints:
    By default, typing one character will open the autocompletion box at the cursor position
    Autocompletion is case sensitive, you must type upper and lower case letters as they appear in the list
    Words and functions in the list follow standard camel case capitalization.
    Use the arrow keys or the mouse wheel to navigate the list
    Use the enter or tab keys or double click on an item in the list to insert it at the cursor position
    The autocompletion will detect how much of the word you have already entered, and only add the remaining characters to the word
    To use the function hint feature, enter the name of a framework function.  All public framework functions can be autocompleted.
    After typing or autocompleting the full name of the function, enter a single start square bracket ( after the name of the function
    The full documentation of the function will now display until an end square bracket ) is typed, the cursor is moved using the mouse or arrow keys, or the backspace key is used
    To display the documentation again, position the cursor after the ( and before the ) and press ctrl+shift+space
    You can type out all the arguments while still viewing the documentation
