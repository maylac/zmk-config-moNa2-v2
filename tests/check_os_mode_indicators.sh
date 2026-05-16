#!/bin/sh
set -eu

if ! rg -q 'win_mode: win_mode' config/mona2.keymap; then
  echo "missing win_mode macro" >&2
  exit 1
fi

if rg -q 'indicator_win' config/mona2.keymap README.md; then
  echo "indicator_win must be removed; layer 1 is the Mac base layer now" >&2
  exit 1
fi

if ! awk '/default_win \{/{seen_win=1} /default_mac \{/{if(!seen_win){exit 1}; seen_mac=1; exit} END{exit seen_mac ? 0 : 1}' config/mona2.keymap; then
  echo "default_mac must directly follow default_win so OS bases are layers 0 and 1" >&2
  exit 1
fi

check_combo_layer() {
  combo="$1"
  expected="$2"
  block="$(awk "/${combo} \\{/{flag=1} flag{print} /^[[:space:]]*};/{if(flag){exit}}" config/mona2.keymap)"

  if ! printf '%s\n' "$block" | rg -q "layers = <${expected}>;"; then
    echo "${combo} must be scoped to layer ${expected}" >&2
    exit 1
  fi
}

check_combo_layer 'app_sw_win' 0
check_combo_layer 'vdesk_win' 0
check_combo_layer 'general_win' 0
check_combo_layer 'Select_All_win' 0
check_combo_layer 'app_sw_mac' 1
check_combo_layer 'vdesk_mac' 1
check_combo_layer 'general_mac' 1
check_combo_layer 'Select_All_mac' 1

if ! rg -q 'win_mode: win_mode \{' config/mona2.keymap; then
  echo "missing win_mode block" >&2
  exit 1
fi

win_block="$(awk '/win_mode: win_mode \{/{flag=1} flag{print} /label = "WIN_MODE";/{exit}' config/mona2.keymap)"
if ! printf '%s\n' "$win_block" | rg -q '<&macro_release &kp LALT &kp LGUI>'; then
  echo "win_mode must release GUI/Alt before changing the OS layer" >&2
  exit 1
fi

if ! printf '%s\n' "$win_block" | rg -q '<&tog_on 1>'; then
  echo "win_mode must force Mac layer 1 on before turning it off" >&2
  exit 1
fi

if ! printf '%s\n' "$win_block" | rg -q '<&tog_off 1>'; then
  echo "win_mode must force a Mac layer 1 on->off transition" >&2
  exit 1
fi

mac_block="$(awk '/mac_mode: mac_mode \{/{flag=1} flag{print} /label = "MAC_MODE";/{exit}' config/mona2.keymap)"
if ! printf '%s\n' "$mac_block" | rg -q '<&macro_release &kp LALT &kp LGUI>'; then
  echo "mac_mode must release GUI/Alt before changing the OS layer" >&2
  exit 1
fi

if ! printf '%s\n' "$mac_block" | rg -q '<&tog_off 1>'; then
  echo "mac_mode must force Mac layer 1 off before turning it on" >&2
  exit 1
fi

if ! printf '%s\n' "$mac_block" | rg -q '<&tog_on 1>'; then
  echo "mac_mode must force a Mac layer 1 off->on transition" >&2
  exit 1
fi

if ! rg -q '^CONFIG_RGBLED_WIDGET_LAYER_0_COLOR=4$' config/mona2_r.conf; then
  echo "layer 0 (default_win) LED color must be blue (4)" >&2
  exit 1
fi

if ! rg -q '^CONFIG_RGBLED_WIDGET_LAYER_1_COLOR=2$' config/mona2_r.conf; then
  echo "layer 1 (default_mac) LED color must be green (2)" >&2
  exit 1
fi

if ! rg -q '^CONFIG_RGBLED_WIDGET_LAYER_2_COLOR=3$' config/mona2_r.conf; then
  echo "layer 2 (symbol) LED color must be yellow (3)" >&2
  exit 1
fi

if ! rg -q '^CONFIG_RGBLED_WIDGET_LAYER_3_COLOR=1$' config/mona2_r.conf; then
  echo "layer 3 (num_fn) LED color must be red (1)" >&2
  exit 1
fi

if ! rg -q '^CONFIG_RGBLED_WIDGET_LAYER_4_COLOR=6$' config/mona2_r.conf; then
  echo "layer 4 (nav_win) LED color must be cyan (6)" >&2
  exit 1
fi

if ! rg -q '^CONFIG_RGBLED_WIDGET_LAYER_5_COLOR=6$' config/mona2_r.conf; then
  echo "layer 5 (nav_mac) LED color must be cyan (6)" >&2
  exit 1
fi

if rg -q '^CONFIG_RGBLED_WIDGET_LAYER_6_COLOR=' config/mona2_r.conf; then
  echo "layer 6 (mouse) must not have a color set — should be off" >&2
  exit 1
fi

if rg -q '^CONFIG_RGBLED_WIDGET_LAYER_7_COLOR=' config/mona2_r.conf; then
  echo "layer 7 (scroll) must not have a color set — should be off" >&2
  exit 1
fi

if ! rg -q '^CONFIG_RGBLED_WIDGET_LAYER_8_COLOR=7$' config/mona2_r.conf; then
  echo "layer 8 (gesture_browser_win) LED color must be white (7)" >&2
  exit 1
fi

if ! rg -q '^CONFIG_RGBLED_WIDGET_LAYER_14_COLOR=7$' config/mona2_r.conf; then
  echo "layer 14 (app_switch) LED color must be white (7)" >&2
  exit 1
fi

if ! rg -q '^CONFIG_RGBLED_WIDGET_LAYER_15_COLOR=5$' config/mona2_r.conf; then
  echo "layer 15 (bt) LED color must be magenta (5)" >&2
  exit 1
fi

if rg -q '^CONFIG_RGBLED_WIDGET_LAYER_16_COLOR=' config/mona2_r.conf; then
  echo "layer 16 must not have a color after minimizing OS layers" >&2
  exit 1
fi

echo "OS mode macros and LED colors look consistent."
