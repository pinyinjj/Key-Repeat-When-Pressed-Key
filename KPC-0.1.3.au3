#include <Misc.au3>
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <StaticConstants.au3>
#include <ButtonConstants.au3>

Opt("GUIOnEventMode", 1)

Global $isRunning = False
Global $Version = " v0.1.4"
Global $targetWindowName = "魔兽世界" ; 参数化目标窗口名称
Global $isFixed = False             ; 默认窗口不锁定，可拖动

; 创建 GUI
Global $gui = GUICreate("KPC " & $Version, 120, 100, -1, -1, $WS_POPUP)
WinSetOnTop($gui, "", True) ; 默认窗口置顶

Global $startButton = GUICtrlCreateButton("开始", 10, 10, 100, 30)
Global $versionLabel = GUICtrlCreateLabel("KPC" & $Version, 10, 82, 100, 10, $SS_CENTER)
GUICtrlSetColor($versionLabel, 0x808080) ; 设置版本号颜色为灰色
GUICtrlSetFont($versionLabel, 8)          ; 设置字体大小

GUISetState(@SW_SHOW, $gui)

; 设置圆角效果
Local $aPos = WinGetPos($gui)
Local $iWidth = $aPos[2]
Local $iHeight = $aPos[3]
Local $iRound = 20 ; 圆角半径，可根据需要调整
Local $aRet = DllCall("gdi32.dll", "hwnd", "CreateRoundRectRgn", "int", 0, "int", 0, "int", $iWidth + 1, "int", $iHeight + 1, "int", $iRound, "int", $iRound)
If Not @error And IsArray($aRet) Then
    DllCall("user32.dll", "int", "SetWindowRgn", "hwnd", $gui, "hwnd", $aRet[0], "int", True)
Else
    ConsoleWrite("设置圆角失败" & @CRLF)
EndIf

GUICtrlSetOnEvent($startButton, "OnStartButtonClick")
GUISetOnEvent($GUI_EVENT_CLOSE, "OnCloseWindow")

Global $isDragging = False
Global $dragOffsetX, $dragOffsetY

; 创建右键菜单
Global $contextMenu = GUICtrlCreateContextMenu()

; 透明度菜单项
Global $opacityMenu = GUICtrlCreateMenu("透明度", $contextMenu)
Global $menuOpacityMap[10]
For $i = 1 To 10
    $menuOpacityMap[$i - 1] = GUICtrlCreateMenuItem(($i * 10) & "%", $opacityMenu)
    GUICtrlSetOnEvent($menuOpacityMap[$i - 1], "OnOpacityMenuSelect")
Next

; 锁定窗口菜单项（初始状态：未锁定，不打勾）
Global $fixedMenuItem = GUICtrlCreateMenuItem("锁定窗口", $contextMenu)
GUICtrlSetOnEvent($fixedMenuItem, "OnFixedMenuSelect")

; 退出菜单项
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
    EndSwitch

    ; 如果窗口未锁定，则允许拖拽移动
    If Not $isFixed Then
        HandleDrag()
    EndIf
	
    ; 检查目标窗口是否存在且处于激活状态，决定是否置顶窗口
    If WinExists($targetWindowName) And WinActive($targetWindowName) Then
        WinSetOnTop($gui, "", True)
    Else
        WinSetOnTop($gui, "", False)
    EndIf

    ; 仅当运行状态时监听按键
    If $isRunning Then
        ListenKeys()
    EndIf

    Sleep(10) ; 防止程序卡死，定期更新 GUI
WEnd

Func ListenKeys()
    Local $key = "" ; 避免覆盖问题

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

    If _IsPressed("01") Then ; 鼠标左键按下
        If Not $isDragging Then
            ; 检查是否在窗口范围内
            If $mousePos[0] >= $winPos[0] And $mousePos[0] <= $winPos[0] + 120 And _
               $mousePos[1] >= $winPos[1] And $mousePos[1] <= $winPos[1] + 100 Then
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
        GUICtrlSetBkColor($startButton, 0xFFC0CB)
    Else
        ; 恢复默认按钮背景颜色
        GUICtrlSetBkColor($startButton, 0xFFFFFF)
    EndIf
EndFunc

Func OnOpacityMenuSelect()
    Local $id = @GUI_CTRLID
    For $i = 0 To UBound($menuOpacityMap) - 1
        If $menuOpacityMap[$i] = $id Then
            Local $opacity = (10 * ($i + 1)) * 2.55
            ConsoleWrite("Selected Opacity: " & $opacity & @CRLF)
            WinSetTrans($gui, "", $opacity)
            ExitLoop
        EndIf
    Next
EndFunc

Func OnFixedMenuSelect()
    ; 切换锁定状态
    $isFixed = Not $isFixed
    If $isFixed Then
        GUICtrlSetData($fixedMenuItem, "锁定窗口✔")
        ConsoleWrite("窗口已锁定，不可移动" & @CRLF)
    Else
        GUICtrlSetData($fixedMenuItem, "锁定窗口")
        ConsoleWrite("窗口可移动" & @CRLF)
    EndIf
EndFunc

Func OnCloseWindow()
    ConsoleWrite("Window closed. Exiting the program." & @CRLF)
    Exit
EndFunc
