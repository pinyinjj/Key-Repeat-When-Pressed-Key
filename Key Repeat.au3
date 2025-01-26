#include <Misc.au3>
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <StaticConstants.au3>
#include <ButtonConstants.au3>

Opt("GUIOnEventMode", 1)

Global $isRunning = False
Global $isAlwaysOnTop = False
Global $key = ""  ; 用于保存按键

; 创建 GUI
Global $gui = GUICreate("KPC unstable", 150, 80, -1, -1, BitOR($WS_CAPTION, $WS_SYSMENU))
Global $startButton = GUICtrlCreateButton("启动", 25, 20, 50, 30)
Global $alwaysOnTopCheckbox = GUICtrlCreateCheckbox("置顶", 90, 25, 50, 20)

GUISetState(@SW_SHOW, $gui)

; 绑定按钮点击事件
GUICtrlSetOnEvent($startButton, "OnStartButtonClick")
GUICtrlSetOnEvent($alwaysOnTopCheckbox, "OnAlwaysOnTopCheckbox")
GUISetOnEvent($GUI_EVENT_CLOSE, "OnCloseWindow")
; 主循环
While 1
    ; 获取事件，确保界面能响应
    $msg = GUIGetMsg()
    If $msg = $GUI_EVENT_CLOSE Then Exit

    ; 按键监听
    If $isRunning Then
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
            $key = StringLower($key) ; 转换为小写
            
            While _IsPressed("31") Or _IsPressed("32") Or _IsPressed("33") Or _IsPressed("34") Or _IsPressed("35") Or _
              _IsPressed("36") Or _IsPressed("51") Or _IsPressed("45") Or _IsPressed("52") Or _IsPressed("54") Or _IsPressed("46")
				ConsoleWrite("Key Pressed: " & $key & @CRLF)  ; 输出到控制台
                ControlSend("", "", "", $key)
                Sleep(50 + Random(1, 50)) ; 按键间隔时间
            WEnd
        EndIf
    EndIf

    Sleep(10) ; 防止程序卡死，定期更新 GUI
WEnd

; 启动按钮点击事件
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