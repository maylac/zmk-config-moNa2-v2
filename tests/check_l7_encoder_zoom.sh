#!/bin/sh
set -eu

keymap="config/mona2.keymap"

if ! rg -q 'sensor-bindings = <&inc_dec_kp LC\(MINUS\) LC\(EQUAL\)>;' "$keymap"; then
  echo "missing Win browser-gesture encoder zoom binding" >&2
  exit 1
fi

if ! rg -q 'sensor-bindings = <&inc_dec_kp LG\(MINUS\) LG\(EQUAL\)>;' "$keymap"; then
  echo "missing Mac browser-gesture encoder zoom binding" >&2
  exit 1
fi

if rg -q 'zoom_scroll: zoom_scroll|ctrl_scroll_up: ctrl_scroll_up|ctrl_scroll_down: ctrl_scroll_down' "$keymap"; then
  echo "legacy wheel-based zoom behavior is still present" >&2
  exit 1
fi

echo "Browser gesture encoder zoom bindings look consistent."
