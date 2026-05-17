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
check_combo_layer 'general_win' 0
check_combo_layer 'Select_All_win' 0
check_combo_layer 'app_sw_mac' 1
check_combo_layer 'general_mac' 1
check_combo_layer 'Select_All_mac' 1

check_combo_positions() {
  combo="$1"
  expected="$2"
  block="$(awk "/${combo} \\{/{flag=1} flag{print} /^[[:space:]]*};/{if(flag){exit}}" config/mona2.keymap)"

  if ! printf '%s\n' "$block" | rg -q "key-positions = <${expected}>;"; then
    echo "${combo} must use key positions ${expected}" >&2
    exit 1
  fi
}

check_combo_positions 'app_sw_win' '19 20'
check_combo_positions 'app_sw_mac' '19 20'
check_combo_positions 'general_win' '8 9'
check_combo_positions 'general_mac' '8 9'

for removed_combo in Scroll_toggle; do
  if rg -q "^[[:space:]]*${removed_combo}[[:space:]]*\\{" config/mona2.keymap; then
    echo "${removed_combo} combo must not activate a layer" >&2
    exit 1
  fi
done

if rg -q '<&tog 7>' config/mona2.keymap; then
  echo "Layer 7 scroll toggle binding must be removed" >&2
  exit 1
fi

check_vdesk_combo() {
  combo="$1"
  layer="$2"
  scope="$3"
  block="$(awk "/${combo} \\{/{flag=1} flag{print} /^[[:space:]]*};/{if(flag){exit}}" config/mona2.keymap)"

  if ! printf '%s\n' "$block" | rg -q "bindings = <&mo ${layer}>;"; then
    echo "${combo} must activate VDesk layer ${layer}" >&2
    exit 1
  fi

  if ! printf '%s\n' "$block" | rg -q 'key-positions = <30 32>;'; then
    echo "${combo} must use comma+slash, not W+E or comma+dot, as the VDesk switcher" >&2
    exit 1
  fi

  if ! printf '%s\n' "$block" | rg -q "layers = <${scope}>;"; then
    echo "${combo} must be scoped to layer ${scope}" >&2
    exit 1
  fi

  if ! printf '%s\n' "$block" | rg -q 'timeout-ms = <100>;'; then
    echo "${combo} must allow a 100ms VDesk combo window" >&2
    exit 1
  fi

  if ! printf '%s\n' "$block" | rg -q 'slow-release;'; then
    echo "${combo} must hold VDesk until both combo keys are released" >&2
    exit 1
  fi
}

check_vdesk_combo 'vdesk_win' 10 0
check_vdesk_combo 'vdesk_mac' 11 1

check_app_switch_combo() {
  combo="$1"
  block="$(awk "/${combo} \\{/{flag=1} flag{print} /^[[:space:]]*};/{if(flag){exit}}" config/mona2.keymap)"

  if ! printf '%s\n' "$block" | rg -q 'timeout-ms = <100>;'; then
    echo "${combo} must allow a 100ms O+P combo window" >&2
    exit 1
  fi

  if ! printf '%s\n' "$block" | rg -q 'slow-release;'; then
    echo "${combo} must hold App Switcher until both combo keys are released" >&2
    exit 1
  fi
}

check_app_switch_macro() {
  macro="$1"
  modifier="$2"
  block="$(awk "/${macro}: ${macro} \\{/{flag=1} flag{print} /label = \"APP_SW_/{if(flag){exit}}" config/mona2.keymap)"

  if ! printf '%s\n' "$block" | rg -q 'wait-ms = <30>;'; then
    echo "${macro} must use a 30ms wait so Alt/Cmd+Tab is ordered reliably" >&2
    exit 1
  fi

  if ! printf '%s\n' "$block" | rg -q 'tap-ms = <40>;'; then
    echo "${macro} must hold tapped TAB for 40ms" >&2
    exit 1
  fi

  if ! printf '%s\n' "$block" | rg -q "<&macro_press &kp ${modifier} &mo 14>"; then
    echo "${macro} must press ${modifier} and activate Layer 14" >&2
    exit 1
  fi

  if ! printf '%s\n' "$block" | rg -q '<&macro_tap &kp TAB>'; then
    echo "${macro} must tap TAB once to open the OS app switcher" >&2
    exit 1
  fi

  if ! printf '%s\n' "$block" | rg -q "<&macro_release &kp ${modifier} &mo 14>"; then
    echo "${macro} must release ${modifier} and Layer 14 together" >&2
    exit 1
  fi
}

check_app_switch_combo 'app_sw_win'
check_app_switch_combo 'app_sw_mac'
check_app_switch_macro 'app_sw_win' 'LALT'
check_app_switch_macro 'app_sw_mac' 'LGUI'

check_general_combo() {
  combo="$1"
  block="$(awk "/${combo} \\{/{flag=1} flag{print} /^[[:space:]]*};/{if(flag){exit}}" config/mona2.keymap)"

  if ! printf '%s\n' "$block" | rg -q 'timeout-ms = <100>;'; then
    echo "${combo} must allow a 100ms O+P combo window" >&2
    exit 1
  fi

  if ! printf '%s\n' "$block" | rg -q 'slow-release;'; then
    echo "${combo} must hold General Gesture until both combo keys are released" >&2
    exit 1
  fi
}

check_general_combo 'general_win'
check_general_combo 'general_mac'

if rg -q 'locking;' config/mona2.keymap; then
  echo "ZMK v0.3 toggle-layer binding does not support locking" >&2
  exit 1
fi

if ! rg -q 'win_mode: win_mode \{' config/mona2.keymap; then
  echo "missing win_mode block" >&2
  exit 1
fi

win_block="$(awk '/win_mode: win_mode \{/{flag=1} flag{print} /label = "WIN_MODE";/{exit}' config/mona2.keymap)"
if ! printf '%s\n' "$win_block" | rg -q '<&macro_release &kp LALT &kp LGUI>'; then
  echo "win_mode must release GUI/Alt before changing the OS layer" >&2
  exit 1
fi

if ! printf '%s\n' "$win_block" | rg -q '<&macro_tap &tog_on 1>'; then
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

if ! printf '%s\n' "$mac_block" | rg -q '<&macro_tap &tog_off 1>'; then
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

if ! rg -q '^CONFIG_RGBLED_WIDGET_LAYER_6_COLOR=0$' config/mona2_r.conf; then
  echo "layer 6 (mouse) LED color must be black/off (0)" >&2
  exit 1
fi

if ! rg -q '^CONFIG_RGBLED_WIDGET_LAYER_7_COLOR=0$' config/mona2_r.conf; then
  echo "layer 7 (scroll) LED color must be black/off (0)" >&2
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
