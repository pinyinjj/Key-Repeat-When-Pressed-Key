#include <Misc.au3>
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <StaticConstants.au3>
#include <ButtonConstants.au3>
#NoTrayIcon
#AutoIt3Wrapper_Icon=icon.ico

Opt("WinTitleMatchMode", 4)
Opt("GUIOnEventMode", 1)

; -------------------------
; 注册表设置
; -------------------------
RegWrite("HKEY_CURRENT_USER\Control Panel\Accessibility\StickyKeys", "Flags", "REG_SZ", "506")

; -------------------------
; 全局变量声明
; -------------------------
Global $Version             = " v0.2.12"
Global $targetWindowName    = "魔兽世界"

Global $isRunning           = False
Global $g_colorTimer        = TimerInit()
Global $isFixed             = False             ; 默认窗口不锁定，可拖动

; 自动右键点击功能
Global $isAutoRightClick    = False
Global $g_TimerAutoRightClick = TimerInit()

; 颜色平滑过渡参数及变量
Global $currR               = 255, $currG = 255, $currB = 255
Global $targetR             = Random(0, 255, 1), $targetG = Random(0, 255, 1), $targetB = Random(0, 255, 1)
Global $colorTransitionFactor = 0.3

; 按键重复发送计时器（毫秒）
; 数字键 1~6 的计时器使用数组存储（下标 1~6 使用，下标 0 保留）
Global $g_TimerKeys[7] = [0, 0, 0, 0, 0, 0, 0]

; Q, E, R, T, F 按键的计时器
Global $g_TimerKeyQ         = 0
Global $g_TimerKeyE         = 0
Global $g_TimerKeyR         = 0
Global $g_TimerKeyT         = 0
Global $g_TimerKeyF         = 0

Global $repeatDelay         = 100

; 数字键 Shift 组合标志使用数组存储（下标 1~6 使用）
Global $g_bShiftActive[7] = [False, False, False, False, False, False, False]

; -------------------------
; GUI 界面及控件创建
; -------------------------
Global $gui = GUICreate("KPC " & $Version, 100, 80, -1, -1, $WS_POPUP, BitOR($WS_EX_TOPMOST, 0x02000000))
WinSetOnTop($gui, "", True)

Global $startButton   = GUICtrlCreateButton("开始", 10, 10, 80, 30)
Global $versionLabel  = GUICtrlCreateLabel("KPC" & $Version, 0, 60, 100, 10, $SS_CENTER)
GUICtrlSetColor($versionLabel, 0x808080)
GUICtrlSetFont($versionLabel, 8)

GUISetIcon(@ScriptDir & "\icon.ico", $gui)
GUISetState(@SW_SHOW, $gui)

; -------------------------
; 设置窗口圆角效果
; -------------------------
Local $aPos      = WinGetPos($gui)
Local $iWidth    = $aPos[2]
Local $iHeight   = $aPos[3]
Local $iRound    = 30      ; 圆角半径，可根据需要调整
Local $aRet      = DllCall("gdi32.dll", "hwnd", "CreateRoundRectRgn", "int", 0, "int", 0, "int", $iWidth + 1, "int", $iHeight + 1, "int", $iRound, "int", $iRound)
If Not @error And IsArray($aRet) Then
    DllCall("user32.dll", "int", "SetWindowRgn", "hwnd", $gui, "hwnd", $aRet[0], "int", True)
Else
    ConsoleWrite("设置圆角失败" & @CRLF)
EndIf

; -------------------------
; 右键菜单创建及事件绑定
; -------------------------
Global $contextMenu = GUICtrlCreateContextMenu()

; 透明度菜单及其子项
Global $opacityMenu   = GUICtrlCreateMenu("透明度", $contextMenu)
Global $menuOpacityMap[10]
For $i = 1 To 10
    Local $num = ($i * 10) & "%"   ; 例如 "10%", "20%"…… "100%"
    If $i = 10 Then
        ; 默认“100%”选项前加“✔　”，并设置主窗口透明度为 255（即 100%）
        $menuOpacityMap[$i - 1] = GUICtrlCreateMenuItem("✔" & $num, $opacityMenu)
        WinSetTrans($gui, "", 255)
    Else
        $menuOpacityMap[$i - 1] = GUICtrlCreateMenuItem("     " & $num, $opacityMenu)
    EndIf
    GUICtrlSetOnEvent($menuOpacityMap[$i - 1], "OnOpacityMenuSelect")
Next

GUICtrlSetOnEvent($startButton, "OnStartButtonClick") 


; “采轻歌花”菜单项（自动右键点击功能）
Global $autoRightClickMenuItem = GUICtrlCreateMenuItem("采轻歌花", $contextMenu)
GUICtrlSetOnEvent($autoRightClickMenuItem, "OnAutoRightClickSelect")

; 退出菜单项
Global $exitMenuItem = GUICtrlCreateMenuItem("退出", $contextMenu)
GUICtrlSetOnEvent($exitMenuItem, "OnCloseWindow")

; -------------------------
; 主循环
; -------------------------
While 1
    Local $msg = GUIGetMsg()
    Switch $msg
        Case $GUI_EVENT_CLOSE
            OnCloseWindow()
            Exit
        Case $startButton
            OnStartButtonClick()
    EndSwitch

    ; 若未锁定则允许拖拽移动
    If Not $isRunning Then
        HandleDrag()
    EndIf

    ; 根据目标窗口状态调整 GUI 置顶
    If WinExists($targetWindowName) And WinActive($targetWindowName) Then
        WinSetOnTop($gui, "", True)
    Else
        WinSetOnTop($gui, "", False)
    EndIf

    ; 仅在运行状态下监听按键
    If $isRunning Then
        ListenKeys()
    EndIf

    ; 自动右键点击（采轻歌花）功能
    If $isAutoRightClick Then
        If TimerDiff($g_TimerAutoRightClick) >= 300 Then
            MouseClick("right")
            $g_TimerAutoRightClick = TimerInit()
        EndIf
    EndIf

    UpdateButtonColor()
    Sleep(10) ; 防止程序卡死，定期更新 GUI
WEnd

; =========================
; 按键处理函数区
; =========================

;------------------------------------------------------------------
; 整合的数字键处理函数：HandleDigitKey
; 参数 $index 表示数字键（1~6），虚拟键码依次为 "31"、"32"……"36"
;------------------------------------------------------------------
Func HandleDigitKey($index)
    Local $vkCode = String(30 + $index)    ; 例如：1 对应 "31"
    Local $digit  = String($index)          ; 要发送的字符
    If _IsPressed($vkCode) Then
        If _IsPressed("10") Then            ; Shift 键被按下
            If Not $g_bShiftActive[$index] Then
                ControlSend("", "", "", "{SHIFTDOWN}")
                $g_bShiftActive[$index] = True
            EndIf
            If $g_TimerKeys[$index] = 0 Then
                ControlSend("", "", "", $digit)
                $g_TimerKeys[$index] = TimerInit()
            ElseIf TimerDiff($g_TimerKeys[$index]) >= $repeatDelay Then
                ControlSend("", "", "", $digit)
                $g_TimerKeys[$index] = TimerInit()
            EndIf
        Else
            ; 如果之前处于 Shift+组合状态则释放 Shift
            If $g_bShiftActive[$index] Then
                ControlSend("", "", "", "{SHIFTUP}")
                $g_bShiftActive[$index] = False
            EndIf
            If $g_TimerKeys[$index] = 0 Then
                ControlSend("", "", "", $digit)
                $g_TimerKeys[$index] = TimerInit()
            ElseIf TimerDiff($g_TimerKeys[$index]) >= $repeatDelay Then
                ControlSend("", "", "", $digit)
                $g_TimerKeys[$index] = TimerInit()
            EndIf
        EndIf
    Else
        ; 键未按下：若处于 Shift+状态则释放 Shift，并重置计时器
        If $g_bShiftActive[$index] Then
            ControlSend("", "", "", "{SHIFTUP}")
            $g_bShiftActive[$index] = False
        EndIf
        $g_TimerKeys[$index] = 0
    EndIf
EndFunc

;------------------------------------------------------------------
; 按键监听封装函数（减少重复代码）
;------------------------------------------------------------------
Func HandleKeyPress($keyCode, $keyChar, ByRef $g_TimerKey)
    If _IsPressed($keyCode) Then
        If $g_TimerKey = 0 Then
            ControlSend("", "", "", $keyChar)
            $g_TimerKey = TimerInit()
        ElseIf TimerDiff($g_TimerKey) >= $repeatDelay Then
            ControlSend("", "", "", $keyChar)
            $g_TimerKey = TimerInit()
        EndIf
    Else
        $g_TimerKey = 0
    EndIf
EndFunc

;------------------------------------------------------------------
; ListenKeys()：整合所有按键监听逻辑
;------------------------------------------------------------------
Func ListenKeys()
    If Not WinActive($targetWindowName) Then Return

    ; 数字键 1～6 统一处理
    For $i = 1 To 6
        HandleDigitKey($i)
    Next

    ; Q, E, R, T, F 按键监听
    HandleKeyPress("51", "q", $g_TimerKeyQ)
    HandleKeyPress("45", "e", $g_TimerKeyE)
    HandleKeyPress("52", "r", $g_TimerKeyR)
    HandleKeyPress("54", "t", $g_TimerKeyT)
    HandleKeyPress("46", "f", $g_TimerKeyF)

    ; 自动右键点击处理
    If $isAutoRightClick Then
        If TimerDiff($g_TimerAutoRightClick) >= 300 Then
            MouseClick("right")
            $g_TimerAutoRightClick = TimerInit()
        EndIf
    EndIf
EndFunc

; -------------------------
; 窗口拖拽处理函数（未锁定时允许拖动 GUI）
; -------------------------
Func HandleDrag()
    ; 为了在 Option Explicit 或严格模式下使用全局变量，需在函数内声明
    Global $isDragging, $dragOffsetX, $dragOffsetY, $gui

    Local $mousePos = MouseGetPos()
    Local $winPos   = WinGetPos($gui)
    
    If _IsPressed("01") Then ; 鼠标左键按下
        If Not $isDragging Then
            ; 检查是否在窗口范围内
            If $mousePos[0] >= $winPos[0] And $mousePos[0] <= $winPos[0] + 120 And _
               $mousePos[1] >= $winPos[1] And $mousePos[1] <= $winPos[1] + 100 Then
                $isDragging   = True
                $dragOffsetX  = $mousePos[0] - $winPos[0]
                $dragOffsetY  = $mousePos[1] - $winPos[1]
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

; -------------------------
; GUI 事件回调函数
; -------------------------

;------------------------------------------------------------------
; 开始/停止按钮回调函数
;------------------------------------------------------------------
Func OnStartButtonClick()
	If Not (GUIGetCursorInfo($gui)[4]) Then Return
	
    ConsoleWrite("Start/Stop button clicked." & @CRLF)  ; 添加调试输出
    $isRunning = Not $isRunning
    GUICtrlSetData($startButton, $isRunning ? "停止" : "启动")
    If $isRunning Then
        ConsoleWrite("Application is running." & @CRLF)
        WinActivate($targetWindowName)
    Else
		GUICtrlSetBkColor($startButton, 0xFFFFFF)
        GUICtrlSetColor($startButton, 0x000000)
        WinActivate($targetWindowName)
        ConsoleWrite("Application stopped." & @CRLF)
    EndIf
EndFunc


;------------------------------------------------------------------
; 透明度菜单选择回调函数
;------------------------------------------------------------------
Func OnOpacityMenuSelect()
    Local $id = @GUI_CTRLID
    For $i = 0 To UBound($menuOpacityMap) - 1
        Local $num = (10 * ($i + 1)) & "%"  ; 原始百分比字符串
        If $menuOpacityMap[$i] = $id Then
            Local $opacity = (10 * ($i + 1)) * 2.55
            ConsoleWrite("Selected Opacity: " & $opacity & @CRLF)
            WinSetTrans($gui, "", $opacity)
            GUICtrlSetData($menuOpacityMap[$i], "✔" & $num)
        Else
            GUICtrlSetData($menuOpacityMap[$i], "     " & $num)
        EndIf
    Next
EndFunc

;------------------------------------------------------------------
; "采轻歌花" 菜单点击回调函数（自动右键点击）
;------------------------------------------------------------------
Func OnAutoRightClickSelect()
    $isAutoRightClick = Not $isAutoRightClick
    If $isAutoRightClick Then
        GUICtrlSetData($autoRightClickMenuItem, "✔ 采轻歌花")
        ConsoleWrite("自动右键点击已开启" & @CRLF)
    Else
        GUICtrlSetData($autoRightClickMenuItem, "采轻歌花")
        ConsoleWrite("自动右键点击已关闭" & @CRLF)
    EndIf
EndFunc

;------------------------------------------------------------------
; 更新开始按钮背景颜色函数（颜色平滑过渡）
;------------------------------------------------------------------
Func UpdateButtonColor()
    If Not $isRunning Then Return

    Local $t = $colorTransitionFactor
    $currR += ($targetR - $currR) * $t
    $currG += ($targetG - $currG) * $t
    $currB += ($targetB - $currB) * $t

    If Abs($currR - $targetR) < 1 And Abs($currG - $targetG) < 1 And Abs($currB - $targetB) < 1 Then
        $targetR = Random(0, 255, 1)
        $targetG = Random(0, 255, 1)
        $targetB = Random(0, 255, 1)
    EndIf

    Local $newColor = Int($currR) * 0x10000 + Int($currG) * 0x100 + Int($currB)
    GUICtrlSetBkColor($startButton, $newColor)
    GUICtrlSetColor($startButton, 0xFFFFFF - $newColor)
EndFunc


;------------------------------------------------------------------
; 关闭窗口回调函数
;------------------------------------------------------------------
Func OnCloseWindow()
    ConsoleWrite("Window closed. Exiting the program." & @CRLF)
    Exit
EndFunc
