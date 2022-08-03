#include QMK_KEYBOARD_H
#include "version.h"

enum layers {
  BASE, // default layer
  FUNC, // funnctions
};

enum custom_keycodes {
    PASTE = SAFE_RANGE,
};

bool process_record_user(uint16_t keycode, keyrecord_t *record) {
    switch (keycode) {
    case PASTE:
        if (record->event.pressed) {
            // when keycode QMKBEST is pressed
            // SEND_STRING("QMK is the best thing ever!");
            SEND_STRING(SS_LSFT(C));
        } else {
            // when keycode QMKBEST is released
        }
        break;
    }
    return true;
};

// Left-hand home row mods
#define HOME_A LGUI_T(KC_A)
#define HOME_S LALT_T(KC_S)
#define HOME_D LSFT_T(KC_D)
#define HOME_F LCTL_T(KC_F)

// Right-hand home row mods
#define HOME_J RCTL_T(KC_J)
#define HOME_K RSFT_T(KC_K)
#define HOME_L LALT_T(KC_L)
#define HOME_SCLN RGUI_T(KC_SCLN)

// clang-format off
const uint16_t PROGMEM keymaps[][MATRIX_ROWS][MATRIX_COLS] = {
  /* Keymap 0: Basic layer
 *
 * ,--------------------------------------------------.           ,--------------------------------------------------.
 * |   `    |   1  |   2  |   3  |   4  |   5  |      |           |      |   6  |   7  |   8  |   9  |   0  |        |
 * |--------+------+------+------+------+-------------|           |------+------+------+------+------+------+--------|
 * | Tab    |   Q  |   W  |   E  |   R  |   T  |  [   |           |   ]  |   Y  |   U  |   I  |   O  |   P  |  \     |
 * |--------+------+------+------+------+------|      |           |      |------+------+------+------+------+--------|
 * | MO(1)  |   A  |   S  |   D  |   F* |   G  |------|           |------|   H  |   J* |   K  |   L  |   ;  |   '    |
 * |--------+------+------+------+------+------|  -   |           |  =   |------+------+------+------+------+--------|
 * | ESC(`) |   Z  |   X  |   C  |   V  |   B  |      |           |      |   N  |   M  |   ,  |   .  |   /  |        |
 * `--------+------+------+------+------+-------------'           `-------------+------+------+------+------+--------'
 *   |      |      |      |      |       |                                       |       |    |      |      |        |
 *   `-----------------------------------'                                       `-----------------------------------'
 *                                        ,-------------.       ,--------------.
 *                                        |      |      |       |      |       |
 *                                 ,------|------|------|       |------+--------+------.
 *                                 |      |      |      |       |      |        |      |
 *                                 | Space|      |------|       |------|        |Enter |
 *                                 |      |      | Alt  |       | Ctrl |        |      |
 *                                 `--------------------'       `----------------------'
 */
[BASE] = LAYOUT_ergodox_pretty(
  // left hand                                                        // right hand
  KC_GRV,   KC_1,     KC_2,   KC_3,     KC_4,   KC_5,   KC_NO,        KC_NO,    KC_6,   KC_7,   KC_8,     KC_9,     KC_0,     KC_NO,
  KC_TAB,   KC_Q,     KC_W,   KC_E,     KC_R,   KC_T,   KC_LBRC,      KC_RBRC,  KC_Y,   KC_U,   KC_I,     KC_O,     KC_P,     KC_BSLS,
  MO(1),    HOME_A,   HOME_S, HOME_D,   HOME_F, KC_G,                           KC_H,   HOME_J, HOME_K,   HOME_L,   HOME_SCLN,KC_QUOTE,
  KC_GESC,  KC_Z,     KC_X,   KC_C,     KC_V,   KC_B,   KC_MINS,      KC_EQL,   KC_N,   KC_M,   KC_COMM,  KC_DOT,   KC_SLASH, KC_NO,
  KC_NO,    KC_NO,    KC_NO,  KC_NO,    KC_NO,                                          KC_NO,  KC_NO,    KC_NO,    KC_NO,    KC_NO,

                                                KC_NO,    KC_NO,      KC_NO,   KC_NO,
                                                          KC_NO,      KC_NO,
                                      KC_SPC,   KC_NO,    KC_NO,      KC_NO,   KC_NO,  KC_ENT

),
/* Keymap 1: Symbol Layer
 *
 * ,---------------------------------------------------.           ,--------------------------------------------------.
 * | Ecsape  |  F1  |  F2  |  F3  |  F4  |  F5  |     |           |      |  F6  |  F7  |  F8  |  F9  |  F10 |   F11  |
 * |---------+------+------+------+------+------+------|           |------+------+------+------+------+------+--------|
 * |         | Vol+ | Mute | NTrk | Brt+ |      |      |           |      |      |      |      |      |PrtSc |   F12  |
 * |---------+------+------+------+------+------|      |           |      |------+------+------+------+------+--------|
 * |  TRANS  | Vol- | Play | PTrk | Brt- |      |------|           |------| Left | Down |  Up  | Right|      |        |
 * |---------+------+------+------+------+------|      |           |      |------+------+------+------+------+--------|
 * |         |      |      |      |      |      |      |           |      |      | PgDwn| PgUp |      |      |        |
 * `---------+------+------+------+------+-------------'           `-------------+------+------+------+------+--------'
 *   | Reset |      |      |      |      |                                       |      |      |      |      |      |
 *   `-----------------------------------'                                       `----------------------------------'
 *                                        ,-------------.       ,-------------.
 *                                        |      |      |       |      |      |
 *                                 ,------|------|------|       |------+------+------.
 *                                 |      |      |      |       |      |      |      |
 *                                 | BKSPC| Del  |------|       |------| Del  | BKSPC|
 *                                 |      |      |      |       |      |      |      |
 *                                 `--------------------'       `--------------------'
 */
[FUNC] = LAYOUT_ergodox_pretty(
  // left hand
  KC_ESC,    KC_F1,   KC_F2,   KC_F3,   KC_F4,   KC_F5,  KC_TRNS,    KC_TRNS, KC_F6,   KC_F7,   KC_F8,    KC_F9,    KC_F10,  KC_F11,
  KC_TRNS, KC_VOLU, KC_MUTE,   KC_MNXT, KC_BRIU, KC_TRNS, KC_TRNS,   KC_TRNS, KC_TRNS, KC_TRNS, KC_TRNS,  KC_TRNS,  KC_PSCR, KC_F12,
  KC_TRNS, KC_VOLD, KC_MPLY,  KC_MPRV, KC_BRID, KC_TRNS,                     KC_LEFT, KC_DOWN, KC_UP,    KC_RIGHT, KC_TRNS, KC_TRNS,
  KC_TRNS, KC_TRNS, KC_TRNS, KC_TRNS, KC_TRNS, KC_TRNS, KC_TRNS,     KC_TRNS, KC_TRNS, KC_PGDN, KC_PGUP,  KC_TRNS,  KC_TRNS, KC_TRNS,
  RESET,   KC_TRNS, KC_TRNS, KC_TRNS, KC_TRNS,                                         KC_TRNS, KC_TRNS,  KC_TRNS,  KC_TRNS, KC_TRNS,
                                               KC_TRNS, KC_TRNS,     KC_TRNS, KC_TRNS,
                                                        KC_TRNS,     KC_TRNS,
                                      KC_BSPC, KC_DEL,  KC_TRNS,     KC_TRNS, KC_DEL,  PASTE
),
};
