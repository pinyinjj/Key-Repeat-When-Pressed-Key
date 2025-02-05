#include <Misc.au3>
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <StaticConstants.au3>
#include <ButtonConstants.au3>
#NoTrayIcon
#AutoIt3Wrapper_Icon=icon.ico

Opt("WinTitleMatchMode", 4)
Opt("GUIOnEventMode", 1)


; --- version ---
Global $Version = " v0.1.10"

; --- window ---
Global $targetWindowName = "魔兽世界"

Global $isRunning = False
; 在全局变量区添加一个定时器变量，用于计算颜色变化的时间
Global $g_colorTimer = TimerInit()
Global $isFixed = False             ; 默认窗口不锁定，可拖动

;-----------------------------------------------------------
; 全局变量：当前颜色（浮点数用于平滑过渡）及目标颜色
;-----------------------------------------------------------
Global $currR = 255, $currG = 255, $currB = 255
Global $targetR = Random(0, 255, 1), $targetG = Random(0, 255, 1), $targetB = Random(0, 255, 1)
; 颜色过渡因子（可调，值越大变化越快）
Global $colorTransitionFactor = 0.3

; --- 新增全局计时器变量，用于实现按键重复发送 ---
Global $g_TimerKey1 = 0
Global $g_TimerKey2 = 0
Global $g_TimerKey3 = 0
Global $g_TimerKey4 = 0
Global $g_TimerKey5 = 0
Global $g_TimerKey6 = 0
Global $g_TimerKeyQ = 0
Global $g_TimerKeyE = 0
Global $g_TimerKeyR = 0
Global $g_TimerKeyT = 0
Global $g_TimerKeyF = 0

; 重复发送间隔（毫秒）
Global $repeatDelay = 100

; --- 增加数字键的 Shift 组合标志 ---
Global $g_bShift1Active = False
Global $g_bShift2Active = False
Global $g_bShift3Active = False
Global $g_bShift4Active = False
Global $g_bShift5Active = False
Global $g_bShift6Active = False

; --- 创建 GUI ---
Global $gui = GUICreate("KPC " & $Version, 100, 80, -1, -1, $WS_POPUP, BitOR($WS_EX_TOPMOST, 0x02000000)) 
WinSetOnTop($gui, "", True) ; 默认窗口置顶
Global $startButton = GUICtrlCreateButton("我 爱 罗", 10, 10, 80, 30)
Global $versionLabel = GUICtrlCreateLabel("KPC" & $Version, 0, 60, 100, 10, $SS_CENTER)
GUICtrlSetColor($versionLabel, 0x808080) ; 设置版本号颜色为灰色
GUICtrlSetFont($versionLabel, 8)          ; 设置字体大小
GUISetIcon(@ScriptDir & "\icon.ico", $gui)
GUISetState(@SW_SHOW, $gui)

; --- 设置圆角效果 ---
Local $aPos = WinGetPos($gui)
Local $iWidth = $aPos[2]
Local $iHeight = $aPos[3]
Local $iRound = 30; 圆角半径，可根据需要调整
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

; --- 创建右键菜单 ---
Global $contextMenu = GUICtrlCreateContextMenu()

; 透明度菜单项
Global $opacityMenu = GUICtrlCreateMenu("透明度", $contextMenu)
Global $menuOpacityMap[10]

;-------------------------------
; 初始化透明度菜单项，默认勾上 100%
;-------------------------------
For $i = 1 To 10
    Local $num = ($i * 10) & "%"   ; 例如 "10%", "20%"…… "100%"
    If $i = 10 Then
        ; 默认“100%”选项前加“√　”，并设置主窗口透明度为 255（即 100%）
        $menuOpacityMap[$i - 1] = GUICtrlCreateMenuItem("✔" & $num, $opacityMenu)
        WinSetTrans($gui, "", 255)
    Else
        $menuOpacityMap[$i - 1] = GUICtrlCreateMenuItem("     " & $num, $opacityMenu)
    EndIf
    GUICtrlSetOnEvent($menuOpacityMap[$i - 1], "OnOpacityMenuSelect")
Next


; 锁定窗口菜单项（初始状态：未锁定，不打勾）
Global $fixedMenuItem = GUICtrlCreateMenuItem("锁定窗口", $contextMenu)
GUICtrlSetOnEvent($fixedMenuItem, "OnFixedMenuSelect")

; 退出菜单项
Global $exitMenuItem = GUICtrlCreateMenuItem("退出", $contextMenu)
GUICtrlSetOnEvent($exitMenuItem, "OnCloseWindow")

; --- 主循环 ---
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
	
	If WinExists($targetWindowName) And WinActive($targetWindowName) Then
		WinSetOnTop($gui, "", True)
	Else
		WinSetOnTop($gui, "", False)
	EndIf

    ; 仅当运行状态时监听按键
    If $isRunning Then
        ListenKeys()
    EndIf
	
	UpdateButtonColor()
    Sleep(10) ; 防止程序卡死，定期更新 GUI
WEnd

;------------------------------------------------------------------
; 数字键“1”的处理（虚拟键码 "31"）
; 当检测到数字键"1"同时Shift按下时，进入Shift+1模式：首次发送{SHIFTDOWN}，重复发送"1"，直到两键释放后发送{SHIFTUP}
Func HandleKey1()
    If _IsPressed("31") Then
        If _IsPressed("10") Then
            ; Shift+1组合
            If Not $g_bShift1Active Then
                ControlSend("", "", "", "{SHIFTDOWN}")
                $g_bShift1Active = True
            EndIf
            If $g_TimerKey1 = 0 Then
                ControlSend("", "", "", "1")
                $g_TimerKey1 = TimerInit()
            ElseIf TimerDiff($g_TimerKey1) >= $repeatDelay Then
                ControlSend("", "", "", "1")
                $g_TimerKey1 = TimerInit()
            EndIf
        Else
            ; 仅"1"键按下
            If $g_bShift1Active Then
                ControlSend("", "", "", "{SHIFTUP}")
                $g_bShift1Active = False
            EndIf
            If $g_TimerKey1 = 0 Then
                ControlSend("", "", "", "1")
                $g_TimerKey1 = TimerInit()
            ElseIf TimerDiff($g_TimerKey1) >= $repeatDelay Then
                ControlSend("", "", "", "1")
                $g_TimerKey1 = TimerInit()
            EndIf
        EndIf
    Else
        ; "1"键未按下，若处于Shift+1模式则释放Shift
        If $g_bShift1Active Then
            ControlSend("", "", "", "{SHIFTUP}")
            $g_bShift1Active = False
        EndIf
        $g_TimerKey1 = 0
    EndIf
EndFunc

;------------------------------------------------------------------
; 数字键“2”的处理（虚拟键码 "32"）
Func HandleKey2()
    If _IsPressed("32") Then
        If _IsPressed("10") Then
            If Not $g_bShift2Active Then
                ControlSend("", "", "", "{SHIFTDOWN}")
                $g_bShift2Active = True
            EndIf
            If $g_TimerKey2 = 0 Then
                ControlSend("", "", "", "2")
                $g_TimerKey2 = TimerInit()
            ElseIf TimerDiff($g_TimerKey2) >= $repeatDelay Then
                ControlSend("", "", "", "2")
                $g_TimerKey2 = TimerInit()
            EndIf
        Else
            If $g_bShift2Active Then
                ControlSend("", "", "", "{SHIFTUP}")
                $g_bShift2Active = False
            EndIf
            If $g_TimerKey2 = 0 Then
                ControlSend("", "", "", "2")
                $g_TimerKey2 = TimerInit()
            ElseIf TimerDiff($g_TimerKey2) >= $repeatDelay Then
                ControlSend("", "", "", "2")
                $g_TimerKey2 = TimerInit()
            EndIf
        EndIf
    Else
        If $g_bShift2Active Then
            ControlSend("", "", "", "{SHIFTUP}")
            $g_bShift2Active = False
        EndIf
        $g_TimerKey2 = 0
    EndIf
EndFunc

;------------------------------------------------------------------
; 数字键“3”的处理（虚拟键码 "33"）
Func HandleKey3()
    If _IsPressed("33") Then
        If _IsPressed("10") Then
            If Not $g_bShift3Active Then
                ControlSend("", "", "", "{SHIFTDOWN}")
                $g_bShift3Active = True
            EndIf
            If $g_TimerKey3 = 0 Then
                ControlSend("", "", "", "3")
                $g_TimerKey3 = TimerInit()
            ElseIf TimerDiff($g_TimerKey3) >= $repeatDelay Then
                ControlSend("", "", "", "3")
                $g_TimerKey3 = TimerInit()
            EndIf
        Else
            If $g_bShift3Active Then
                ControlSend("", "", "", "{SHIFTUP}")
                $g_bShift3Active = False
            EndIf
            If $g_TimerKey3 = 0 Then
                ControlSend("", "", "", "3")
                $g_TimerKey3 = TimerInit()
            ElseIf TimerDiff($g_TimerKey3) >= $repeatDelay Then
                ControlSend("", "", "", "3")
                $g_TimerKey3 = TimerInit()
            EndIf
        EndIf
    Else
        If $g_bShift3Active Then
            ControlSend("", "", "", "{SHIFTUP}")
            $g_bShift3Active = False
        EndIf
        $g_TimerKey3 = 0
    EndIf
EndFunc

;------------------------------------------------------------------
; 数字键“4”的处理（虚拟键码 "34"）
Func HandleKey4()
    If _IsPressed("34") Then
        If _IsPressed("10") Then
            If Not $g_bShift4Active Then
                ControlSend("", "", "", "{SHIFTDOWN}")
                $g_bShift4Active = True
            EndIf
            If $g_TimerKey4 = 0 Then
                ControlSend("", "", "", "4")
                $g_TimerKey4 = TimerInit()
            ElseIf TimerDiff($g_TimerKey4) >= $repeatDelay Then
                ControlSend("", "", "", "4")
                $g_TimerKey4 = TimerInit()
            EndIf
        Else
            If $g_bShift4Active Then
                ControlSend("", "", "", "{SHIFTUP}")
                $g_bShift4Active = False
            EndIf
            If $g_TimerKey4 = 0 Then
                ControlSend("", "", "", "4")
                $g_TimerKey4 = TimerInit()
            ElseIf TimerDiff($g_TimerKey4) >= $repeatDelay Then
                ControlSend("", "", "", "4")
                $g_TimerKey4 = TimerInit()
            EndIf
        EndIf
    Else
        If $g_bShift4Active Then
            ControlSend("", "", "", "{SHIFTUP}")
            $g_bShift4Active = False
        EndIf
        $g_TimerKey4 = 0
    EndIf
EndFunc

;------------------------------------------------------------------
; 数字键“5”的处理（虚拟键码 "35"）
Func HandleKey5()
    If _IsPressed("35") Then
        If _IsPressed("10") Then
            If Not $g_bShift5Active Then
                ControlSend("", "", "", "{SHIFTDOWN}")
                $g_bShift5Active = True
            EndIf
            If $g_TimerKey5 = 0 Then
                ControlSend("", "", "", "5")
                $g_TimerKey5 = TimerInit()
            ElseIf TimerDiff($g_TimerKey5) >= $repeatDelay Then
                ControlSend("", "", "", "5")
                $g_TimerKey5 = TimerInit()
            EndIf
        Else
            If $g_bShift5Active Then
                ControlSend("", "", "", "{SHIFTUP}")
                $g_bShift5Active = False
            EndIf
            If $g_TimerKey5 = 0 Then
                ControlSend("", "", "", "5")
                $g_TimerKey5 = TimerInit()
            ElseIf TimerDiff($g_TimerKey5) >= $repeatDelay Then
                ControlSend("", "", "", "5")
                $g_TimerKey5 = TimerInit()
            EndIf
        EndIf
    Else
        If $g_bShift5Active Then
            ControlSend("", "", "", "{SHIFTUP}")
            $g_bShift5Active = False
        EndIf
        $g_TimerKey5 = 0
    EndIf
EndFunc

;------------------------------------------------------------------
; 数字键“6”的处理（虚拟键码 "36"）
Func HandleKey6()
    If _IsPressed("36") Then
        If _IsPressed("10") Then
            If Not $g_bShift6Active Then
                ControlSend("", "", "", "{SHIFTDOWN}")
                $g_bShift6Active = True
            EndIf
            If $g_TimerKey6 = 0 Then
                ControlSend("", "", "", "6")
                $g_TimerKey6 = TimerInit()
            ElseIf TimerDiff($g_TimerKey6) >= $repeatDelay Then
                ControlSend("", "", "", "6")
                $g_TimerKey6 = TimerInit()
            EndIf
        Else
            If $g_bShift6Active Then
                ControlSend("", "", "", "{SHIFTUP}")
                $g_bShift6Active = False
            EndIf
            If $g_TimerKey6 = 0 Then
                ControlSend("", "", "", "6")
                $g_TimerKey6 = TimerInit()
            ElseIf TimerDiff($g_TimerKey6) >= $repeatDelay Then
                ControlSend("", "", "", "6")
                $g_TimerKey6 = TimerInit()
            EndIf
        EndIf
    Else
        If $g_bShift6Active Then
            ControlSend("", "", "", "{SHIFTUP}")
            $g_bShift6Active = False
        EndIf
        $g_TimerKey6 = 0
    EndIf
EndFunc

;------------------------------------------------------------------
; ListenKeys()：整合所有按键监听逻辑
;------------------------------------------------------------------
Func ListenKeys()
	If Not WinActive($targetWindowName) Then Return
		
    ; 数字键 1～6 分别采用直接检测组合键方式
    HandleKey1()
    HandleKey2()
    HandleKey3()
    HandleKey4()
    HandleKey5()
    HandleKey6()

    ; 以下字母键保持原有逻辑
    ; "Q" 键 (虚拟键码 "51")
    If _IsPressed("51") Then
        If $g_TimerKeyQ = 0 Then
            ControlSend("", "", "", "q")
            $g_TimerKeyQ = TimerInit()
        ElseIf TimerDiff($g_TimerKeyQ) >= $repeatDelay Then
            ControlSend("", "", "", "q")
            $g_TimerKeyQ = TimerInit()
        EndIf
    Else
        $g_TimerKeyQ = 0
    EndIf

    ; "E" 键 (虚拟键码 "45")
    If _IsPressed("45") Then
        If $g_TimerKeyE = 0 Then
            ControlSend("", "", "", "e")
            $g_TimerKeyE = TimerInit()
        ElseIf TimerDiff($g_TimerKeyE) >= $repeatDelay Then
            ControlSend("", "", "", "e")
            $g_TimerKeyE = TimerInit()
        EndIf
    Else
        $g_TimerKeyE = 0
    EndIf

    ; "R" 键 (虚拟键码 "52")
    If _IsPressed("52") Then
        If $g_TimerKeyR = 0 Then
            ControlSend("", "", "", "r")
            $g_TimerKeyR = TimerInit()
        ElseIf TimerDiff($g_TimerKeyR) >= $repeatDelay Then
            ControlSend("", "", "", "r")
            $g_TimerKeyR = TimerInit()
        EndIf
    Else
        $g_TimerKeyR = 0
    EndIf

    ; "T" 键 (虚拟键码 "54")
    If _IsPressed("54") Then
        If $g_TimerKeyT = 0 Then
            ControlSend("", "", "", "t")
            $g_TimerKeyT = TimerInit()
        ElseIf TimerDiff($g_TimerKeyT) >= $repeatDelay Then
            ControlSend("", "", "", "t")
            $g_TimerKeyT = TimerInit()
        EndIf
    Else
        $g_TimerKeyT = 0
    EndIf

    ; "F" 键 (虚拟键码 "46")
    If _IsPressed("46") Then
        If $g_TimerKeyF = 0 Then
            ControlSend("", "", "", "f")
            $g_TimerKeyF = TimerInit()
        ElseIf TimerDiff($g_TimerKeyF) >= $repeatDelay Then
            ControlSend("", "", "", "f")
            $g_TimerKeyF = TimerInit()
        EndIf
    Else
        $g_TimerKeyF = 0
    EndIf
EndFunc

;------------------------------------------------------------------
; 拖拽处理函数（未锁定时允许拖动 GUI）
;------------------------------------------------------------------
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

;------------------------------------------------------------------
; 开始/停止按钮回调函数
;------------------------------------------------------------------
Func OnStartButtonClick()
    ; 仅允许鼠标左键点击触发，而不允许回车（Enter）或空格（Space）触发
    If Not (GUIGetCursorInfo($gui)[4]) Then Return

    $isRunning = Not $isRunning

    ; 先更新按钮文本
    GUICtrlSetData($startButton, $isRunning ? "停止" : "启动")

    ; 立即调用颜色更新函数
    If $isRunning Then
        WinActivate($targetWindowName)
    Else
        ; 恢复默认按钮颜色为白色，并将文本颜色设为黑色
        GUICtrlSetBkColor($startButton, 0xFFFFFF)
        GUICtrlSetColor($startButton, 0x000000)
        WinActivate($targetWindowName)
    EndIf

    ConsoleWrite("running " & $isRunning & @CRLF)
EndFunc




;-------------------------------
; 透明度菜单选择回调函数
Func OnOpacityMenuSelect()
    Local $id = @GUI_CTRLID
    For $i = 0 To UBound($menuOpacityMap) - 1
        Local $num = (10 * ($i + 1)) & "%"  ; 原始百分比字符串
        If $menuOpacityMap[$i] = $id Then
            Local $opacity = (10 * ($i + 1)) * 2.55
            ConsoleWrite("Selected Opacity: " & $opacity & @CRLF)
            WinSetTrans($gui, "", $opacity)
            ; 选中项：前缀改为“√”后跟一个全角空格（注意：全角空格为 "　"）
            GUICtrlSetData($menuOpacityMap[$i], "✔" & $num)
        Else
            ; 未选中项：前缀用两个全角空格，保证数字起始位置与选中项一致
            GUICtrlSetData($menuOpacityMap[$i], "     " & $num)
        EndIf
    Next
EndFunc


;------------------------------------------------------------------
; 锁定/解锁窗口回调函数
;------------------------------------------------------------------
Func OnFixedMenuSelect()
    ; 切换锁定状态
    $isFixed = Not $isFixed
    If $isFixed Then
        GUICtrlSetData($fixedMenuItem, "✔ 锁定窗口")
        ConsoleWrite("窗口已锁定，不可移动" & @CRLF)
    Else
        GUICtrlSetData($fixedMenuItem, "锁定窗口")
        ConsoleWrite("窗口可移动" & @CRLF)
    EndIf
EndFunc

;-------------------------------
; 新增：更新开始按钮背景颜色函数
Func UpdateButtonColor()
    ; 仅当处于运行状态时更新颜色
    If Not $isRunning Then Return

    ; 逐渐平滑过渡：当前颜色向目标颜色靠拢
    $currR = $currR + ($targetR - $currR) * $colorTransitionFactor
    $currG = $currG + ($targetG - $currG) * $colorTransitionFactor
    $currB = $currB + ($targetB - $currB) * $colorTransitionFactor

    ; 如果当前颜色已经非常接近目标颜色，则生成新的目标颜色（随机RGB）
    If Abs($targetR - $currR) < 1 And Abs($targetG - $currG) < 1 And Abs($targetB - $currB) < 1 Then
        $targetR = Random(0, 255, 1)
        $targetG = Random(0, 255, 1)
        $targetB = Random(0, 255, 1)
    EndIf

    ; 将浮点数转换为整数
    Local $intR = Int($currR)
    Local $intG = Int($currG)
    Local $intB = Int($currB)

    ; 计算新颜色（格式：0xRRGGBB）
    Local $newColor = ($intR * 0x10000) + ($intG * 0x100) + $intB

    ; 计算反色（文本颜色）
    Local $inverseColor = 0xFFFFFF - $newColor

    ; 更新按钮的背景色和文本颜色
    GUICtrlSetBkColor($startButton, $newColor)
    GUICtrlSetColor($startButton, $inverseColor)
EndFunc




;------------------------------------------------------------------
; 关闭窗口回调函数
;------------------------------------------------------------------
Func OnCloseWindow()
    ConsoleWrite("Window closed. Exiting the program." & @CRLF)
    Exit
EndFunc
