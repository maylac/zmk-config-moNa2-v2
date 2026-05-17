#!/bin/sh
set -eu

keymap="config/mona2.keymap"

if rg -n 'bindings = <&kp [A-Z]+\(.*\)>' config/gesture; then
  echo "gesture bindings must use explicit modifier macros so modifiers go down before keys" >&2
  exit 1
fi

check_macro() {
  macro="$1"
  modifier_pattern="$2"
  block="$(awk "/${macro}: ${macro} \\{/{flag=1} flag{print} /label = \"${macro}\";/{if(flag){exit}}" "$keymap")"

  if ! printf '%s\n' "$block" | rg -q 'compatible = "zmk,behavior-macro-one-param";'; then
    echo "${macro} must be a one-param macro" >&2
    exit 1
  fi

  if ! printf '%s\n' "$block" | rg -q "macro_press.*${modifier_pattern}"; then
    echo "${macro} must press ${modifier_pattern} before tapping the key" >&2
    exit 1
  fi

  if ! printf '%s\n' "$block" | rg -q '&macro_param_1to1'; then
    echo "${macro} must forward its key parameter" >&2
    exit 1
  fi

  if ! printf '%s\n' "$block" | rg -q "macro_release.*${modifier_pattern}"; then
    echo "${macro} must release ${modifier_pattern} after tapping the key" >&2
    exit 1
  fi
}

check_macro 'lg_key' 'LGUI'
check_macro 'lc_key' 'LCTRL'
check_macro 'la_key' 'LALT'
check_macro 'ls_key' 'LSHFT'
check_macro 'lc_ls_key' 'LCTRL.*LSHFT|LSHFT.*LCTRL'
check_macro 'lg_ls_key' 'LGUI.*LSHFT|LSHFT.*LGUI'
check_macro 'lg_lc_key' 'LGUI.*LCTRL|LCTRL.*LGUI'
check_macro 'lg_lc_ls_key' 'LGUI.*LCTRL.*LSHFT|LSHFT.*LCTRL.*LGUI'

if rg -n 'sensor-bindings = <&inc_dec_kp [^;]*[A-Z]+\(.*\)>' "$keymap"; then
  echo "sensor bindings must use explicit rotate behaviors when modifiers are required" >&2
  exit 1
fi

check_binding() {
  file="$1"
  expected="$2"

  if ! rg -q "$expected" "$file"; then
    echo "${file} missing expected ordered gesture binding: ${expected}" >&2
    exit 1
  fi
}

check_binding config/gesture/gesture_app_switch.dtsi 'app_prev .*bindings = <&ls_key TAB>;'
check_binding config/gesture/gesture_general_mac.dtsi 'focus_url .*bindings = <&lg_key L>;'
check_binding config/gesture/gesture_general_mac.dtsi 'spotlight .*bindings = <&lg_key SPACE>;'
check_binding config/gesture/gesture_general_mac.dtsi 'browser_back .*bindings = <&lg_key LEFT>;'
check_binding config/gesture/gesture_general_mac.dtsi 'browser_forward .*bindings = <&lg_key RIGHT>;'
check_binding config/gesture/gesture_vdesk_mac.dtsi 'vdesk_prev .*bindings = <&lc_key LEFT>;'
check_binding config/gesture/gesture_vdesk_mac.dtsi 'vdesk_next .*bindings = <&lc_key RIGHT>;'
check_binding config/gesture/gesture_vdesk_mac.dtsi 'mission_control .*bindings = <&lc_key UP>;'
check_binding config/gesture/gesture_vdesk_mac.dtsi 'vdesk_send_next .*bindings = <&lc_ls_key RIGHT>;'

echo "Gesture modifier macro ordering looks consistent."
