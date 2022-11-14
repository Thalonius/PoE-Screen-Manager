#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#SingleInstance, force
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

IniRead, WinPosX, config.ini, General, XPos, % Round(A_ScreenWidth/4)
IniRead, WinPosY, config.ini, General, YPos, 0
IniRead, WinPosW, config.ini, General, Width, % Round(A_ScreenWidth/2)
IniRead, WinPosH, config.ini, General, Height, % A_ScreenHeight
IniRead, StartPoE, config.ini, General, StartPoE, False
IniRead, ClientPath, config.ini, General, ClientPath
IniRead, ClientExecuteable, config.ini, General, ClientExe
IniRead, StoreValuesOnExit, config.ini, General, StoreValuesOnExit, True

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

Menu, Tray, Icon, Display.dll, 1
Menu, Tray, Add, Start PoE, RunPoE
Menu, Tray, Add, Save Current Values, SaveCurrentValues

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
WinGet, active_id, ID, A
WinMove, ahk_id %active_id%, , 0, 0, %WinPosX%, %A_ScreenHeight%
Return

MoveWindowToRight:
WinGet, active_id, ID, A
WinMove, ahk_id %active_id%, , % WinPosX+WinPosW, 0, % A_ScreenWidth - WinPosX - WinPosW, %A_ScreenHeight%
Return

RunPoE:
RunPoE()
Return

RunPoE()
{
    global ClientPath, ClientExecuteable
    Run, %ClientPath%%ClientExecuteable%, %ClientPath%  ;PID can't be used as PoE starts another instance
    WinWait, Path of Exile ahk_class POEWindowClass, , 10 ;, , Path of Exile - Patch Note
    if ErrorLevel = 0
        MovePoEWindow()
}

MovePoEWindow()
{
    global WinPosX, WinPosY, WinPosW, WinPosH
    WinMove, ahk_class POEWindowClass, , %WinPosX%, %WinPosY%, %WinPosW%, %WinPosH%
}

SaveCurrentValues:
SaveValues(False)
Return

SaveValues(FirstTime)
{
    global WinPosX, WinPosY, WinPosW, WinPosH, StartPoE, ClientPath, ClientExecuteable, StoreValuesOnExit

    if !FirstTime
        WinGetPos, WinPosX, WinPosY, WinPosW, WinPosH, ahk_class POEWindowClass
    if WinPosX <>
        IniWrite, %WinPosX%, config.ini, General, XPos
    if WinPosY <>
        IniWrite, %WinPosY%, config.ini, General, YPos
    if WinPosW <>
        IniWrite, %WinPosW%, config.ini, General, Width
    if WinPosH <>
        IniWrite, %WinPosH%, config.ini, General, Height
    if FirstTime
    {
        IniWrite, %StartPoE%, config.ini, General, StartPoE
        IniWrite, %ClientPath%, config.ini, General, ClientPath
        IniWrite, %ClientExecuteable%, config.ini, General, ClientExe
        IniWrite, %StoreValuesOnExit%, config.ini, General, StoreValuesOnExit
    }
}

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