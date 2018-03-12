#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=icon.ico
#AutoIt3Wrapper_Compression=4
#AutoIt3Wrapper_Res_Comment=Edit the script to meet your needs, then recompile. https://www.autoitscript.com/autoit3/docs/intro/compiler.htm
#AutoIt3Wrapper_Res_Description=Listens for USB plug/unplug events and does stuff.
#AutoIt3Wrapper_Res_Fileversion=0.1.0.6
#AutoIt3Wrapper_Res_Fileversion_AutoIncrement=y
#AutoIt3Wrapper_Res_LegalCopyright=Copyright Jeff Savage (BetaLeaf) for script & Nirsoft for USBLogView & Nircmdc
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=icon.ico
#AutoIt3Wrapper_Compression=4
#AutoIt3Wrapper_Res_Comment=Edit the script to meet your needs, then recompile. https://www.autoitscript.com/autoit3/docs/intro/compiler.htm
#AutoIt3Wrapper_Res_Description=Listens for USB plug/unplug events and does stuff.
#AutoIt3Wrapper_Res_Fileversion=0.1.0.6
#AutoIt3Wrapper_Res_Fileversion_AutoIncrement=y
#AutoIt3Wrapper_Res_LegalCopyright=Copyright Jeff Savage (BetaLeaf) for script & Nirsoft for USBLogView & Nircmdc
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#include <AutoItConstants.au3>
#include <Array.au3>
#include <File.au3>
FileChangeDir(@ScriptDir)
if Not FileExists("USBLogView\USBLogView.exe") then
	$FirstRun=True
Else
	$FirstRun=False
EndIf
FileInstall("USB Log Viewer - On-Event Utility.au3", @ScriptDir & "\USB Log Viewer - On-Event Utility.au3", 0) ;required to compile.
FileInstall("icon.ico", @ScriptDir & "\icon.ico", 0) ;required to compile with icon.
FileInstall("ReadMe.md", @ScriptDir & "\ReadMe.md", 0) ;recommended to read.
FileInstall("LICENSE", @ScriptDir & "\LICENSE", 0) ;recommended to read.
DirCreate(@ScriptDir&"\USBLogView")
FileInstall("USBLogView\USBLogView.exe", @ScriptDir & "\USBLogView\USBLogView.exe", 0) ;required to detect usb device plug/unplug
FileInstall("USBLogView\USBLogView.cfg", @ScriptDir & "\USBLogView\USBLogView.cfg", 0) ;recommended to run USBLogView silently.
FileInstall("USBLogView\USBLogView.chm", @ScriptDir & "\USBLogView\USBLogView.chm", 0) ;required to redistribute
FileInstall("USBLogView\readme.txt", @ScriptDir & "\readme.txt", 0) ;required to redistribute
FileInstall("USBLogView\license.txt", @ScriptDir & "\license.txt", 0) ;required to redistribute
DirCreate(@ScriptDir&"\NirCMD")
FileInstall("NirCMD\nircmd.exe", @ScriptDir & "\NirCMD\nircmdc.exe", 0) ;required to redistribute
FileInstall("NirCMD\nircmdc.exe", @ScriptDir &"\NirCMD\nircmdc.exe", 0) ;required to set default audio device.
FileInstall("NirCMD\NirCmd.chm", @ScriptDir & "\NirCMD\NirCmd.chm", 0) ;required to redistribute
FileInstall("NirCMD\license.txt", @ScriptDir & "\NirCMD\license.txt", 0) ;required to redistribute
if $FirstRun = True then Exit; First time script was ran, so extract files for recompile, then exit.

;Starts this script with Windows
If RegWrite("HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Run", "USBLogView: On-Event Utility", "REG_SZ", '"' & @ScriptFullPath & '"') = 0 Then MsgBox(0, "USBLogView: On-Event Utility", "Could not add to Window's Startup. Error: " & @error)

;Devices to look for
Global $VID_Controller = "045e", $PID_Controller = "02dd"
Global $VID_Controller_Audio = "045e", $PID_Controller_Audio = "02e4"

;Starts USBLogView
If Not ProcessExists("USBLogView.exe") Then ShellExecute("USBLogView.exe", "", @ScriptDir&"\USBLogView")

;Set Log file path
Global Const $LogFile = @ScriptDir & "\USBLogView\Log.csv"

;Clear Log if it exists. A large Log file affects script performance.
FileDelete($LogFile)

;Wait for Log file to exist
Do
	$LogExists = FileExists($LogFile)
Until $LogExists = True

;Read Log file
Global $aLogFile
$hLogFile = FileOpen($LogFile, 0)
_FileReadToArray($hLogFile, $aLogFile, "", ",")
FileClose($hLogFile)
;Declare important parser variables
Global $Event_Type, $Vendor_ID, $Product_ID, $Last_Index

;Get indexes of important columns
For $i = 0 To UBound($aLogFile, $UBOUND_COLUMNS) - 1
	If StringInStr($aLogFile[0][$i], "Event Type") = True Then $Event_Type = $i
	If StringInStr($aLogFile[0][$i], "Vendor ID") = True Then $Vendor_ID = $i
	If StringInStr($aLogFile[0][$i], "Product ID") = True Then $Product_ID = $i
Next
$Last_Index = 0

;Check log every X milliseconds. Default = 250 (Second value)
AdlibRegister("Parse", 250)

;idle sleep
While 1
	Sleep(60000)
WEnd

Func Parse()
	;Read Log File
	$hLogFile = FileOpen($LogFile, 0)
	_FileReadToArray($hLogFile, $aLogFile, "", ",")
	FileClose($hLogFile)

	;if last index is less than current index, log was updated and needs reparsed.
	If $Last_Index < UBound($aLogFile, $UBOUND_ROWS) - 1 Then

		;reparse only since last index
		For $i = $Last_Index + 1 To UBound($aLogFile, $UBOUND_ROWS) - 1
			DeviceActions($i)
		Next

		;All new entries parsed, so update last index value.
		$Last_Index = UBound($aLogFile, $UBOUND_ROWS) - 1
	EndIf
EndFunc   ;==>Parse

Func DeviceActions($i)
	;if Xbox One Wireless Controller was plugged in, go to Controller_Plug()
	If $aLogFile[$i][$Event_Type] = "Plug" And $aLogFile[$i][$Vendor_ID] = $VID_Controller And $aLogFile[$i][$Product_ID] = $PID_Controller Then Controller_Plug()

	;if Headphones was plugged in to Xbox One Wireless Controller, go to Controller_Audio_Plug()
	If $aLogFile[$i][$Event_Type] = "Plug" And $aLogFile[$i][$Vendor_ID] = $VID_Controller_Audio And $aLogFile[$i][$Product_ID] = $PID_Controller_Audio Then Controller_Audio_Plug()
EndFunc   ;==>DeviceActions

;Opens or focuses RetroArch
Func Controller_Plug()
	If ProcessExists("RetroArch.exe") Then
		WinActivate("RetroArch")
	Else
		ShellExecute(@AppDataDir & "\RetroArch\retroarch.exe", "", @AppDataDir & "\RetroArch")
	EndIf
EndFunc   ;==>Controller_Plug

;Makes this audio device the default so windows redirects all audio to the headset.
Func Controller_Audio_Plug()
	For $i = 0 To 2
		ShellExecute(@ScriptDir & "\NirCMD\NIRCMDC.exe", 'setdefaultsounddevice "Headphones" ' & $i & '"', @ScriptDir, "", @SW_HIDE) ;Set Default Playback Device to Slot $Slot.
	Next
	For $i = 0 To 2
		ShellExecute(@ScriptDir & "\NirCMD\NIRCMDC.exe", 'setdefaultsounddevice "Headset Microphone" ' & $i & '"', @ScriptDir, "", @SW_HIDE) ;Set Default Recording Device to Slot $Slot.
	Next
EndFunc   ;==>Controller_Audio_Plug
