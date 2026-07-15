# Kanary と音声入力のショートカットを Karabiner なしで分離する

- 日付: 2026-07-15
- 領域: zmk-config-moNa2-v2 / macOS 入力
- 種別: design-tradeoff

## 問題

右 Command 単独を Aqua Voice の起動に使うと、Kanary の「右 Command 単押しで日本語入力」と競合する。一方、音声入力を `F18` / `F19` に退避すると moNa2 では安全だが、MacBook 内蔵キーボードから押すためだけに Karabiner が必要になった。moNa2 と MacBook の双方から、隣接キーの同時押しで同じアプリを操作する必要があった。

## 試して駄目だった道

- Karabiner だけで LANG1/LANG2 と Command の IME 変換を続ける: Kanary の Command 判定と二重処理になる。
- Aqua Voice に右 Command **単独**を残す: Kanary が日本語切替に使うキーを音声入力が消費する。
- Typeless の `Left Option` 単独を維持する: 通常の Option 修飾操作でも音声入力が始まる。
- `F18` / `F19` をアプリ側の基準にする: moNa2 では安全だが、MacBook 側に専用キーがなく、リマッパー依存になる。
- `Fn + Left Control` を共通化する: Aqua Voice は `Fn` を認識するが、Apple の Fn/Globe は標準 USB HID 修飾キーではなく、ZMK から同じ信号を送れない。

## 効いたアプローチ

1. IME の責務を Kanary に一本化する。Mac レイヤーでは `LANG2` を左 Command（英数）、`LANG1` を右 Command（日本語）として出力する。
2. Aqua Voice の起動を `Right Command + Right Option`、Typeless の音声入力を `Left Option + Left Command` にする。どちらも MacBook 下段の隣接ペアである。
3. moNa2 の既存物理コンボ位置は維持し、`Space + LANG1` から右 Command + 右 Option、`Space + Enter` から左 Option + 左 Command をホールド出力する。
4. MacBook と moNa2 が同じ通常 HID 修飾キーを直接送るため、Karabiner を経路から外す。

## なぜ効いたか

Apple Fn/Globe と違い、左右の Command / Option は標準 HID 修飾キーなので、MacBook と ZMK の両方から同一信号を送れる。Command 単独ではなく左右を限定した2修飾キーの組にすることで、Kanary の単独タップ操作と音声入力を分離できる。Aqua Voice と Typeless の保存値は再起動後も維持され、リポジトリの全シェルテストと `git diff --check` が成功した。

## 一般化できる原則

- 1つの入力動作は、IME・リマッパー・アプリのうち1つだけを責務の所有者にすること。
- 複数キーボードでショートカットを共通化するときは、すべての機器が送れる標準 HID キーだけで構成すること。
- 常時待受けの音声入力は修飾キー単独ではなく、通常操作と区別できる左右限定の隣接ペアにすること。
