#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#SingleInstance, force
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

Menu, Tray, NoStandard
Menu, Tray, Icon, Display.dll, 1
Menu, Tray, Add, Start PoE, RunPoE
Menu, Tray, Add, Select Profile, ShowSelectionWindow
Menu, Tray, Add, Open Config, OpenConfig
Menu, Tray, Add, Reload, Reload
Menu, Tray, Add, Save Current Values, SaveCurrentValues
Menu, Tray, Add, Exit, Exit
Menu, Tray, Default, Start PoE

GoSub, InitSettings

Gui, Font, Bold
Gui, +AlwaysonTop +LastFound -MinimizeBox -MaximizeBox
Gui, Add, Text, section x10 y10, Active Profile:
Gui, Add, Edit, x+5 ys-3 w100 ReadOnly vActiveProfileTxt, %ActiveProfile%
Gui, Add, ListView, section xs+0 y+5 w225 -LV0x10 Sort -ReadOnly -Multi AltSubmit vProfileLV gProfileLV, Profile
Gui, Add, Text, xs+0 y+8 section, X
Gui, Add, Edit, x+3 ys-3 w40 Limit4 Number vPosXEdit, 
Gui, Add, Text, x+5 ys+0, Y
Gui, Add, Edit, x+3 ys-3 w40 Limit4 Number vPosYEdit, 
Gui, Add, Text, x+5 ys+0, W
Gui, Add, Edit, x+3 ys-3 w40 Limit4 Number vPosWEdit, 
Gui, Add, Text, x+5 ys+0, H
Gui, Add, Edit, x+3 ys-3 w40 Limit4 Number vPosHEdit, 
Gui, Add, Button, xs+0 y+10 gAddProfile, Add Profile
Gui, Add, Button, x+5 yp+0 gDeleteProfile, Delete Profile
Gui, Add, Button, x+0 yp+0 w1 Hidden Default gLV_OK, OK
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
GoSub, InitSelectionWindow
;GoSub, ShowSelectionWindow
Return

InitSettings:
    DefaultProfileName := "New Profile "
    IniRead, StartPoE, config.ini, General, StartPoE, False
    IniRead, ClientPath, config.ini, General, ClientPath
    IniRead, ClientExecuteable, config.ini, General, ClientExe
    IniRead, StoreValuesOnExit, config.ini, General, StoreValuesOnExit, True
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

    if Format("{1:Ts}",StoreValuesOnExit) = "True"
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

    if Format("{1:Ts}",StartPoE) = "True"
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
    RunPoE()
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
Gui, Show, Hide, Select Profile..
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