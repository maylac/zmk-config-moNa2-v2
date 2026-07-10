# Kanary と音声入力のショートカット競合を分離する

- 日付: 2026-07-11
- 領域: zmk-config-moNa2-v2 / macOS 入力
- 種別: design-tradeoff

## 問題

右 Command を Aqua Voice の起動に使っていたため、Kanary の「右 Command 単押しで日本語入力」と競合していた。Karabiner でも LANG キーと Command の IME 変換を重ねており、入力方式の担当が複数あった。

## 試して駄目だった道

- Karabiner だけで LANG1/LANG2 と Command の IME 変換を続ける: Kanary の Command 判定と二重処理になる。
- Aqua Voice に右 Command を残す: Kanary が日本語切替に使うキーを音声入力が消費する。
- Typeless の `Left Option` 単独を維持する: 通常の Option 修飾操作でも音声入力が始まる。

## 効いたアプローチ

1. IME の責務を Kanary に一本化し、Karabiner の Command/LANG 用 IME ルールを削除する。
2. Mac レイヤーでは `LANG2` を左 Command（英数）、`LANG1` を右 Command（日本語）として出力する。LANG1 のホールドによる Nav レイヤーは保持する。
3. 親指二本の明示的なコンボを音声入力に割り当てる。`Space + LANG1` は Aqua Voice の `F18` ホールド、`Space + Enter` は Typeless の `F19` ホールドにする。

## なぜ効いたか

Kanary は左右の Command キーを区別して入力モードを固定選択する。moNa2 側でその HID 出力を直接作れば、IME 切替に Karabiner のキー変換は不要になる。音声入力はアプリ固有の未使用ファンクションキーへ退避し、物理側では通常入力中に誤発火しにくい両親指コンボで送るため、IME と音声操作が独立する。

## 一般化できる原則

- 1つの入力動作は、IME・リマッパー・アプリのうち1つだけを責務の所有者にすること。
- 修飾キーを OS レベルの入力切替に使う場合、アプリ固有の起動キーには専用の未使用 HID キーを使うこと。
- 常時待受けの音声入力は、通常の修飾キー単独ではなく明示的な両手または両親指コンボにすること。
