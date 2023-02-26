#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#SingleInstance, force
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

NonBreakSpace := Chr(160)

GoSub, InitSettings

GoSub, BuildTrayMenu
GoSub, BuildMenu

Gui, Font, Bold
Gui, +AlwaysonTop +LastFound -MinimizeBox -MaximizeBox
Gui, Add, Text, section x10 y10, Active Profile:
Gui, Add, Edit, x+5 ys-3 w150 ReadOnly vActiveProfileTxt, %ActiveProfile%
Gui, Add, Button, x+0 yp+0 w1 Hidden Default gLV_OK, OK
Gui, Add, ListView, section xs+0 y+5 w305 -LV0x10 Sort -ReadOnly -Multi AltSubmit vProfileLV gProfileLV, Profile
Gui, Add, Text, xs+0 y+8 section, X
Gui, Add, Edit, x+3 ys-3 w60 Limit5 vPosXEdit gPosXEdit, 
Gui, Add, UpDown, vPosXUpDown gPosXUpDown Range-9999-9999
Gui, Add, Text, x+5 ys+0, Y
Gui, Add, Edit, x+3 ys-3 w60 Limit4 vPosYEdit gPosYEdit, 
Gui, Add, UpDown, vPosYUpDown Range-9999-9999
Gui, Add, Text, x+5 ys+0, W
Gui, Add, Edit, x+3 ys-3 w60 Limit4 vPosWEdit, 
Gui, Add, UpDown, vPosWUpDown gPosWUpDown Range0-9999
Gui, Add, Text, x+5 ys+0, H
Gui, Add, Edit, x+3 ys-3 w60 Limit4 vPosHEdit, 
Gui, Add, UpDown, vPosHUpDown gPosHUpDown Range0-9999
GuiControl, Focus, ProfileLV

FileRead, ConfigFile, config.ini
Loop, Parse, ConfigFile, `r, `n
{
    RegExMatch(A_LoopField,"U)\[.*\]",ProfileName)
    if ProfileName not in [General],[Hotkey]
    {
        if (ProfileName <> "")
        {
            if (ProfileName = "[" ActiveProfile "]")
                RowOption := "Select Focus"            
            Else
                RowOption := ""
            LV_Add(RowOption, SubStr(ProfileName, 2, StrLen(ProfileName)-2))
        }
    }
}
Sleep, 100  ;needed to finish all LV triggers
GoSub, InitSelectionWindow
if ShowProfilesOnStart
    GoSub, ShowSelectionWindow
Return

PosXEdit:
GuiControlGet, PosXUPDown, , PosXEdit, 
Return

PosYEdit:
GuiControlGet, PosYUPDown, , PosYEdit, 
Return

PosXUpDown:
Gosub, PosXEdit
CleanNumber(PosXUPDown)
GuiControl, , PosXEdit, %PosXUPDown%
Return

PosYUpDown:
Gosub, PosYEdit
CleanNumber(PosYUPDown)
GuiControl, , PosYEdit, %PosYUPDown%
Return

PosWUpDown:
GuiControlGet, PosWUPDown, , PosWEdit, 
CleanNumber(PosWUPDown)
GuiControl, , PosWEdit, %PosWUPDown%
Return

PosHUpDown:
GuiControlGet, PosHUPDown, , PosHEdit, 
CleanNumber(PosHUPDown)
GuiControl, , PosHEdit, %PosHUPDown%
Return

CleanNumber(ByRef NumberToClean)
{
    global NonBreakSpace

    If InStr(NumberToClean, NonBreakSpace,,2)
        StringReplace, NumberToClean, NumberToClean, %NonBreakSpace%, , All
    If InStr(NumberToClean, ".",,2)
        StringReplace, NumberToClean, NumberToClean, ., , All
    
}

BuildMenu:
    Menu, ProfileMenu, Add, Add Profile`tCtrl+N, AddProfile
    Menu, ProfileMenu, Add, Delete Profile`tDel, DeleteProfile
    Menu, ProfileMenu, Add, Set Default, SetDefaultProfile
    Menu, SettingsMenu, Add, Autostart PoE, ToggleAutoStartPoE
    Menu, SettingsMenu, Add, Show profiles on start, ToggleShowProfiles
    Menu, SettingsMenu, Add, Store values on exit, ToggleStoreValues
    Menu, SettingsMenu, Add, Always on top, ToggleAlwaysOnTop
    Menu, MenuBar, Add, &Profiles, :ProfileMenu
    Menu, MenuBar, Add, Settings, :SettingsMenu
    Gui, Menu, MenuBar
    if StartPoE
        Menu, SettingsMenu, Check, Autostart PoE
    if ShowProfilesOnStart
        Menu, SettingsMenu, Check, Show profiles on start
    if StoreValuesOnExit
        Menu, SettingsMenu, Check, Store values on exit
    if AlwaysOnTop
        Menu, SettingsMenu, Check, Always on top
Return

ToggleAutoStartPoE:
    Menu, SettingsMenu, ToggleCheck, Autostart PoE
    StartPoE := !StartPoE
    IniWrite, % StartPoE, config.ini, General, StartPoE
Return

ToggleShowProfiles:
    Menu, SettingsMenu, ToggleCheck, Show profiles on start
    ShowProfilesOnStart := !ShowProfilesOnStart
    IniWrite, % ShowProfilesOnStart, config.ini, General, ShowProfilesOnStart
Return

ToggleStoreValues:
    Menu, SettingsMenu, ToggleCheck, Store values on exit
    StoreValuesOnExit := !StoreValuesOnExit
    IniWrite, % StoreValuesOnExit, config.ini, General, StoreValuesOnExit
Return

ToggleAlwaysOnTop:
    Menu, SettingsMenu, ToggleCheck, Always on top
    AlwaysOnTop := !AlwaysOnTop
    IniWrite, % AlwaysOnTop, config.ini, General, AlwaysOnTop
    if AlwaysOnTop
        Gui, +AlwaysOnTop
    Else
        Gui, -AlwaysOnTop
Return

#IfWinActive, Select Profile..
    ^n::GoSub AddProfile
    Del::GoSub DeleteProfile
#IfWinActive

BuildTrayMenu:
    Menu, Tray, NoStandard
    Menu, Tray, Icon, Display.dll, 1
    Menu, Tray, Add, Start PoE, RunPoE
    Menu, Tray, Add, Select Profile, ShowSelectionWindow
    Menu, Tray, Add, Open Config, OpenConfig
    Menu, Tray, Add, Reload, Reload
    Menu, Tray, Add, Save Current Values, SaveCurrentValues
    Menu, Tray, Add, Exit, Exit
    Menu, Tray, Default, Start PoE
Return

InitSettings:
    DefaultProfileName := "New Profile "
    IniRead, StartPoE, config.ini, General, StartPoE, False
    ConvertBool(StartPoE)
    IniRead, ClientPath, config.ini, General, ClientPath
    IniRead, ClientExecuteable, config.ini, General, ClientExe
    IniRead, StoreValuesOnExit, config.ini, General, StoreValuesOnExit, False
    ConvertBool(StoreValuesOnExit)
    ShowProfilesOnStart := ReadFromIni("config.ini", "General", "ShowProfilesOnStart", True)
    ConvertBool(ShowProfilesOnStart)
    AlwaysOnTop := ReadFromIni("config.ini", "General", "AlwaysOnTop", True)
    ConvertBool(AlwaysOnTop)
    ActiveProfile := ReadFromIni("config.ini", "General", "Last Profile", "Default")
    ReadProfile(ActiveProfile, WinPosX, WinPosY, WinPosW, WinPosH)
    
    Hotkey, IfWinExist, ahk_class POEWindowClass
    LeftWindowHK := ReadFromIni("config.ini", "Hotkey", "Left Window", "F9")
    if LeftWindowHK <>
        Hotkey, %LeftWindowHK%, MoveWindowToLeft
    RightWindowHK := ReadFromIni("config.ini", "Hotkey", "Right Window", "F10")
    if RightWindowHK <>
        Hotkey, %RightWindowHK%, MoveWindowToRight
    Hotkey, IfWinActive, ahk_class POEWindowClass
    PoEWindowHK := ReadFromIni("config.ini", "Hotkey", "PoE Window", "F11")
    if PoEWindowHK <>
        Hotkey, %PoEWindowHK%, MovePoEWindow
    DecreasePoEHeightHK := ReadFromIni("config.ini", "Hotkey", "Decrease PoE Height", "^Up")
    if DecreasePoEHeightHK <>
        Hotkey, %DecreasePoEHeightHK%, DecreasePoEHeight
    IncreasePoEHeightHK := ReadFromIni("config.ini", "Hotkey", "Increase PoE Height", "^Down")
    if IncreasePoEHeightHK <>
        Hotkey, %IncreasePoEHeightHK%, IncreasePoEHeight
    DecreasePoEWidthHK := ReadFromIni("config.ini", "Hotkey", "Decrease PoE Width", "^Left")
    if DecreasePoEWidthHK <>
        Hotkey, %DecreasePoEWidthHK%, DecreasePoEWidth
    IncreasePoEWidthHK := ReadFromIni("config.ini", "Hotkey", "Increase PoE Width", "^Right")
    if IncreasePoEWidthHK <>
        Hotkey, %IncreasePoEWidthHK%, IncreasePoEWidth
    Hotkey, IfWinActive

    if StoreValuesOnExit
        OnExit("ExitFunc")


    if (ClientPath = "ERROR")
    {
        RegRead, ClientPath, HKCU, Software\GrindingGearGames\Path of Exile, InstallLocation
        if ErrorLevel = 1
        {
            ClientPath =
        }
    }
    if (ClientExecuteable = "ERROR")
    {
        if A_Is64bitOS
            ClientExecuteable := "PathOfExile_x64.exe"
        Else
            ClientExecuteable := "PathOfExile.exe"
        SaveValues(true)
    }

    if StartPoE
    {
        RunPoE()
    }
Return

OpenConfig:
    Run %A_ScriptDir%\config.ini
Return

Reload:
Reload

LV_OK:
    Gui, Submit, NoHide
    RowNo := LV_GetNext(0, "Focused")
    LV_GetText(NewProfileName, RowNo)
    WriteProfile(NewProfileName, PosXEdit, PosYEdit, PosWEdit, PosHEdit)
    if (WinPosX <> PosXEdit)
        WinPosX := PosXEdit
    if (WinPosY <> PosYEdit)
        WinPosY := PosYEdit
    if (WinPosW <> PosWEdit)
        WinPosW := PosWEdit
    if (WinPosH <> PosHEdit)
        WinPosH := PosHEdit
    SetNewProfile(NewProfileName, RowNo)
    RunPoE()
Return

AddProfile:
    RowNo := 1
    Number := 0
    Loop, % LV_GetCount()
    {
        LV_GetText(ProfileName,RowNo)
        if InStr(ProfileName, DefaultProfileName)
            Number := SubStr(ProfileName, StrLen(DefaultProfileName)+1)
        RowNo += 1
    }
    Number += 1
    RowNo := LV_Add("Select Focus", DefaultProfileName Number)
    if (RowNo <> 0)
    {
        WriteProfile(DefaultProfileName Number, WinPosX, WinPosY, WinPosW, WinPosH)
        SetNewProfile(DefaultProfileName Number, RowNo)
    }
Return

DeleteProfile:
    RowNo := LV_GetNext(0, "F")
    LV_GetText(ProfileName, RowNo)
    if (ProfileName = ActiveProfile)
        MsgBox, 4112, Error, You can't delete the active profile!
    Else
    {    
        MsgBox, 4388, Delete Profile?, Do you want to delete the profile %ProfileName%?
        IfMsgBox, Yes
        {
            LV_Delete(RowNo)
            IniDelete, config.ini, %ProfileName%
        }
    }
Return

SetDefaultProfile:
    RowNo := LV_GetNext(0, "Focused")
    LV_GetText(NewProfileName, RowNo)
    if (RowNo <> 0)
    {
        SetNewProfile(NewProfileName, RowNo)
    }
Return

SetNewProfile(NewProfileName, RowNo)
{
    global ActiveProfile, WinPosX, WinPosY, WinPosW, WinPosH
    if (NewProfileName <> ActiveProfile)
    {
        ActiveProfile := NewProfileName
        ReadProfile(ActiveProfile, WinPosX, WinPosY, WinPosW, WinPosH)
        GuiControl, , ActiveProfileTxt, %ActiveProfile%
        IniWrite, %ActiveProfile%, config.ini, General, Last Profile
    }
    GoSub, ShowSelectionWindow
}

ProfileLV:
    Critical, On
    if (A_GuiEvent = "DoubleClick")
    {
        GoSub, LV_OK
    }
    Else if (A_GuiEvent == "E")     ;Start editing
    {
        LV_GetText(OldProfileName, A_EventInfo)
    }
    Else if (A_GuiEvent == "e")     ;Ended editing
    {
        LV_GetText(NewProfileName, A_EventInfo)
        if (OldProfileName <> NewProfileName)
        {
            ReadProfile(OldProfileName, PosX, PosY, Width, Height)
            WriteProfile(NewProfileName, PosX, PosY, Width, Height)
            IniDelete, config.ini, %OldProfileName%
            if (OldProfileName = ActiveProfile)
            {
                ActiveProfile := NewProfileName
                IniWrite, %ActiveProfile%, config.ini, General, Last Profile
                GuiControl, , ActiveProfileTxt, %ActiveProfile%
            }
        }
    }
    Else if (A_GuiEvent == "I") AND (ErrorLevel == "SF")
    {
        LV_GetText(ProfileName, A_EventInfo)
        ReadProfile(ProfileName, PosX, PosY, Width, Height)
        GuiControl, , PosXEdit, %PosX%
        GuiControl, , PosYEdit, %PosY%
        GuiControl, , PosWEdit, %Width%
        GuiControl, , PosHEdit, %Height%
    }
Return

ReadProfile(Profile, ByRef PosX, ByRef PosY, ByRef Width, ByRef Height)
{
    IniRead, PosX, config.ini, %Profile%, XPos, % Round(A_ScreenWidth/4)
    IniRead, PosY, config.ini, %Profile%, YPos, 0
    IniRead, Width, config.ini, %Profile%, Width, % Round(A_ScreenWidth/2)
    IniRead, Height, config.ini, %Profile%, Height, % A_ScreenHeight
}

WriteProfile(Profile, PosX, PosY, Width, Height)
{
    if PosX <>
        IniWrite, %PosX%, config.ini, %Profile%, XPos
    if PosY <>
        IniWrite, %PosY%, config.ini, %Profile%, YPos
    if Width <>
        IniWrite, %Width%, config.ini, %Profile%, Width
    if Height <>
        IniWrite, %Height%, config.ini, %Profile%, Height
}

InitSelectionWindow:
    Gui +LastFound
    if AlwaysOnTop
        Gui, +AlwaysOnTop
    Gui, Show, Hide, Select Profile..
    GuiControl, , PosXEdit, %WinPosX%
    GuiControl, , PosYEdit, %WinPosY%
    GuiControl, , PosWEdit, %WinPosW%
    GuiControl, , PosHEdit, %WinPosH%
Return

ShowSelectionWindow:
    Gui, Show
Return

DecreasePoEHeight:
    WinGetPos, WinPosXTemp, WinPosYTemp, WinPosWTemp, WinPosHTemp, ahk_class POEWindowClass
    WinMove, ahk_class POEWindowClass, , %WinPosXTemp%, %WinPosYTemp%, %WinPosWTemp%, % WinPosHTemp-40
Return

IncreasePoEHeight:
    WinGetPos, WinPosXTemp, WinPosYTemp, WinPosWTemp, WinPosHTemp, ahk_class POEWindowClass
    WinMove, ahk_class POEWindowClass, , %WinPosXTemp%, %WinPosYTemp%, %WinPosWTemp%, % WinPosHTemp+40
Return

DecreasePoEWidth:
    WinGetPos, WinPosXTemp, WinPosYTemp, WinPosWTemp, WinPosHTemp, ahk_class POEWindowClass
    WinMove, ahk_class POEWindowClass, , % WinPosXTemp + 40, %WinPosYTemp%, % WinPosWTemp - 80, %WinPosHTemp%
Return

IncreasePoEWidth:
    WinGetPos, WinPosXTemp, WinPosYTemp, WinPosWTemp, WinPosHTemp, ahk_class POEWindowClass
    WinMove, ahk_class POEWindowClass, , % WinPosXTemp - 40, %WinPosYTemp%, % WinPosWTemp + 80, %WinPosHTemp%
Return

MovePoEWindow:
    MovePoEWindow()
Return

MoveWindowToLeft:
    if (A_ScreenWidth - WinPosW > 50)
    {
        WinGet, active_id, ID, A
        WinMove, ahk_id %active_id%, , 0, %WinPosY%, %WinPosX%, %WinPosH%
    }
Return

MoveWindowToRight:
    if (A_ScreenWidth - WinPosW > 50)
    {
        WinGet, active_id, ID, A
        WinMove, ahk_id %active_id%, , % WinPosX+WinPosW, %WinPosY%, % A_ScreenWidth - WinPosX - WinPosW, %WinPosH%
    }
Return

RunPoE:
    RunPoE()
Return

RunPoE()
{
    global ClientPath, ClientExecuteable
    if !WinExist("Path of Exile ahk_class POEWindowClass")
        Run, %ClientPath%%ClientExecuteable%, %ClientPath%  ;PID can't be used as PoE starts another instance
    WinWait, Path of Exile ahk_class POEWindowClass, , 10
    if ErrorLevel = 0
        MovePoEWindow()
}

MovePoEWindow()
{
    global WinPosX, WinPosY, WinPosW, WinPosH
    WinActivate, ahk_class POEWindowClass
    WinMove, ahk_class POEWindowClass, , %WinPosX%, %WinPosY%, %WinPosW%, %WinPosH%
}

SaveCurrentValues:
    SaveValues(False)
Return

SaveValues(FirstTime)
{
    global WinPosX, WinPosY, WinPosW, WinPosH, StartPoE, ClientPath, ClientExecuteable, StoreValuesOnExit, ActiveProfile

    if !FirstTime
        WinGetPos, WinPosX, WinPosY, WinPosW, WinPosH, ahk_class POEWindowClass
    WriteProfile(ActiveProfile, WinPosX, WinPosY, WinPosW, WinPosH)

    if FirstTime
    {
        IniWrite, %StartPoE%, config.ini, General, StartPoE
        IniWrite, %ClientPath%, config.ini, General, ClientPath
        IniWrite, %ClientExecuteable%, config.ini, General, ClientExe
        IniWrite, %StoreValuesOnExit%, config.ini, General, StoreValuesOnExit
    }
}

Exit:
ExitApp

ExitFunc(ExitReason, ExitCode)
{
    SaveValues(False)
}

ReadFromIni(File, Section, Key, Default)
{
    IniRead, ReadValue, %File%, %Section%, %Key%, Not Initialized
    if (ReadValue = "Not Initialized")
    {
        IniWrite, %Default%, %File%, %Section%, %Key%
        ReadValue := Default
    }

    Return %ReadValue%
}

ConvertBool(ByRef Bool)
{
    if Bool is Integer
    {
        if Bool < 0
            Bool := False
        Else if Bool > 1
            Bool := True
    } 
    Else 
    {
        if Format("{1:Ts}",Bool) = "True"
            Bool := True
        Else
            Bool := False
    }
}