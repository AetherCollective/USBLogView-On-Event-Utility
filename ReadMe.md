## Welcome
Download the [Source Code](https://cloud.betaleaf.net:3000/BetaLeaf/USB_Log_View_-_On-Event_Utility/repository/archive.zip?ref=master) and modify ```USB Log Viewer - On-Event Utility.au3``` to meet your needs.
  * It is recommended to install [AutoIt](https://www.autoitscript.com/site/autoit/downloads/) and [SciTE](https://www.autoitscript.com/site/autoit-script-editor/downloads/).

## How to configure
1. Set VID and PID of devices you want to look for. 
     * Each device must have unique variable names.
     * To get these values, Open USBLogView.exe and plug/unplug in your usb device.

Example: 
```
Global $VID_Controller = "045e", $PID_Controller = "02dd"
```
 
2. Register a listener in DeviceActions().
   * You can detect unplug events by changing ```Plug``` to ```Unplug```.
   * Change ```$VID_Controller``` & ```$PID_Controller``` and to match the variable names you set in step 1.
   * Change ```Controller_Plug()``` to match the function you create in step 3.

Example:
```
If $aLogFile[$i][$Event_Type] = "Plug" And $aLogFile[$i][$Vendor_ID] = $VID_Controller And $aLogFile[$i][$Product_ID] = $PID_Controller Then Controller_Plug()
```
  
3. Create the function that does what you need it to do. You will need to know the AutoIt programming language. [View the Documentation](https://www.autoitscript.com/wiki/Documentation)

Example:
```
 ;Opens or focuses RetroArch
 Func Controller_Plug()
	If ProcessExists("RetroArch.exe") Then
		WinActivate("RetroArch")
	Else
		ShellExecute(@AppDataDir & "\RetroArch\retroarch.exe", "", @AppDataDir & "\RetroArch")
	EndIf
 EndFunc   ;==>Controller_Plug
```

4. Once you have everything set up the way you want it, it's recommended to recompile the exe. You can only run the script without recompiling if you have installed AutoIt. 

## How to Recompile
View the [Tutorial](https://www.autoitscript.com/autoit3/docs/intro/compiler.htm).