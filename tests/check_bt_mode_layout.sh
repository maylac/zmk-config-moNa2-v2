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

echo "BT mode layout looks consistent."
