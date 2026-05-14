#!/bin/sh
set -eu

keymap="config/mona2.keymap"
layer_4_block="$(sed -n '/[[:space:]]bt {/,/^[[:space:]]*};/p' "$keymap")"

for pattern in \
  '&win_mode' \
  '&mac_mode' \
  '&bt BT_SEL 0' \
  '&bt BT_SEL 1' \
  '&bt BT_SEL 2' \
  '&bt BT_SEL 3' \
  '&bt BT_SEL 4'
do
  if ! printf '%s\n' "$layer_4_block" | rg -q "$pattern"; then
    echo "missing layer 4 binding: ${pattern}" >&2
    exit 1
  fi
done

if rg -q 'bt_win_[0-4]: bt_win_[0-4]|bt_mac_[0-4]: bt_mac_[0-4]' "$keymap"; then
  echo "legacy combined BT/OS macros are still present" >&2
  exit 1
fi

if printf '%s\n' "$layer_4_block" | rg -q '&bt_(win|mac)_[0-4]'; then
  echo "layer 4 still uses combined BT/OS macros" >&2
  exit 1
fi

bt_combo_block="$(awk '/BT_layer \{/{flag=1} flag{print} /^[[:space:]]*};/{if(flag){exit}}' "$keymap")"
if ! printf '%s\n' "$bt_combo_block" | rg -q 'slow-release;'; then
  echo "BT layer combo must use slow-release so the momentary layer stays active until both combo keys are released" >&2
  exit 1
fi

if ! rg -q 'mt_lang2: mt_lang2' "$keymap"; then
  echo "missing BT-safe LANG2 mod-tap behavior" >&2
  exit 1
fi

mt_lang2_block="$(awk '/mt_lang2: mt_lang2 \{/{flag=1} flag{print} /^[[:space:]]*};/{if(flag){exit}}' "$keymap")"
if ! printf '%s\n' "$mt_lang2_block" | rg -q 'hold-trigger-key-positions = <0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 40 41>'; then
  echo "mt_lang2 must exclude LANG1 position 39 so LANG2+LANG1 can resolve as the BT combo" >&2
  exit 1
fi

if ! rg -q '&mt_lang2 LGUI LANG2' "$keymap"; then
  echo "default layer must use BT-safe &mt_lang2 for LANG2" >&2
  exit 1
fi

echo "BT mode layout looks consistent."
