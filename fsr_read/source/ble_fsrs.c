// ble_fsrs.c

#include "ble_fsrs.h"

#include "sdk_config.h"
#include "sdk_common.h"
#include "ble_srv_common.h"

/**@brief Function for handling the @ref BLE_GAP_EVT_CONNECTED event from the S110 SoftDevice.
 *
 * @param[in] p_fsrs     FSR Service structure.
 * @param[in] p_ble_evt Pointer to the event received from BLE stack.
 */
static void on_connect(ble_fsrs_t * p_fsrs, ble_evt_t * p_ble_evt)
{
    p_fsrs->conn_handle = p_ble_evt->evt.gap_evt.conn_handle;
}


/**@brief Function for handling the @ref BLE_GAP_EVT_DISCONNECTED event from the S110 SoftDevice.
 *
 * @param[in] p_fsrs     Nordic UART Service structure.
 * @param[in] p_ble_evt Pointer to the event received from BLE stack.
 */
static void on_disconnect(ble_fsrs_t * p_fsrs, ble_evt_t * p_ble_evt)
{
    UNUSED_PARAMETER(p_ble_evt);
    p_fsrs->conn_handle = BLE_CONN_HANDLE_INVALID;
}


/**@brief Function for handling the @ref BLE_GATTS_EVT_WRITE event from the S110 SoftDevice.
 *
 * @param[in] p_fsrs     FSR Service structure.
 * @param[in] p_ble_evt Pointer to the event received from BLE stack.
 */
static void on_write(ble_fsrs_t * p_fsrs, ble_evt_t * p_ble_evt)
{
    ble_gatts_evt_write_t * p_evt_write = &p_ble_evt->evt.gatts_evt.params.write;

    if (
        (p_evt_write->handle == p_fsrs->data_char_handles.cccd_handle) &&
        (p_evt_write->len == 2) &&
        (p_fsrs->data_subscr_handler != NULL)
       )
    {
        p_fsrs->data_subscr_handler(p_fsrs, *(p_evt_write->data));
    }
}


/**@brief Function for adding fsr data characteristic.
 *
 * @param[in] p_fsrs       FSR Service structure.
 * @param[in] p_fsrs_init  Information needed to initialize the service.
 *
 * @return NRF_SUCCESS on success, otherwise an error code.
 */
static uint32_t data_char_add(ble_fsrs_t * p_fsrs, const ble_fsrs_init_t * p_fsrs_init)
{
    ble_gatts_char_md_t char_md;
    ble_gatts_attr_md_t cccd_md;
    ble_gatts_attr_t    attr_char_value;
    ble_uuid_t          ble_uuid;
    ble_gatts_attr_md_t attr_md;

    memset(&cccd_md, 0, sizeof(cccd_md));

    BLE_GAP_CONN_SEC_MODE_SET_OPEN(&cccd_md.read_perm);
    BLE_GAP_CONN_SEC_MODE_SET_OPEN(&cccd_md.write_perm);
    cccd_md.vloc = BLE_GATTS_VLOC_STACK;

    memset(&char_md, 0, sizeof(char_md));

    char_md.char_props.read   = 1;
    char_md.char_props.write  = 0;
    char_md.char_props.notify = 1;
    char_md.p_char_user_desc  = NULL;
    char_md.p_char_pf         = NULL;
    char_md.p_user_desc_md    = NULL;
    char_md.p_cccd_md         = &cccd_md;
    char_md.p_sccd_md         = NULL;

    ble_uuid.type = p_fsrs->uuid_type;
    ble_uuid.uuid = FSRS_UUID_DATA_CHAR;

    memset(&attr_md, 0, sizeof(attr_md));

    BLE_GAP_CONN_SEC_MODE_SET_OPEN(&attr_md.read_perm);
    BLE_GAP_CONN_SEC_MODE_SET_OPEN(&attr_md.write_perm);

    attr_md.vloc    = BLE_GATTS_VLOC_STACK;
    attr_md.rd_auth = 0;
    attr_md.wr_auth = 0;
    attr_md.vlen    = 0;

    memset(&attr_char_value, 0, sizeof(attr_char_value));

    attr_char_value.p_uuid    = &ble_uuid;
    attr_char_value.p_attr_md = &attr_md;
    attr_char_value.init_len  = (p_fsrs_init->p_fsr_data_init->fsr_data_array_size)*(sizeof(int16_t));
    attr_char_value.init_offs = 0;
    attr_char_value.max_len   = (p_fsrs_init->p_fsr_data_init->fsr_data_array_size)*(sizeof(int16_t));
    attr_char_value.p_value   = (uint8_t*)(p_fsrs_init->p_fsr_data_init->p_fsr_data_array);

    return sd_ble_gatts_characteristic_add(p_fsrs->service_handle,
                                           &char_md,
                                           &attr_char_value,
                                           &p_fsrs->data_char_handles);
}


void ble_fsrs_on_ble_evt(ble_fsrs_t * p_fsrs, ble_evt_t * p_ble_evt)
{
    if ((p_fsrs == NULL) || (p_ble_evt == NULL))
    {
        return;
    }

    switch (p_ble_evt->header.evt_id)
    {
        case BLE_GAP_EVT_CONNECTED:
            on_connect(p_fsrs, p_ble_evt);
            break;

        case BLE_GAP_EVT_DISCONNECTED:
            on_disconnect(p_fsrs, p_ble_evt);
            break;

        case BLE_GATTS_EVT_WRITE:
            on_write(p_fsrs, p_ble_evt);
            break;

        default:
            // No implementation needed.
            break;
    }
}


uint32_t ble_fsrs_init(ble_fsrs_t * p_fsrs, const ble_fsrs_init_t * p_fsrs_init)
{
    uint32_t      err_code;
    ble_uuid_t    ble_uuid;
    ble_uuid128_t base_uuid = {FSRS_UUID_BASE};

    VERIFY_PARAM_NOT_NULL(p_fsrs);
    VERIFY_PARAM_NOT_NULL(p_fsrs_init);

    // Initialize the service structure.
    p_fsrs->conn_handle             = BLE_CONN_HANDLE_INVALID;
    p_fsrs->data_subscr_handler     = p_fsrs_init->data_subscr_handler;

    // Add a custom base UUID.
    err_code = sd_ble_uuid_vs_add(&base_uuid, &p_fsrs->uuid_type);
    VERIFY_SUCCESS(err_code);

    ble_uuid.type = p_fsrs->uuid_type;
    ble_uuid.uuid = FSRS_UUID_SERVICE;

    // Add the service.
    err_code = sd_ble_gatts_service_add(BLE_GATTS_SRVC_TYPE_PRIMARY,
                                        &ble_uuid,
                                        &p_fsrs->service_handle);
    VERIFY_SUCCESS(err_code);

    // Add Characteristic.
    err_code = data_char_add(p_fsrs, p_fsrs_init);
    VERIFY_SUCCESS(err_code);

    return NRF_SUCCESS;
}


uint32_t ble_fsrs_data_notify(ble_fsrs_t * p_fsrs, fsr_data_t * p_fsr_data)
{
    ble_gatts_hvx_params_t hvx_params;
    uint16_t               length = (p_fsr_data->fsr_data_array_size)*(sizeof(int16_t));

    memset(&hvx_params, 0, sizeof(hvx_params));

    hvx_params.handle = p_fsrs->data_char_handles.value_handle;
    hvx_params.p_data = (uint8_t *)(p_fsr_data->p_fsr_data_array);
    hvx_params.p_len  = &length;
    hvx_params.type   = BLE_GATT_HVX_NOTIFICATION;

    return sd_ble_gatts_hvx(p_fsrs->conn_handle, &hvx_params);
}
