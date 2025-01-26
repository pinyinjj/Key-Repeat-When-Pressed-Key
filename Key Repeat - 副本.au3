#include <Misc.au3>
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <StaticConstants.au3>
#include <ButtonConstants.au3>

Global $isRunning = False
Global $isAlwaysOnTop = False
;Global $isKeyPressed = False

; 创建 GUI
Global $gui = GUICreate("KeyPress Controller", 150, 80, -1, -1, BitOR($WS_CAPTION, $WS_SYSMENU))
Global $startButton = GUICtrlCreateButton("启动", 25, 20, 50, 30)
Global $alwaysOnTopCheckbox = GUICtrlCreateCheckbox("置顶", 90, 25, 50, 20)

GUISetState(@SW_SHOW, $gui)

;Func SetHotKeys()
    ;HotKeySet("1", "ToggleKeyPress")
    ;HotKeySet("2", "ToggleKeyPress")
    ;HotKeySet("3", "ToggleKeyPress")
    ;HotKeySet("4", "ToggleKeyPress")
    ;HotKeySet("5", "ToggleKeyPress")
    ;HotKeySet("6", "ToggleKeyPress")
;EndFunc


; 主循环
While 1
    Switch GUIGetMsg()
        Case $GUI_EVENT_CLOSE
            Exit
        Case $startButton
            $isRunning = Not $isRunning
			;SetHotKeys() ; 启动时重新绑定热键
            GUICtrlSetData($startButton, $isRunning ? "停止" : "启动")
        Case $alwaysOnTopCheckbox
            $isAlwaysOnTop = GUICtrlRead($alwaysOnTopCheckbox) = $GUI_CHECKED
            WinSetOnTop($gui, "", $isAlwaysOnTop)
    EndSwitch

    ; 检查目标窗口是否激活
    If $isRunning Then
        ;If $isKeyPressed Then
		While _IsPressed("31") Or _IsPressed("32") Or _IsPressed("33") Or _IsPressed("34") Or _IsPressed("35") Or _
			_IsPressed("36") Or _IsPressed("51") Or _IsPressed("45") Or _IsPressed("52") Or _IsPressed("54") Or _IsPressed("46")
			Local $key = StringLower(@HotKeyPressed)
			ControlSend("", "", "", $key)
			Sleep(50 + Random(1, 100))
		WEnd
			;$isKeyPressed = False
		;EndIf
	EndIf
WEnd



;Func ToggleKeyPress()
;    $isKeyPressed = True
;EndFunc

