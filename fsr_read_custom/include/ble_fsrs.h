/*Force Sensitive Resistor Service*/

#ifndef BLE_FSRS_H__
#define BLE_FSRS_H__

#include <stdint.h>
#include <stdbool.h>
#include "ble.h"
#include "ble_srv_common.h"
#include "fsr_data_types.h"

//Base UUID 6c1bxxxx-4e01-8b6f-9a30-4ab6f2d2937c
#define FSRS_UUID_BASE                       {0x7C, 0x93, 0xD2, 0xF2, 0xB6, 0x4A, 0x30, 0x9A, \
                                             0x6F, 0x8B, 0x01, 0x4E, 0x00, 0x00, 0x1B, 0x6C}
#define FSRS_UUID_SERVICE                    (0x0001)
#define FSRS_UUID_DATA_CHAR                  (0x0002)


//Forward declaration of the service type ble_fsrs_t
typedef struct ble_fsrs_s ble_fsrs_t;

typedef void (*ble_fsrs_data_subscr_handler_t) (ble_fsrs_t * p_fsrs, bool is_data_subscr);

typedef struct
{
    ble_fsrs_data_subscr_handler_t      data_subscr_handler;
    fsr_data_t *                        p_fsr_data_init;
} ble_fsrs_init_t;

struct ble_fsrs_s
{
    uint16_t                            service_handle;
    ble_gatts_char_handles_t            data_char_handles;
    uint8_t                             uuid_type;
    uint16_t                            conn_handle;
    ble_fsrs_data_subscr_handler_t      data_subscr_handler;
};

uint32_t ble_fsrs_init(ble_fsrs_t * p_fsrs, const ble_fsrs_init_t * p_fsrs_init);

void ble_fsrs_on_ble_evt(ble_fsrs_t * p_fsrs, ble_evt_t * p_ble_evt);

uint32_t ble_fsrs_data_notify(ble_fsrs_t * p_fsrs, fsr_data_t * p_fsr_data);

#endif //BLE_FSRS_H__
