#!/bin/sh
set -eu

if ! test -f app/src/profile_os_mode.c; then
  echo "missing local profile os mode module source" >&2
  exit 1
fi

if ! rg -q 'target_sources_ifdef\(CONFIG_ZMK_BEHAVIOR_OS_LAYER app PRIVATE src/profile_os_mode.c\)' app/CMakeLists.txt; then
  echo "missing module CMake wiring" >&2
  exit 1
fi

if ! rg -q 'config ZMK_BEHAVIOR_OS_LAYER' app/Kconfig; then
  echo "missing module Kconfig entry" >&2
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

if rg -q 'zmk-feature-default-layer|cormoran' config/west.yml; then
  echo "legacy default-layer west dependency is still present" >&2
  exit 1
fi

echo "Profile OS mode module wiring looks consistent."
