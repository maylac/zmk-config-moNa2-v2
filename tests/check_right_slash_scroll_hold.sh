#!/bin/sh
set -eu

keymap="config/mona2.keymap"

if ! rg -q '&lt 7 SLASH' "$keymap"; then
  echo "right slash key must tap slash and hold scroll layer 7" >&2
  exit 1
fi

if rg -q '&mt RIGHT_SHIFT SLASH' "$keymap"; then
  echo "right slash key still holds Right Shift instead of scroll layer 7" >&2
  exit 1
fi

echo "Right slash scroll hold binding looks consistent."
