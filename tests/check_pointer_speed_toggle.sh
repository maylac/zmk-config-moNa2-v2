#!/bin/sh
set -eu

keymap="config/mona2.keymap"
overlay="boards/shields/mona2/mona2_r.overlay"

if ! rg -q '^#define POINTER_FAST 16$' "$keymap"; then
  echo "missing POINTER_FAST layer define" >&2
  exit 1
fi

bt_layer_block="$(sed -n '/^[[:space:]]*bt {/,/^[[:space:]]*};/p' "$keymap")"
if ! printf '%s\n' "$bt_layer_block" | rg -q '&tog_off POINTER_FAST.*&tog_on POINTER_FAST'; then
  echo "BT/System layer must expose adjacent 600/off and 1000/on pointer speed keys" >&2
  exit 1
fi

if ! rg -q 'pointer_fast \{' "$keymap"; then
  echo "missing pointer_fast keymap layer" >&2
  exit 1
fi

fast_block="$(sed -n '/^[[:space:]]*pointer_fast {/,/^[[:space:]]*};/p' "$keymap")"
if ! printf '%s\n' "$fast_block" | rg -q 'sensor-bindings = <&scroll_up_down>;'; then
  echo "pointer_fast layer must keep the default encoder binding" >&2
  exit 1
fi

if ! rg -q 'layers = <POINTER_FAST>;' "$overlay"; then
  echo "right trackball overlay must include a POINTER_FAST layer override" >&2
  exit 1
fi

if ! rg -q 'input-processors = <&zip_xy_scaler 5 3>;' "$overlay"; then
  echo "POINTER_FAST layer must scale XY movement to 1000-equivalent from 600 CPI" >&2
  exit 1
fi

echo "Pointer speed toggle bindings look consistent."
