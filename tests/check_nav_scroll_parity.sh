#!/bin/sh
set -eu

overlay="boards/shields/mona2/mona2_r.overlay"

scroller_block="$(sed -n '/^[[:space:]]*scroller {/,/^[[:space:]]*};/p' "$overlay")"
if [ -z "$scroller_block" ]; then
  echo "missing scroller node in right trackball overlay" >&2
  exit 1
fi

if ! printf '%s\n' "$scroller_block" | rg -q 'layers = <4 5>;'; then
  echo "trackball scroller must cover both nav_win (4) and nav_mac (5) so the same fingering scrolls on both OS modes" >&2
  exit 1
fi

echo "Nav scroll parity looks consistent."
