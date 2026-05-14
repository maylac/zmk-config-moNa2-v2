# moNa2 v2 ZMK Config

右手トラックボール付き分割キーボード「moNa2」のZMKファームウェア設定。

- ボード: Seeeduino XIAO BLE
- センサ: PMW3610（右手側）
- ファームウェア: ZMK v0.3.0

---

## レイヤー一覧

| # | レイヤー名 | 概要 | LED | 起動方法 |
|---|-----------|------|-----|---------|
| 0 | `default_win` | QWERTY基本配置 | 消灯 | ベースレイヤー（常時） |
| 1 | `indicator_win` | Winモードコンボ識別用フラグ（全キー透過） | 消灯 | Winモード時に自動オン |
| 2 | `symbol` | 記号・括弧 | 🟡 黄 | `ENTER` ホールド |
| 3 | `num_fn` | 数字・ファンクション | 🔴 赤 | `SPACE` ホールド |
| 4 | `nav_win` | ナビゲーション + ウィンドウスナップ | 🩵 シアン | `LANG1` ホールド |
| 5 | `bt` | Bluetooth設定 + 現在プロファイルのWin/Mac設定 | 🟣 マゼンタ | `LANG2`+`LANG1` 同時押し |
| 6 | `mouse` | マウスボタン | 消灯 | `TAB` or `ESC` ホールド / Automouse |
| 7 | `scroll` | スクロールモード | 消灯 | `,`+`.` 同時押し（トグル） |
| 8 | `gesture_browser_win` | ジェスチャー：ブラウザ操作 | ◯白 | `-` ホールド（Win） |
| 9 | `gesture_vdesk_win` | ジェスチャー：仮想デスクトップ | ◯白 | `W`+`E` 同時押し（Win） |
| 10 | `gesture_general_win` | ジェスチャー：一般操作 | ◯白 | `L`+`-` 同時押し（Win） |
| 11 | `default_mac` | Mac用ベースレイヤー（L0透過オーバーレイ） | 🟢 緑 | L5で `BTn` 選択後 `Mac` を保存 |
| 12 | `nav_mac` | Magnetウィンドウスナップ（3×3）+ Macナビゲーション | 🩵 シアン | `LANG1` ホールド（Mac） |
| 13 | `gesture_browser_mac` | Macジェスチャー：ブラウザ操作 | ◯白 | `-` ホールド（Mac） |
| 14 | `gesture_vdesk_mac` | Macジェスチャー：仮想デスクトップ | ◯白 | `W`+`E` 同時押し（Mac） |
| 15 | `gesture_general_mac` | Macジェスチャー：一般操作 | ◯白 | `L`+`-` 同時押し（Mac） |
| 16 | `app_switch` | Alt/Cmd+Tab アプリ切替 | ◯白 | `O`+`P` 同時押し（Win/Mac共通） |

## キーマップ

![keymap](mona2.svg)

---

## レイヤー遷移図

```mermaid
flowchart LR
    classDef winBase fill:#607D8B,stroke:#37474F,color:#fff
    classDef macBase fill:#43A047,stroke:#2E7D32,color:#fff
    classDef symbol  fill:#F9A825,stroke:#c47d00,color:#fff
    classDef number  fill:#1976D2,stroke:#1565C0,color:#fff
    classDef nav     fill:#0097A7,stroke:#006064,color:#fff
    classDef bt      fill:#9C27B0,stroke:#6A1B9A,color:#fff
    classDef mouse   fill:#E91E63,stroke:#880E4F,color:#fff
    classDef scroll  fill:#78909C,stroke:#546E7A,color:#fff
    classDef gesture fill:#7B1FA2,stroke:#4A148C,color:#fff

    L0["L0\nDefault\nWin\n⚫"]:::winBase
    L11["L11\nDefault\nMac\n🟢\n※L0と同時にアクティブ"]:::macBase
    L5["L5\nBluetooth\n🟣"]:::bt
    L2["L2\nSymbol\n🟡"]:::symbol
    L3["L3\nNumber\n🔴"]:::number
    L4["L4\nNav Win\n🩵"]:::nav
    L12["L12\nNav Mac\n🩵"]:::nav
    L13["L13\nGesture Mac\nBrowser"]:::gesture
    L14["L14\nGesture Mac\nVDesk"]:::gesture
    L15["L15\nGesture Mac\nGeneral"]:::gesture
    L6["L6\nMouse\n⚫"]:::mouse
    L7["L7\nScroll\n⚫"]:::scroll
    L8["L8\nGesture\nBrowser"]:::gesture
    L9["L9\nGesture\nVDesk"]:::gesture
    L10["L10\nGesture\nGeneral"]:::gesture
    L16["L16\nApp Switcher\nAlt/Cmd+Tab"]:::gesture
    L1["L1\nWin Indicator\n(Winコンボ識別)"]:::winBase

    %% BT切替
    L0 <-->|"combo LANG2+LANG1"| L5
    L11 <-->|"combo LANG2+LANG1"| L5

    %% L0からの遷移（Win・Mac共通）
    L0 -->|"ENTER"| L2
    L0 -->|"SPACE"| L3
    L0 -->|"LANG1"| L4
    L0 -->|"TAB / ESC"| L6
    L0 -->|"combo comma+dot"| L7
    L0 -->|"MINUS hold"| L8
    L0 -->|"combo W+E"| L9
    L0 -->|"combo O+P"| L16
    L0 -->|"combo 19+20"| L10
    L0 -->|"Automouse"| L6

    %% 戻り
    L2 & L3 & L4 & L8 & L9 & L10 & L16 -->|"コンボ/キー離す"| L0

    %% L1はWinモードフラグ（L5でWin/Mac切替）
    L5 -->|"Win押す"| L1
    L5 -->|"Mac押す（L1オフ）"| L0
    L7 -->|"combo comma+dot 再押し"| L0
    L6 -->|"10秒 or Ctrl/Shift"| L0

    %% L11はL0と同時にアクティブ → L0の全遷移が使える
    L11 <-->|"常時重ねがけ（L0透過）"| L0

    %% L11のみ異なる遷移
    L11 -->|"LANG1"| L12
    L11 -->|"MINUS hold"| L13
    L11 -->|"combo W+E"| L14
    L11 -->|"combo O+P"| L16
    L11 -->|"combo 19+20"| L15
    L12 & L13 & L14 & L15 -->|"コンボ/キー離す"| L11
    L16 -->|"ESC or コンボ離す"| L0
```

### 補足

- **Win モード**（デフォルト）: Layer 0 を基点に遷移。Layer 1 (Win Indicator) が同時アクティブ
- **Mac モード**: Layer 11 を基点に遷移。Layer 11 は Layer 0 の透過オーバーレイ（LANG1 長押し以外は Layer 0 に通過）
- **Layer 1 (Win Indicator)**: Layer 0 は常時アクティブなため「Winモード限定コンボ」を `layers=0` で定義するとMacモードでも誤発火する。Layer 1 をWinモードのフラグとして使い、Winコンボは `layers=1` で参照することで誤発火を防ぐ
- **Automouse**: トラックボールを動かすと Layer 6 に自動遷移、300ms 静止 + 10秒タイムアウトで復帰
- **BT プロファイルごとに Win/Mac 状態をキーボード側へ保存**（BTレイヤーを離したときに確定保存）
- **LED は最上位レイヤー色を表示する。L5 を押している間はマゼンタ、離した後に Win=消灯 / Mac=緑 を確認する**

---

## 特殊バインド

- `A` ホールド → **Win: LCtrl** / **Mac: Cmd**（+ マウスレイヤー終了）
- `Z` ホールド → LShift（+ マウスレイヤー終了）
- `LANG1` タップ → Layer 0へ戻る / ホールド → Layer 4一時有効（Mac時はLayer 12）

---

## Layer 3 - Number

**エンコーダ:** 上下スクロール

---

## Layer 4/12 - Nav（ナビゲーション）

左側はカーソル移動、右側はウィンドウスナップ（3×3空間マッピング）。
Win/Mac で同一の `Ctrl+Alt+[key]` を送信し、OS側ソフトウェアが処理する。

```
LANG1押しながら...

[ Y ] [ U ] [ I ] [ O ] [ P ]
 左2/3  左上  上半  右上  右2/3

[ H ] [ J ] [ K ] [ L ] [ - ]
 左1/3  左半  最大  右半  右1/3

[ N ] [ M ] [ , ] [ . ] [ / ]
 復元  左下  下半  右下  中央1/3
```

| 機能 | Windows (L4) | Mac (L12) |
|------|-------------|-----------|
| ウィンドウスナップ | `Ctrl+Alt+[key]` → **AHK**（`windows/window_snap.ahk`） | `Ctrl+Alt+[key]` → **Magnet** |
| 全画面スクショ | `Ctrl+Win+PrintScreen` | `Cmd+Shift+4` |
| 範囲スクショ | `Shift+PrintScreen` | `Cmd+Shift+5` |
| **Ctrl+Alt+Del** | `LANG1+BS`（ロック画面解除） | — |

**エンコーダ:**
- Win (L4): `Ctrl+Tab` / `Ctrl+Shift+Tab`（タブ切り替え）
- Mac (L12): `Cmd+Shift+]` / `Cmd+Shift+[`（タブ切り替え）

**トラックボール:** スクロール変換（X軸反転、速度1/5倍）

---

## Layer 6 - Mouse（マウス操作）

トラックボール操作で自動遷移（Automouse）。

| ボタン | 機能 |
|--------|------|
| MB1 | 左クリック |
| MB2 | 右クリック |
| MB3 | 中クリック |
| MB4 | 戻る |
| MB5 | 進む |

---

## Layer 7 - Scroll（スクロール）

全キー透過（トランス）。トラックボール移動がスクロール入力に変換される。

**遷移方法:** `,` + `.` 同時押し（トグル）

- スケール: 1/8倍
- Y軸反転あり

---

## Layer 8/13 - Gesture（ブラウザ操作）

トラックボールのスワイプ方向でブラウザ操作。

| スワイプ | 動作 | Windows (L8) | Mac (L13) |
|---------|------|-------------|-----------|
| ←      | 前のタブ | `Ctrl+Shift+Tab` | `Ctrl+Shift+Tab` |
| →      | 次のタブ | `Ctrl+Tab` | `Ctrl+Tab` |
| ↑      | 新規タブ | `Ctrl+T` | `Cmd+T` |
| ↓      | タブを閉じる | `Ctrl+W` | `Cmd+W` |

**遷移方法:** `-`キー長押し または コンボ（後述）

**エンコーダ:**
- Win (L8): `Ctrl+-` / `Ctrl+=`（ズーム）
- Mac (L13): `Cmd+-` / `Cmd+=`（ズーム）

---

## Layer 9/14 - Gesture（仮想デスクトップ）

| スワイプ | Windows 動作 (L9) | ショートカット | Mac 動作 (L14) | ショートカット |
|---------|-----------------|--------------|--------------|--------------|
| ←      | 前の仮想デスク | `Win+Ctrl+←` | 前のSpace | `Ctrl+←` |
| →      | 次の仮想デスク | `Win+Ctrl+→` | 次のSpace | `Ctrl+→` |
| ↑      | タスクビュー | `Win+Tab` | Mission Control | `Ctrl+↑` |
| ↓      | アプリを次のデスクへ | `Win+Ctrl+Shift+→` | Spaceへ移動 | `Ctrl+Shift+→` |

**遷移方法:** `W`+`E` 同時押し

---

## Layer 10/15 - Gesture（一般操作）

| スワイプ | Windows 動作 (L10) | ショートカット | Mac 動作 (L15) | ショートカット |
|---------|-----------------|--------------|--------------|--------------|
| ↑      | URLバー選択 | `Ctrl+L` | URLバー選択 | `Cmd+L` |
| ↓      | PowerToys Run | `Alt+Space` | Spotlight / Raycast | `Cmd+Space` |
| ←      | ブラウザ戻る | `Alt+←` | ブラウザ戻る | `Cmd+←` |
| →      | ブラウザ進む | `Alt+→` | ブラウザ進む | `Cmd+→` |

**遷移方法:** キー19+20同時押し（Win: `Win` / Mac: `Cmd`）

---

## Layer 11 - Default Mac（差分）

- `-` キー ホールド → Layer 13（Mac Gesture Browser）
- `LANG1` ホールド → Layer 12（Mac Nav）
- コンボ `W+E` → Layer 14（Mac Gesture VDesk）
- コンボ `19+20` → Layer 15（Mac Gesture General）

---

## コンボ

| キー | 動作 |
|-----|------|
| `W` + `E` 同時押し | Layer 9/14 一時有効（仮想デスクトップジェスチャー） |
| `O` + `P` 同時押し | Layer 16 一時有効（App Switcher、Alt/Cmd+Tab） |
| `L` + `-` 同時押し | Layer 10/15 一時有効（一般ジェスチャー + Win/Cmd） |
| `LANG2` + `LANG1` 同時押し | Layer 5 (Bluetooth) 一時有効 |
| `,` + `.` 同時押し | Layer 7 (Scroll) トグル ON/OFF |
| `Q` + `A` 同時押し | 全選択（Win: `Ctrl+A` / Mac: `Cmd+A`） |

### Layer 5 の使い方

- 上段右側 5 キー: `BT0..4`
- 左上側: `Win`
- その右: `Mac`
- `bootloader`: ブートローダ起動
- `BT CLR` / `BT CLR ALL`: 現在のプロファイル消去 / 全消去
- 手順: `BTn` を押す → `Win` または `Mac` を押す

### Win/Mac 判定の見方

- `Win`: Layer 11 がオフなので、L5 を離した後は LED が消灯
- `Mac`: Layer 11 がオンなので、L5 を離した後は LED が緑
- `L5` を押している間は Layer 5 が最上位なのでマゼンタ
- `Nav Mac` に入ると Layer 12 が最上位になり、LED はシアンに変わる

---

## Automouse設定

トラックボールを動かすと自動的にマウスレイヤー(6)に遷移する。

| 項目 | 値 |
|-----|-----|
| 対象レイヤー | Layer 6（Mouse） |
| タイムアウト | 10000ms（10秒） |
| require-prior-idle | 300ms（静止300ms後の操作で発動） |
| 除外キー位置 | `10 17 18 19 21 29 31` |

---

## トラックボール（PMW3610）設定

| 項目 | 値 |
|-----|-----|
| CPI | 600 |
| invert-x | 有効（COROPIT版） |
| force-awake | 有効 |
| SPI周波数 | 2MHz |

### レイヤー別トラックボール挙動

| レイヤー | 挙動 | スケール |
|---------|------|---------|
| 0〜3, 5, 6 | マウス移動 | 等倍（Automouseトリガー付き） |
| 3 | マウス移動 | 1/3倍（低速） |
| 4 | スクロール（X反転） | 1/5倍 |
| 7 | スクロール（Y反転） | 1/8倍 |
| 8〜10 | ジェスチャー認識 | — |

---

## ジェスチャー設定（共通）

| 項目 | 値 |
|-----|-----|
| stroke-size | 5 |
| movement-threshold | 6 |
| idle-timeout | 100ms |
| gesture-cooldown | 120ms |
| eager-mode | 有効 |

---

## エンコーダ設定

| レイヤー | 動作 |
|---------|------|
| 0, 1, 2, 3, 5, 6, 7, 11 | 上下スクロール |
| 4 (Nav Win) | `Ctrl+Tab` / `Ctrl+Shift+Tab` |
| 8 (Win Gesture Browser) | `Ctrl+-` / `Ctrl+=` |
| 9 (Win Gesture VDesk) | `Win+Ctrl+←` / `Win+Ctrl+→` |
| 10 (Win Gesture General) | `Alt+←` / `Alt+→` |
| 12 (Mac Nav) | `Cmd+Shift+]` / `Cmd+Shift+[` |
| 13 (Mac Gesture Browser) | `Cmd+-` / `Cmd+=` |
| 14 (Mac Gesture VDesk) | `Ctrl+←` / `Ctrl+→` |
| 15 (Mac Gesture General) | `Cmd+←` / `Cmd+→` |
| 16 (App Switcher) | `Shift+Tab` / `Tab` |

---

## Bluetooth設定

Layer 5で操作。

| キー | 機能 |
|-----|------|
| BT_0〜4 | デバイス0〜4を選択 |
| BT_CLR | 現在のBTペアリング解除 |
| BT_CLR_ALL | 全ペアリング解除 |
| BOOT | ブートローダモード |

---

## 使用モジュール

| モジュール | 用途 | 作者 |
|-----------|------|------|
| zmk-pmw3610-driver | PMW3610センサドライバ | badjeff |
| zmk-rgbled-widget | RGB LED表示 | caksoylar |
| zmk-input-processor-keybind | 入力プロセッサ | zettaface |
| zmk-mouse-gesture | マウスジェスチャー認識 | kot149 |
| zmk-listeners | レイヤーリスナー | ssbb |

---

## COROPIT版での設定変更

`boards/shields/mona2/mona2_r.overlay` を以下のように修正：

**修正前（デフォルト）:**
```c
cpi = <600>;
//swap-xy;
//invert-x;
//invert-y;
```

**修正後（COROPIT版）:**
```c
cpi = <600>;
//swap-xy;
invert-x;
invert-y;
```
