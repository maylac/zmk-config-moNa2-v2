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

check_binding "gesture_vdesk_win" 'sensor-bindings = <&vdesk_win_steps>;'
check_binding "gesture_general_win" 'sensor-bindings = <&window_zoom_win_steps>;'
check_binding "gesture_vdesk_mac" 'sensor-bindings = <&vdesk_mac_steps>;'
check_binding "gesture_general_mac" 'sensor-bindings = <&window_zoom_mac_steps>;'
check_binding "app_switch" 'sensor-bindings = <&app_switch_steps>;'

echo "Missing encoder layer bindings look consistent."
