;@Ahk2Exe-SetCompanyName Made by LeoTN
;@Ahk2Exe-SetCopyright Licence available on my GitHub project (https://github.com/LeoTN/gtav-tweaks)
;@Ahk2Exe-SetDescription GTAV Tweaks
;@Ahk2Exe-SetMainIcon library\assets\gtav_tweaks_icon.ico

#SingleInstance Force
#MaxThreadsPerHotkey 2
SendMode "Input"
CoordMode "Mouse", "Window"

; Imports important functions and variables.
; Sets the directory for all following files.
#Include "includes\"
#Include "ConfigFile.ahk"
#Include "CustomHotkeyOverviewGUI.ahk"
#Include "Functions.ahk"
#Include "Languages.ahk"
#Include "MainGUI.ahk"
#Include "NewCustomHotkeyGUI.ahk"
#Include "Objects.ahk"

onInit()

onInit()
{
    global booleanFirstTimeLaunch := false
    global macroRecordHotkey := "F5"

    global ahkBaseFileLocation := A_ScriptDir . "\GTAV_Tweaks\AutoHotkey32.exe"
    global readmeFileLocation := A_ScriptDir . "\GTAV_Tweaks\README.txt"

    global iconFileLocation := A_ScriptDir . "\GTAV_Tweaks\assets\gtav_tweaks_icon.ico"

    global psUpdateScriptLocation := A_ScriptDir . "\GTAV_Tweaks\update\checkForUpdates.ps1"
    global currentVersionFileLocation := A_ScriptDir . "\GTAV_Tweaks\update\currentVersion.csv"

    global audioHookFileLocation := A_ScriptDir . "\GTAV_Tweaks\soundvolumeview-x64\SoundVolumeView.exe"

    global macroFilesStorageDirectory := A_ScriptDir . "\GTAV_Tweaks\macros"
    global macroConfigFileLocation := macroFilesStorageDirectory . "\GTAV_Tweaks_MACROS.ini"
    global builtInHKLocation_createSololobby := macroFilesStorageDirectory . "\builtInHK_createSololobby.ahk"
    global builtInHKLocation_walkDriveFlyAFK := macroFilesStorageDirectory . "\builtInHK_cayoPrepPlaneAfkFlight.ahk"

    global recordedMacroFilesStorageDirectory := A_ScriptDir . "\GTAV_Tweaks\recorded_macros"

    onInit_unpackSupportFiles()
    ; The version can now be specified because the version file should now be available.
    Try
    {
        currentVersionFileMap := readFromCSVFile(currentVersionFileLocation)
        global versionFullName := currentVersionFileMap.Get("CURRENT_VERSION")
    }
    Catch
    {
        global versionFullName := "v0.0.1"
    }
    ; Runs all onInit() functions from included files.
    ; languages_onInit() is included in configFile_onInit().
    configFile_onInit()
    functions_onInit()
    objects_onInit()
    mainGUI_onInit()
    customHotkeyOverviewGUI_onInit()
    newCustomHotkeyGUI_onInit()

    If (readConfigFile("DISPLAY_LAUNCH_NOTIFICATION"))
    {
        TrayTip(getLanguageArrayString("generalScriptTrayTip2_1"), getLanguageArrayString("generalScriptTrayTip2_2"), "Iconi Mute")
        Sleep(1500)
        TrayTip()
    }
    If (readConfigFile("ASK_FOR_TUTORIAL"))
    {
        scriptTutorial()
    }
    If (readConfigFile("CHECK_FOR_UPDATES_AT_LAUNCH"))
    {
        checkForAvailableUpdates()
    }
    waitForGTAToExist()
    If (readConfigFile("MUTE_GAME_WHILE_LAUNCH"))
    {
        muteGTAWhileInLoadingScreen()
    }
    ; Checks every 3 seconds if GTA is still existing and if it is the active window.
    SetTimer(checkForExistingGTA, 3000)
}

onInit_unpackSupportFiles()
{
    If (!A_IsCompiled && !DirExist(A_ScriptDir . "\GTAV_Tweaks"))
    {
        MsgBox("You are using a non compiled version of this script.`n`nMake sure that all supportive files are present "
            . "in the [GTAV_Tweaks] folder.`n`nThis folder needs to exist in the same directory as this script.`n`n"
            "You can achieve this by executing a compiled version in this directory that will create them for you.",
            "GTAV Tweaks - Uncompiled Script Information", "Iconi 262144")
        Return
    }
    ; Prompts the user to confirm the creation of files.
    If (!DirExist(A_ScriptDir . "\GTAV_Tweaks"))
    {
        result := MsgBox("Hello there!`n`nYou are about to create additional files in a folder called [GTAV_Tweaks]"
            . " in the same directory as this script.`n`n"
            "Would you like to proceed?", "GTAV Tweaks - Confirm File Creation", "YN Iconi 262144")
        If (result != "Yes")
        {
            ExitApp()
        }
        MsgBox("To uninstall this software you just need to delete the files.", "GTAV Tweaks - How To Uninstall?", "Iconi 262144")
        DirCreate(A_ScriptDir . "\GTAV_Tweaks")
    }
    If (!DirExist(A_ScriptDir . "\GTAV_Tweaks\assets"))
    {
        DirCreate(A_ScriptDir . "\GTAV_Tweaks\assets")
    }
    If (!DirExist(macroFilesStorageDirectory))
    {
        DirCreate(macroFilesStorageDirectory)
    }
    If (!DirExist(recordedMacroFilesStorageDirectory))
    {
        DirCreate(recordedMacroFilesStorageDirectory)
    }
    If (!DirExist(A_ScriptDir . "\GTAV_Tweaks\update"))
    {
        DirCreate(A_ScriptDir . "\GTAV_Tweaks\update")
    }

    ; Copies a bunch of support files into a folder (GTAV_Tweaks) relative to the script directory.
    If (!FileExist(ahkBaseFileLocation))
    {
        FileInstall("library\build\AutoHotkey32.zip", A_ScriptDir . "\GTAV_Tweaks\AutoHotkey32.zip", true)
        RunWait('powershell.exe -Command "Expand-Archive -Path """' . A_ScriptDir
            . '\GTAV_Tweaks\AutoHotkey32.zip""" -DestinationPath """' . A_ScriptDir . '\GTAV_Tweaks""" -Force"', , "Hide")
        FileDelete(A_ScriptDir . "\GTAV_Tweaks\AutoHotkey32.zip")
    }
    If (!FileExist(readmeFileLocation))
    {
        FileInstall("library\build\README.txt", readmeFileLocation, true)
    }

    If (!FileExist(iconFileLocation))
    {
        FileInstall("library\assets\gtav_tweaks_icon.ico", iconFileLocation, true)
    }

    If (!FileExist(psUpdateScriptLocation))
    {
        FileInstall("library\build\checkForUpdates.ps1", psUpdateScriptLocation, true)
    }
    If (!FileExist(currentVersionFileLocation))
    {
        FileInstall("library\build\currentVersion.csv", currentVersionFileLocation, true)
    }

    If (!FileExist(audioHookFileLocation))
    {
        FileInstall("library\build\soundvolumeview-x64.zip", A_ScriptDir . "\GTAV_Tweaks\soundvolumeview-x64.zip", true)
        RunWait('powershell.exe -Command "Expand-Archive -Path """' . A_ScriptDir
            . '\GTAV_Tweaks\soundvolumeview-x64.zip""" -DestinationPath """' . A_ScriptDir . '\GTAV_Tweaks\soundvolumeview-x64""" -Force"', , "Hide")
        FileDelete(A_ScriptDir . "\GTAV_Tweaks\soundvolumeview-x64.zip")
    }

    If (!FileExist(macroConfigFileLocation))
    {
        IniWrite("Always back up your files!", macroConfigFileLocation, "CustomHotkeysBelow", "Advice")
    }

    If (!FileExist(builtInHKLocation_walkDriveFlyAFK))
    {
        FileInstall("library\built_in_hotkeys\builtInHK_cayoPrepPlaneAfkFlight.ahk", builtInHKLocation_walkDriveFlyAFK, true)
    }
    If (!FileExist(builtInHKLocation_createSololobby))
    {
        FileInstall("library\built_in_hotkeys\builtInHK_createSololobby.ahk", builtInHKLocation_createSololobby, true)
    }
}