# BT Profile OS Mapping Design

## Goal

Make each Bluetooth profile `BT0..BT4` remember its own Win/Mac default layer, so selecting `BTn` later restores the previously saved OS mode automatically.

## Constraints

- The implementation must align with `cormoran/zmk-feature-default-layer`.
- The module documents `&df DF_SEL N` as setting the default layer for the active endpoint.
- Layer 4 should remain usable as a compact settings layer.

## Chosen Approach

Use Layer 4 for two separate actions:

1. `BT0..BT4` select the active Bluetooth endpoint.
2. `Win` / `Mac` apply `&df DF_SEL 0` or `&df DF_SEL 10` to the current active endpoint.

This keeps normal usage simple:

- Daily use: press `BTn` only.
- Initial setup or changes: press `BTn`, then press `Win` or `Mac` once to save that profile's base layer.

## Why This Approach

- It matches the default-layer module's documented storage model.
- It avoids hidden cross-profile state in the keymap itself.
- It preserves per-profile flexibility without requiring combined `Win+BTn` / `Mac+BTn` keys for routine switching.

## Layer 4 Layout

- Right hand top row: `BT0..BT4`
- Left hand dedicated keys: `Set Win`, `Set Mac`
- Existing maintenance actions stay available: `bootloader`, `BT CLR`, `BT CLR ALL`

## Verification

- Static regression check confirms Layer 4 contains direct `BT_SEL` bindings plus separate `win_mode` / `mac_mode` bindings.
- `git diff --check` ensures clean patch formatting.
