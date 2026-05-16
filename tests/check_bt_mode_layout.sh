#!/bin/sh
set -eu

keymap="config/mona2.keymap"
bt_layer_block="$(sed -n '/^[[:space:]]*bt {/,/^[[:space:]]*};/p' "$keymap")"

for pattern in \
  '&win_mode' \
  '&mac_mode' \
  '&bt_0' \
  '&bt_1' \
  '&bt_2' \
  '&bt_3' \
  '&bt_4'
do
  if ! printf '%s\n' "$bt_layer_block" | rg -q "$pattern"; then
    echo "missing BT layer binding: ${pattern}" >&2
    exit 1
  fi
done

if rg -q 'bt_win_[0-4]: bt_win_[0-4]|bt_mac_[0-4]: bt_mac_[0-4]' "$keymap"; then
  echo "legacy combined BT/OS macros are still present" >&2
  exit 1
fi

if printf '%s\n' "$bt_layer_block" | rg -q '&bt_(win|mac)_[0-4]'; then
  echo "BT layer still uses combined BT/OS macros" >&2
  exit 1
fi

if printf '%s\n' "$bt_layer_block" | rg -q '&bt BT_SEL [0-4]'; then
  echo "BT layer must use bt_0..bt_4 macros instead of direct BT_SEL bindings" >&2
  exit 1
fi

bt_combo_block="$(awk '/BT_layer \{/{flag=1} flag{print} /^[[:space:]]*};/{if(flag){exit}}' "$keymap")"
if ! printf '%s\n' "$bt_combo_block" | rg -q 'bindings = <&mo 15>;'; then
  echo "BT layer combo must directly activate the single BT/System layer 15" >&2
  exit 1
fi

if ! printf '%s\n' "$bt_combo_block" | rg -q 'layers = <0 1>;'; then
  echo "BT layer combo must be available from Win base and Mac base only" >&2
  exit 1
fi

if ! printf '%s\n' "$bt_combo_block" | rg -q 'slow-release;'; then
  echo "BT layer combo must use slow-release so the momentary layer stays active until both combo keys are released" >&2
  exit 1
fi

if rg -q 'bt_layer_hold: bt_layer_hold|bt_indicator \{|reserved_bt \{' "$keymap"; then
  echo "BT layer must be a single real layer, not a low layer plus indicator/reserved layer" >&2
  exit 1
fi

if rg -q '^CONFIG_RGBLED_WIDGET_LAYER_15_COLOR=7$' config/mona2_r.conf; then
  echo "layer 15 is no longer app_switch and must not be white" >&2
  exit 1
fi

if ! rg -q '^CONFIG_RGBLED_WIDGET_LAYER_15_COLOR=5$' config/mona2_r.conf; then
  echo "BT/System layer 15 must be magenta so it is visible above Mac layer 1" >&2
  exit 1
fi

if rg -q '^CONFIG_RGBLED_WIDGET_LAYER_16_COLOR=' config/mona2_r.conf; then
  echo "layer 16 must not exist after reducing to the minimal OS-layer layout" >&2
  exit 1
fi

if ! rg -q '#include <dt-bindings/zmk/outputs.h>' "$keymap"; then
  echo "BT select macros should include output selection bindings" >&2
  exit 1
fi

for n in 0 1 2 3 4; do
  macro_block="$(awk "/bt_${n}: bt_${n} \\{/{flag=1} flag{print} /label = \"BT_${n}\";/{if(flag){exit}}" "$keymap")"
  if ! printf '%s\n' "$macro_block" | rg -q "<&out OUT_BLE>.*<&bt BT_SEL ${n}>|<&bt BT_SEL ${n}>"; then
    echo "missing bt_${n} macro with BT_SEL ${n}" >&2
    exit 1
  fi
done

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
