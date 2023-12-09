#include <MsgBoxConstants.au3>
#include <Misc.au3>

$gamename = "魔兽世界"
$hDLL = DllOpen("user32.dll")

Global $isGameActive = False ; 新增标志追踪游戏窗口焦点状态
Global $pauseScript = False

While 1
    Sleep(100)

    ; 获取 Scroll Lock 状态
    $scrollLockState = DllCall("user32.dll", "short", "GetKeyState", "int", 0x91)
    $scrollLockState = BitAND($scrollLockState[0], 1)

    ; 如果 Scroll Lock 未开启，暂停脚本
    If Not $scrollLockState Then
        $pauseScript = True
    Else
        $pauseScript = False
    EndIf

    ; 检查游戏窗口焦点状态
    If WinActive($gamename) Then
        If Not $isGameActive Then
            ; 从失焦状态恢复到游戏，设置标志和恢复脚本运行
            $isGameActive = True
            $pauseScript = False
        EndIf

        ; 在游戏窗口中执行的代码
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
    ElseIf Not WinActive($gamename) Then
        If $isGameActive Then
            ; 从游戏到失焦，设置标志
            $isGameActive = False
        EndIf
        ; 如果游戏窗口失焦，暂停脚本并关闭 Scroll Lock
        $pauseScript = True
        Send("{SCROLLLOCK off}")
    EndIf
WEnd

DllClose($hDLL)


