# PoE-Screen-Manager
A small tool to start PoE in a specified position. Especially useful for widescreen monitors if you want to use the space left or right of the main window.

It will create a new config-file in the folder it is launched and doesn't find a config already. The ClientPath and Exe-File will be read from Registry, but can be changed afterwards.
Here is an example how it may look like:

> [General]  
> XPos=0  
> YPos=0  
> Width=2440  
> Height=1390  
> StartPoE=false  
> ClientPath=S:\  
> ClientExe=PathOfExile_x64.exe  
> StoreValuesOnExit=false  
>  
> [Hotkey]  
> Left Window=  
> Right Window=F10  
> PoE Window=F11  
> Decrease PoE Height=^Up  
> Increase PoE Height=^Down  
> Decrease PoE Width=^Left  
> Increase PoE Width=^Right  

With this setup the tool will start without launching PoE directly. You can set "StartPoE" to "True" to do so. You can also start PoE from the tray icon by selecting the option of double clicking the icon.  
On my monitor (3440x1440) PoE will start leaving the right side (1000px) free and also shows the Windows Status Bar on the bottom.  
You can change the size of the PoE-Window using the last four hotkeys (^Up e.g. means Ctrl-Up) and save the values via tray icon. If "StoreValuesOnExit" is set the tool will save the current position of the PoE-Window if it's launched when the tool is closed.  
The "PoE Window" Hotkey will reset the position to the last saved state if you've changed the size or moved it.  
  
The Hotkeys for "Left Window" or "Right Window" will work for any active window and will be moved to the left or right of an existing PoE client.  
This way you can easily move utility windows to one side like a browser or PoB. In my case I'd just click on PoB and press "F10".  
  
All Hotkeys can be disabled by leaving the clear (like you can see for "Left Window").
Please check out [this help](https://www.autohotkey.com/docs/Hotkeys.htm) to see how to setup Hotkeys the way you want.
