#!/bin/sh
set -eu

repo_root="$(git rev-parse --show-toplevel)"
cd "$repo_root"

for check in \
  tests/check_bt_mode_layout.sh \
  tests/check_os_mode_indicators.sh \
  tests/check_profile_os_mode_module.sh \
  tests/check_gesture_macro_ordering.sh \
  tests/check_right_slash_scroll_hold.sh \
  tests/check_pointer_speed_toggle.sh \
  tests/check_nav_scroll_parity.sh \
  tests/check_l7_encoder_zoom.sh \
  tests/check_missing_encoder_layers.sh \
  tests/check_git_hooks.sh
do
  sh "$check"
done

git diff --check --cached
