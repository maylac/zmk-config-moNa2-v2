#include <errno.h>
#include <string.h>

#include <zephyr/init.h>
#include <zephyr/settings/settings.h>
#include <zmk/ble.h>
#include <zmk/event_manager.h>
#include <zmk/events/ble_active_profile_changed.h>
#include <zmk/events/layer_state_changed.h>
#include <zmk/keymap.h>

#define MAC_LAYER 10
#define BT_LAYER 4
#define SETTINGS_NAME "mona2/os_profile_map"

enum profile_os_mode {
    PROFILE_OS_WIN = 0,
    PROFILE_OS_MAC = 1,
};

static uint8_t profile_os_map[ZMK_BLE_PROFILE_COUNT];

static void apply_os_mode(uint8_t mode) {
    if (mode == PROFILE_OS_MAC) {
        zmk_keymap_layer_activate(MAC_LAYER);
    } else {
        zmk_keymap_layer_deactivate(MAC_LAYER);
    }
}

static void apply_active_profile_os_mode(void) {
    int profile = zmk_ble_active_profile_index();

    if (profile < 0 || profile >= ZMK_BLE_PROFILE_COUNT) {
        return;
    }

    apply_os_mode(profile_os_map[profile]);
}

static int save_active_profile_os_mode(uint8_t mode) {
    int profile = zmk_ble_active_profile_index();

    if (profile < 0 || profile >= ZMK_BLE_PROFILE_COUNT) {
        return -EINVAL;
    }

    profile_os_map[profile] = mode;
    return settings_save_one(SETTINGS_NAME, profile_os_map, sizeof(profile_os_map));
}

static int profile_os_mode_settings_set(const char *name, size_t len, settings_read_cb read_cb,
                                        void *cb_arg) {
    const char *next;
    int rc;

    if (!settings_name_steq(name, "os_profile_map", &next) || next) {
        return -ENOENT;
    }

    if (len > sizeof(profile_os_map)) {
        return -EINVAL;
    }

    rc = read_cb(cb_arg, profile_os_map, len);
    return rc >= 0 ? 0 : rc;
}

static int profile_os_mode_settings_commit(void) {
    apply_active_profile_os_mode();
    return 0;
}

SETTINGS_STATIC_HANDLER_DEFINE(profile_os_mode, "mona2", NULL, profile_os_mode_settings_set,
                               profile_os_mode_settings_commit, NULL);

static int profile_os_mode_listener(const zmk_event_t *eh) {
    const struct zmk_ble_active_profile_changed *profile_ev =
        as_zmk_ble_active_profile_changed(eh);
    if (profile_ev) {
        if (profile_ev->index < ZMK_BLE_PROFILE_COUNT) {
            apply_os_mode(profile_os_map[profile_ev->index]);
        }
        return ZMK_EV_EVENT_BUBBLE;
    }

    const struct zmk_layer_state_changed *layer_ev = as_zmk_layer_state_changed(eh);
    if (layer_ev && layer_ev->layer == MAC_LAYER && zmk_keymap_layer_active(BT_LAYER)) {
        save_active_profile_os_mode(layer_ev->state ? PROFILE_OS_MAC : PROFILE_OS_WIN);
    }

    return ZMK_EV_EVENT_BUBBLE;
}

ZMK_LISTENER(profile_os_mode_listener, profile_os_mode_listener);
ZMK_SUBSCRIPTION(profile_os_mode_listener, zmk_ble_active_profile_changed);
ZMK_SUBSCRIPTION(profile_os_mode_listener, zmk_layer_state_changed);

static int profile_os_mode_init(void) {
    apply_active_profile_os_mode();
    return 0;
}

SYS_INIT(profile_os_mode_init, APPLICATION, 95);
