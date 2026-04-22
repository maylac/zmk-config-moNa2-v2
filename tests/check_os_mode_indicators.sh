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

if ! printf '%s\n' "$win_block" | rg -q '<&tog_on 10>'; then
  echo "win_mode must force layer 10 on before turning it off" >&2
  exit 1
fi

if ! printf '%s\n' "$win_block" | rg -q '<&tog_off 10>'; then
  echo "win_mode must force a layer-10 on->off transition" >&2
  exit 1
fi

mac_block="$(awk '/mac_mode: mac_mode \{/{flag=1} flag{print} /label = "MAC_MODE";/{exit}' config/mona2.keymap)"
if ! printf '%s\n' "$mac_block" | rg -q '<&macro_release &kp LALT &kp LGUI>'; then
  echo "mac_mode must release GUI/Alt before changing the OS layer" >&2
  exit 1
fi

if ! printf '%s\n' "$mac_block" | rg -q '<&tog_off 10>'; then
  echo "mac_mode must force layer 10 off before turning it on" >&2
  exit 1
fi

if ! printf '%s\n' "$mac_block" | rg -q '<&tog_on 10>'; then
  echo "mac_mode must force a layer-10 off->on transition" >&2
  exit 1
fi

if ! rg -q '^CONFIG_RGBLED_WIDGET_LAYER_1_COLOR=3$' config/mona2_r.conf; then
  echo "layer 1 LED color must be yellow" >&2
  exit 1
fi

if ! rg -q '^CONFIG_RGBLED_WIDGET_LAYER_2_COLOR=4$' config/mona2_r.conf; then
  echo "layer 2 LED color must be blue" >&2
  exit 1
fi

if ! rg -q '^CONFIG_RGBLED_WIDGET_LAYER_3_COLOR=6$' config/mona2_r.conf; then
  echo "layer 3 LED color must be cyan" >&2
  exit 1
fi

if ! rg -q '^CONFIG_RGBLED_WIDGET_LAYER_5_COLOR=5$' config/mona2_r.conf; then
  echo "layer 5 LED color must be magenta" >&2
  exit 1
fi

if ! rg -q '^CONFIG_RGBLED_WIDGET_LAYER_11_COLOR=6$' config/mona2_r.conf; then
  echo "layer 11 LED color must be cyan" >&2
  exit 1
fi

echo "OS mode macros and LED colors look consistent."
