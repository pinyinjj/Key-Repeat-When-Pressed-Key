#include <Misc.au3>
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <StaticConstants.au3>
#include <ButtonConstants.au3>
#include <SliderConstants.au3>

Opt("GUIOnEventMode", 1)

Global $isRunning = False
Global $Version = "stable v0.1.2"

; 创建 GUI
Global $gui = GUICreate("KPC " & $Version, 120, 100, -1, -1, $WS_POPUP)
WinSetOnTop($gui, "", True) ; 默认窗口置顶

Global $startButton = GUICtrlCreateButton("开始", 10, 10, 100, 30)
Global $opacitySlider = GUICtrlCreateSlider(10, 50, 100, 10)
GUICtrlSetLimit($opacitySlider, 255, 50) ; 设置拖条范围，50 (最透明) 到 255 (最严格)
GUICtrlSetData($opacitySlider, 255) ; 默认透明度

Global $versionLabel = GUICtrlCreateLabel("KPC" & $Version, 10, 82, 100, 10, $SS_CENTER)
GUICtrlSetColor($versionLabel, 0x808080) ; 设置版本号颜色为灰色
GUICtrlSetFont($versionLabel, 8) ; 设置字体大小

GUISetState(@SW_SHOW, $gui)

GUICtrlSetOnEvent($startButton, "OnStartButtonClick")
GUICtrlSetOnEvent($opacitySlider, "OnOpacitySliderChange")
GUISetOnEvent($GUI_EVENT_CLOSE, "OnCloseWindow")

Global $isDragging = False
Global $dragOffsetX, $dragOffsetY

Global $contextMenu = GUICtrlCreateContextMenu()
Global $exitMenuItem = GUICtrlCreateMenuItem("退出", $contextMenu)
GUICtrlSetOnEvent($exitMenuItem, "OnCloseWindow")

; 主循环
While 1
    $msg = GUIGetMsg() ; 获取窗口消息
    Switch $msg
        Case $GUI_EVENT_CLOSE
            OnCloseWindow()
            Exit
        Case $startButton
            OnStartButtonClick()
        Case $opacitySlider
            OnOpacitySliderChange()
    EndSwitch

    ; 检查鼠标拖动
    HandleDrag()

    ; 检查目标窗口是否激活
	If $isRunning Then
		; 检查窗口 "魔兽世界" 是否存在且处于激活状态
		If WinExists("魔兽世界") And WinActive("魔兽世界") Then
			; 监听按键，按下时触发相应的操作
			ListenKeys()
		EndIf
	EndIf

    Sleep(10) ; 防止程序卡死，定期更新 GUI
WEnd

Func ListenKeys()
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
        $key = StringLower($key) ; 转换为小写
        ConsoleWrite("Key Pressed: " & $key & @CRLF)  ; 输出到控制台
        ControlSend("", "", "", $key)
        Sleep(50 + Random(1, 50)) ; 按键间隔时间
    EndIf
EndFunc

Func HandleDrag()
    Local $mousePos = MouseGetPos()
    Local $winPos = WinGetPos($gui)
    Local $sliderPos = ControlGetPos($gui, "", $opacitySlider)
    Local $labelPos = ControlGetPos($gui, "", $versionLabel)

    If _IsPressed("01") Then ; 鼠标左键按下
        If Not $isDragging Then
            ; 检查是否在拖条范围内
            If $mousePos[0] >= $sliderPos[0] + $winPos[0] And $mousePos[0] <= $sliderPos[0] + $winPos[0] + $sliderPos[2] _
                    And $mousePos[1] >= $sliderPos[1] + $winPos[1] And $mousePos[1] <= $sliderPos[1] + $winPos[1] + $sliderPos[3] Then
                Return ; 如果鼠标在拖条范围内，退出函数
            EndIf
			
			; 检查是否在版本号范围内
            If $mousePos[0] >= $labelPos[0] And $mousePos[0] <= $labelPos[0] + $labelPos[2] And $mousePos[1] >= $labelPos[1] And $mousePos[1] <= $labelPos[1] + $labelPos[3] Then
                $isDragging = True
                $dragOffsetX = $mousePos[0] - $winPos[0]
                $dragOffsetY = $mousePos[1] - $winPos[1]
                Return
            EndIf

            ; 检查是否在窗口范围内
            If $mousePos[0] >= $winPos[0] And $mousePos[0] <= $winPos[0] + 120 And $mousePos[1] >= $winPos[1] And $mousePos[1] <= $winPos[1] + 100 Then
                $isDragging = True
                $dragOffsetX = $mousePos[0] - $winPos[0]
                $dragOffsetY = $mousePos[1] - $winPos[1]
            EndIf
        EndIf
    Else
        $isDragging = False
    EndIf

    If $isDragging Then
        $mousePos = MouseGetPos()
        WinMove($gui, "", $mousePos[0] - $dragOffsetX, $mousePos[1] - $dragOffsetY)
    EndIf
EndFunc


Func OnStartButtonClick()
    $isRunning = Not $isRunning
    GUICtrlSetData($startButton, $isRunning ? "停止" : "启动")
    ConsoleWrite("running " & $isRunning & @CRLF)
	
	If $isRunning Then
        ; 改变按钮背景颜色为浅红色
        GUICtrlSetBkColor($startButton, 0xFFC0CB) ; 浅红色 (粉色)
    Else
        ; 恢复默认按钮背景颜色
        GUICtrlSetBkColor($startButton, 0xFFFFFF) ; 白色
    EndIf
	
EndFunc

Func OnOpacitySliderChange()
    Local $opacity = GUICtrlRead($opacitySlider)
    WinSetTrans($gui, "", $opacity)
    ConsoleWrite("Opacity changed to: " & $opacity & @CRLF)
EndFunc

Func OnCloseWindow()
    ; 在窗口关闭时，做些清理工作
    ConsoleWrite("Window closed. Exiting the program." & @CRLF)
    Exit
EndFunc
