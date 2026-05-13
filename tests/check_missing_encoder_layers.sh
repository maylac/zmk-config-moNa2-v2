#!/bin/sh
set -eu

keymap="config/mona2.keymap"

check_binding() {
  layer="$1"
  expected="$2"
  block="$(sed -n "/${layer} {/,/^[[:space:]]*};/p" "$keymap")"

  if ! printf '%s\n' "$block" | rg -q "$expected"; then
    echo "missing encoder binding for ${layer}: ${expected}" >&2
    exit 1
  fi
}

check_binding "gesture_vdesk_win" 'sensor-bindings = <&inc_dec_kp LG\(LC\(LEFT\)\) LG\(LC\(RIGHT\)\)>;'
check_binding "gesture_general_win" 'sensor-bindings = <&inc_dec_kp LA\(LEFT\) LA\(RIGHT\)>;'
check_binding "gesture_vdesk_mac" 'sensor-bindings = <&inc_dec_kp LC\(LEFT\) LC\(RIGHT\)>;'
check_binding "gesture_general_mac" 'sensor-bindings = <&inc_dec_kp LG\(LEFT\) LG\(RIGHT\)>;'
check_binding "app_switch" 'sensor-bindings = <&inc_dec_kp LS\(TAB\) TAB>;'

echo "Missing encoder layer bindings look consistent."
