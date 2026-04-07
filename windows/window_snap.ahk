#Requires AutoHotkey v2.0
#SingleInstance Force

; =============================================================================
; ZMK L3 (Win Nav) ウィンドウスナップ
; Mac の Magnet と同一ショートカット (Ctrl+Alt+Key) を AHK で処理
;
; レイアウト（右手側キー対応）:
;   行0: E=左2/3  U=左上  ↑=上半  I=右上  T=右2/3
;   行1: D=左1/3  ←=左半  Enter=最大  →=右半  G=右1/3
;   行2: BS=復元  J=左下  ↓=下半  K=右下  F=中央1/3
; =============================================================================

; アクティブウィンドウがあるモニターの作業領域を取得
GetMonitorWorkArea(&Left, &Top, &Right, &Bottom) {
    try {
        WinGetPos(&wx, &wy, &ww, &wh, "A")
        cx := wx + ww // 2
        cy := wy + wh // 2
        Loop MonitorGetCount() {
            MonitorGetWorkArea(A_Index, &ml, &mt, &mr, &mb)
            if (cx >= ml && cx < mr && cy >= mt && cy < mb) {
                Left := ml, Top := mt, Right := mr, Bottom := mb
                return
            }
        }
    }
    ; フォールバック: プライマリモニター
    MonitorGetWorkArea(MonitorGetPrimary(), &Left, &Top, &Right, &Bottom)
}

SnapWindow(x, y, w, h) {
    if WinGetMinMax("A") = 1
        WinRestore("A")
    WinMove(x, y, w, h, "A")
}

; --- 半分 ---

^!Left:: {          ; 左半
    GetMonitorWorkArea(&L, &T, &R, &B)
    W := R - L, H := B - T
    SnapWindow(L, T, W // 2, H)
}

^!Right:: {         ; 右半
    GetMonitorWorkArea(&L, &T, &R, &B)
    W := R - L, H := B - T
    SnapWindow(L + W // 2, T, W // 2, H)
}

^!Up:: {            ; 上半
    GetMonitorWorkArea(&L, &T, &R, &B)
    W := R - L, H := B - T
    SnapWindow(L, T, W, H // 2)
}

^!Down:: {          ; 下半
    GetMonitorWorkArea(&L, &T, &R, &B)
    W := R - L, H := B - T
    SnapWindow(L, T + H // 2, W, H // 2)
}

; --- 四隅 ---

^!u:: {             ; 左上
    GetMonitorWorkArea(&L, &T, &R, &B)
    W := R - L, H := B - T
    SnapWindow(L, T, W // 2, H // 2)
}

^!i:: {             ; 右上
    GetMonitorWorkArea(&L, &T, &R, &B)
    W := R - L, H := B - T
    SnapWindow(L + W // 2, T, W // 2, H // 2)
}

^!j:: {             ; 左下
    GetMonitorWorkArea(&L, &T, &R, &B)
    W := R - L, H := B - T
    SnapWindow(L, T + H // 2, W // 2, H // 2)
}

^!k:: {             ; 右下
    GetMonitorWorkArea(&L, &T, &R, &B)
    W := R - L, H := B - T
    SnapWindow(L + W // 2, T + H // 2, W // 2, H // 2)
}

; --- 3分割 ---

^!e:: {             ; 左2/3
    GetMonitorWorkArea(&L, &T, &R, &B)
    W := R - L, H := B - T
    SnapWindow(L, T, W * 2 // 3, H)
}

^!t:: {             ; 右2/3
    GetMonitorWorkArea(&L, &T, &R, &B)
    W := R - L, H := B - T
    SnapWindow(L + W // 3, T, W * 2 // 3, H)
}

^!d:: {             ; 左1/3
    GetMonitorWorkArea(&L, &T, &R, &B)
    W := R - L, H := B - T
    SnapWindow(L, T, W // 3, H)
}

^!g:: {             ; 右1/3
    GetMonitorWorkArea(&L, &T, &R, &B)
    W := R - L, H := B - T
    SnapWindow(L + W * 2 // 3, T, W // 3, H)
}

^!f:: {             ; 中央1/3
    GetMonitorWorkArea(&L, &T, &R, &B)
    W := R - L, H := B - T
    SnapWindow(L + W // 3, T, W // 3, H)
}

; --- 最大化 / 復元 ---

^!Enter:: {         ; 最大化
    WinMaximize("A")
}

^!Backspace:: {     ; 復元（最大化→通常サイズ、それ以外→中央寄せ）
    if WinGetMinMax("A") != 0 {
        WinRestore("A")
    } else {
        GetMonitorWorkArea(&L, &T, &R, &B)
        W := R - L, H := B - T
        SnapWindow(L + W // 6, T + H // 6, W * 2 // 3, H * 2 // 3)
    }
}
