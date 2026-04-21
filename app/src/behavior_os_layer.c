#include <zephyr/kernel.h>
#include <zephyr/init.h>
#include <zmk/keymap.h>
#include <zmk/event_manager.h>
#include <zmk/events/ble_active_profile_changed.h>
#include <zmk/ble.h>

// moNa2 レイヤ構成:
//   Layer  0: Windows ベース
//   Layer 10: Mac オーバーレイ（&trans で Layer 0 に透過）
#define MAC_LAYER 10

static void update_os_layers(uint8_t profile) {
    switch (profile) {
        case 0:
        case 1:
            // Windows
            zmk_keymap_layer_deactivate(MAC_LAYER);
            break;
        case 2:
        case 3:
        case 4:
        default:
            // Mac / iOS
            zmk_keymap_layer_activate(MAC_LAYER);
            break;
    }
}

static int os_layer_listener_cb(const zmk_event_t *eh) {
    const struct zmk_ble_active_profile_changed *ev =
        as_zmk_ble_active_profile_changed(eh);
    if (ev) {
        update_os_layers(ev->index);
    }
    return ZMK_EV_EVENT_BUBBLE;
}

ZMK_LISTENER(os_layer_listener, os_layer_listener_cb);
ZMK_SUBSCRIPTION(os_layer_listener, zmk_ble_active_profile_changed);

static int behavior_os_layer_init(void) {
    update_os_layers(zmk_ble_active_profile_index());
    return 0;
}

SYS_INIT(behavior_os_layer_init, APPLICATION, 95);
