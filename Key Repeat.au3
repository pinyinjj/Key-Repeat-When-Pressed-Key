#include <Misc.au3>
#include <MsgBoxConstants.au3>
#include <WinAPI.au3>



; initialize
Local $hDLL = DllOpen("user32.dll")
Send("{SCROLLLOCK on}")
Local $activate = True
HotKeySet("{SCROLLLOCK}", "TogglePause")


; toggle activate
Func TogglePause()
		If $activate Then
			$activate = Not $activate
		Else
			$activate = True
		EndIf
        While Not $activate
                Sleep(100)
                ToolTip('Script is "Paused"', 0, 0)
        WEnd
        ToolTip("")
EndFunc   ;==>TogglePause


<<<<<<< HEAD
$gamename = "World of Warcraft"
$hDLL = DllOpen("user32.dll")

Global $isGameActive = False ; Flag to track the game window focus state
Global $pauseScript = False

While 1
    Sleep(100)

    ; Get Scroll Lock state
    $scrollLockState = DllCall("user32.dll", "int", "GetKeyState", "int", 0x91)
    $scrollLockState = BitAND($scrollLockState[0], 1)

    ; Check Scroll Lock key
    If $scrollLockState Then
        ; Scroll Lock is pressed, pause the script
        $pauseScript = True
        ConsoleWrite("Scroll Lock pressed - Pause script" & @CRLF)
    Else
        ; Scroll Lock is released, resume the script
        $pauseScript = False
        ConsoleWrite("Scroll Lock released - Resume script" & @CRLF)
    EndIf

    ; If Scroll Lock is not enabled, pause the script
    If Not $scrollLockState Then
        $pauseScript = True
    EndIf

    ; Introduce a small delay to allow Scroll Lock state to stabilize
    Sleep(50)

    ; Check game window focus state
    If WinActive($gamename) Then
        If Not $isGameActive Then
            ; Resuming script after regaining focus from being inactive
            $isGameActive = True
            $pauseScript = False
        EndIf

        ; Code to execute when the game window is active
        If _IsPressed("31", $hDLL) Then
            Send('1')
        ElseIf _IsPressed("32", $hDLL) Then
            Send('2')
        ;... (Add other key press checks as needed)
        EndIf
    ElseIf Not WinActive($gamename) Then
        If $isGameActive Then
            ; Pausing script when the game window loses focus
            $isGameActive = False
        EndIf
        ; If the game window is inactive, pause the script and turn off Scroll Lock
        $pauseScript = True
        Send("{SCROLLLOCK off}")
    EndIf

    ; If the script is paused, perform additional actions (e.g., output debug information)
    If $pauseScript Then
        ConsoleWrite("Script paused" & @CRLF)
        ; Additional actions during script pause can be added here
    EndIf
WEnd

DllClose($hDLL)
=======


While 1
	Sleep(100)
	If $activate Then
		If _IsPressed("31", $hDLL) Then
			Send('1')
		ElseIf _IsPressed("32", $hDLL) Then
			Send('2')
		ElseIf _IsPressed("33", $hDLL) Then
			Send('3')
		ElseIf _IsPressed("34", $hDLL) Then
			Send('4')
		ElseIf _IsPressed("35", $hDLL) Then
			Send('5')
		ElseIf _IsPressed("36", $hDLL) Then
			Send('6')
		ElseIf _IsPressed("51", $hDLL) Then
			Send('q')
		ElseIf _IsPressed("45", $hDLL) Then
			Send('e')
		ElseIf _IsPressed("52", $hDLL) Then
			Send('r')
		ElseIf _IsPressed("54", $hDLL) Then
			Send('t')
		ElseIf _IsPressed("46", $hDLL) Then
			Send('f')
		EndIf
	EndIf
WEnd







>>>>>>> parent of c1752ad (Update Key Repeat.au3)
