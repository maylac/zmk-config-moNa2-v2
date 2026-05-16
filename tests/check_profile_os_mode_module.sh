#!/bin/sh
set -eu

if ! test -f app/src/profile_os_mode.c; then
  echo "missing local profile os mode module source" >&2
  exit 1
fi

if ! rg -q 'zephyr_library_sources_ifdef\(CONFIG_ZMK_BEHAVIOR_OS_LAYER app/src/profile_os_mode.c\)' CMakeLists.txt; then
  echo "missing module CMake wiring" >&2
  exit 1
fi

if ! rg -q 'config ZMK_BEHAVIOR_OS_LAYER' app/Kconfig; then
  echo "missing module Kconfig entry" >&2
  exit 1
fi

if ! rg -q 'depends on ZMK_SPLIT_ROLE_CENTRAL' app/Kconfig; then
  echo "profile OS module must be limited to the central half" >&2
  exit 1
fi

if rg -q 'behaviors/default_layer.dtsi|zmk_behavior_default_layer/default_layer.h' config/mona2.keymap; then
  echo "legacy default-layer module includes are still present" >&2
  exit 1
fi

if rg -q 'CONFIG_ZMK_DEFAULT_LAYER=y|CONFIG_ZMK_DEFAULT_LAYER_MIN_INDEX|CONFIG_ZMK_DEFAULT_LAYER_MAX_INDEX' config/mona2_l.conf config/mona2_r.conf; then
  echo "legacy default-layer Kconfig is still present" >&2
  exit 1
fi

if rg -q 'CONFIG_ZMK_BEHAVIOR_OS_LAYER=y' config/mona2_l.conf; then
  echo "left-half config must not enable profile OS mode module" >&2
  exit 1
fi

if ! rg -q 'CONFIG_ZMK_BEHAVIOR_OS_LAYER=y' config/mona2_r.conf; then
  echo "right-half config must enable profile OS mode module" >&2
  exit 1
fi

if ! rg -q '#define MAC_LAYER 1' app/src/profile_os_mode.c; then
  echo "profile OS module must use default_mac layer 1 in the common two-base-layer layout" >&2
  exit 1
fi

if ! rg -q '#define BT_LAYER 15' app/src/profile_os_mode.c; then
  echo "profile OS module must save when the single BT/System layer 15 is released" >&2
  exit 1
fi

if rg -q '#define WIN_LAYER|zmk_keymap_layer_activate\(WIN_LAYER\)|zmk_keymap_layer_deactivate\(WIN_LAYER\)' app/src/profile_os_mode.c; then
  echo "profile OS module must not need a separate Win indicator layer" >&2
  exit 1
fi

if rg -q 'zmk-feature-default-layer|cormoran' config/west.yml; then
  echo "legacy default-layer west dependency is still present" >&2
  exit 1
fi

echo "Profile OS mode module wiring looks consistent."
