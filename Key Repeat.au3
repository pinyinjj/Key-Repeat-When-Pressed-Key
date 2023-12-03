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







