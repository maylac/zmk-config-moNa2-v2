#!/bin/sh
set -eu

if ! rg -q 'win_mode: win_mode' config/mona2.keymap; then
  echo "missing win_mode macro" >&2
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

if ! printf '%s\n' "$win_block" | rg -q '<&tog_on 11>'; then
  echo "win_mode must force layer 11 on before turning it off" >&2
  exit 1
fi

if ! printf '%s\n' "$win_block" | rg -q '<&tog_off 11>'; then
  echo "win_mode must force a layer-11 on->off transition" >&2
  exit 1
fi

mac_block="$(awk '/mac_mode: mac_mode \{/{flag=1} flag{print} /label = "MAC_MODE";/{exit}' config/mona2.keymap)"
if ! printf '%s\n' "$mac_block" | rg -q '<&macro_release &kp LALT &kp LGUI>'; then
  echo "mac_mode must release GUI/Alt before changing the OS layer" >&2
  exit 1
fi

if ! printf '%s\n' "$mac_block" | rg -q '<&tog_off 11>'; then
  echo "mac_mode must force layer 11 off before turning it on" >&2
  exit 1
fi

if ! printf '%s\n' "$mac_block" | rg -q '<&tog_on 11>'; then
  echo "mac_mode must force a layer-11 off->on transition" >&2
  exit 1
fi

# L1 (indicator_win) must NOT set a color (Win mode = LED off)
if rg -q '^CONFIG_RGBLED_WIDGET_LAYER_1_COLOR=' config/mona2_r.conf; then
  echo "layer 1 (indicator_win) must not have a color set — Win mode should show no LED" >&2
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

if ! rg -q '^CONFIG_RGBLED_WIDGET_LAYER_5_COLOR=5$' config/mona2_r.conf; then
  echo "layer 5 (bt) LED color must be magenta (5)" >&2
  exit 1
fi

# L6 (mouse) and L7 (scroll) must NOT set a color
if rg -q '^CONFIG_RGBLED_WIDGET_LAYER_6_COLOR=' config/mona2_r.conf; then
  echo "layer 6 (mouse) must not have a color set — should be off" >&2
  exit 1
fi

if rg -q '^CONFIG_RGBLED_WIDGET_LAYER_7_COLOR=' config/mona2_r.conf; then
  echo "layer 7 (scroll) must not have a color set — should be off" >&2
  exit 1
fi

if ! rg -q '^CONFIG_RGBLED_WIDGET_LAYER_11_COLOR=2$' config/mona2_r.conf; then
  echo "layer 11 (default_mac) LED color must be green (2)" >&2
  exit 1
fi

if ! rg -q '^CONFIG_RGBLED_WIDGET_LAYER_12_COLOR=6$' config/mona2_r.conf; then
  echo "layer 12 (nav_mac) LED color must be cyan (6)" >&2
  exit 1
fi

echo "OS mode macros and LED colors look consistent."
