#include <Misc.au3>
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <StaticConstants.au3>
#include <ButtonConstants.au3>

Global $isRunning = False
Global $isAlwaysOnTop = False
Global $Version = "stable v0.01"
; 创建 GUI
Global $gui = GUICreate("KPC " & $Version, 150, 80, -1, -1, BitOR($WS_CAPTION, $WS_SYSMENU))
Global $startButton = GUICtrlCreateButton("启动", 25, 20, 50, 30)
Global $alwaysOnTopCheckbox = GUICtrlCreateCheckbox("置顶", 90, 25, 50, 20)

GUISetState(@SW_SHOW, $gui)

GUICtrlSetOnEvent($startButton, "OnStartButtonClick")
GUICtrlSetOnEvent($alwaysOnTopCheckbox, "OnAlwaysOnTopCheckbox")
GUISetOnEvent($GUI_EVENT_CLOSE, "OnCloseWindow")

; 主循环
While 1
    Switch GUIGetMsg()
        Case $GUI_EVENT_CLOSE
            Exit
        Case $startButton
            $isRunning = Not $isRunning
            GUICtrlSetData($startButton, $isRunning ? "停止" : "启动")
			ConsoleWrite("running "& $isRunning & @CRLF)
        Case $alwaysOnTopCheckbox
            $isAlwaysOnTop = GUICtrlRead($alwaysOnTopCheckbox) = $GUI_CHECKED
            WinSetOnTop($gui, "", $isAlwaysOnTop)
    EndSwitch

    ; 检查目标窗口是否激活
    If $isRunning Then
        ; 监听按键，按下时触发相应的操作
        While $isRunning
            Local $key = "" ; Declare $key here to avoid overwriting issues

			If _IsPressed("31") Then 
				$key = "1"  ; 1 key
			ElseIf _IsPressed("32") Then 
				$key = "2"  ; 2 key
			ElseIf _IsPressed("33") Then 
				$key = "3"  ; 3 key
			ElseIf _IsPressed("34") Then 
				$key = "4"  ; 4 key
			ElseIf _IsPressed("35") Then 
				$key = "5"  ; 5 key
			ElseIf _IsPressed("36") Then 
				$key = "6"  ; 6 key
			ElseIf _IsPressed("51") Then 
				$key = "Q"  ; Q key
			ElseIf _IsPressed("45") Then 
				$key = "E"  ; E key
			ElseIf _IsPressed("52") Then 
				$key = "R"  ; R key
			ElseIf _IsPressed("54") Then 
				$key = "T"  ; T key
			ElseIf _IsPressed("46") Then 
				$key = "F"  ; F key
			EndIf

            If $key <> "" Then
                $key = StringLower($key) ; Convert to lowercase
                ConsoleWrite("Key Pressed: " & $key & @CRLF)  ; 输出到控制台
                ControlSend("", "", "", $key)
                Sleep(50 + Random(1, 50)) ; 按键间隔时间
            EndIf
			Sleep(10)
        WEnd
		Sleep(10)
    EndIf
WEnd

Func OnStartButtonClick()
    $isRunning = Not $isRunning
    GUICtrlSetData($startButton, $isRunning ? "停止" : "启动")
    ConsoleWrite("running " & $isRunning & @CRLF)
EndFunc

; 置顶复选框点击事件
Func OnAlwaysOnTopCheckbox()
    $isAlwaysOnTop = GUICtrlRead($alwaysOnTopCheckbox) = $GUI_CHECKED
    WinSetOnTop($gui, "", $isAlwaysOnTop)
EndFunc

Func OnCloseWindow()
    ; 在窗口关闭时，做一些清理工作
    ConsoleWrite("Window closed. Exiting the program." & @CRLF)
    Exit
EndFunc
