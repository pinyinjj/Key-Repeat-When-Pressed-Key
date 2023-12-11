#include <Misc.au3>

Global $isKeyPressed = False

HotKeySet("1", "ToggleKeyPress")
HotKeySet("2", "ToggleKeyPress")
HotKeySet("3", "ToggleKeyPress")
HotKeySet("4", "ToggleKeyPress")
HotKeySet("5", "ToggleKeyPress")
HotKeySet("6", "ToggleKeyPress")
HotKeySet("q", "ToggleKeyPress")
HotKeySet("e", "ToggleKeyPress")
HotKeySet("r", "ToggleKeyPress")
HotKeySet("t", "ToggleKeyPress")
HotKeySet("f", "ToggleKeyPress")

While 1
    If WinActive("魔兽世界") Then
        If $isKeyPressed Then
            While _IsPressed("31") Or _IsPressed("32") Or _IsPressed("33") Or _IsPressed("34") Or _IsPressed("35") Or _
                  _IsPressed("36") Or _IsPressed("51") Or _IsPressed("45") Or _IsPressed("52") Or _IsPressed("54") Or _IsPressed("46")
                Local $key = StringLower(@HotKeyPressed)
                ControlSend("", "", "", $key)
                Sleep(10)
            WEnd
            $isKeyPressed = False
        EndIf
    Else
        $isKeyPressed = False
    EndIf

    Sleep(10)
WEnd

Func ToggleKeyPress()
    $isKeyPressed = True
EndFunc
