// fsr_adc.c

#include <stdbool.h>

#include "fsr_adc.h"
#include "fsr_config.h"

#include "nrf_drv_saadc.h"
#include "nrf_drv_ppi.h"
#include "nrf_drv_timer.h"
#include "nrf_drv_gpiote.h"
#include "nrf_delay.h"

#include "sdk_config.h"

//#define ADC_PRINT_HELP

#ifdef ADC_PRINT_HELP
    #include "nrf_log.h"
    #include "counter.h"
#endif

#define SAMPLES_IN_BUFFER NUM_FSR_SENSORS
#define SAADC_CALIBRATION_INTERVAL 100        //Determines how often the SAADC should be calibrated relative to NRF_DRV_SAADC_EVT_DONE event

#define PERIODIC_POWER

static const nrf_drv_timer_t    m_timer = NRF_DRV_TIMER_INSTANCE(1);
static nrf_saadc_value_t        m_buffer_pool[2][SAMPLES_IN_BUFFER]; // nrf_saadc_value_t is int16_t
static uint32_t                 m_adc_evt_counter = (SAADC_CALIBRATION_INTERVAL - 1);
static bool                     m_saadc_calibrate = false;
static bool                     m_done_sample = false;
static nrf_ppi_channel_t        m_ppi_channel_saadc_sample;
static uint32_t                 m_sample_period;
static int16_t                  m_adc_results_mvolt[SAMPLES_IN_BUFFER]; //Stores the mV values that will be notified
static fsr_adc_evt_handler_t    m_adc_callback;

// If using periodic power source, the timer event turns on power to the circuit
static void timer_handler_SAADC(nrf_timer_event_t event_type, void * p_context)
{

#ifdef PERIODIC_POWER
        if (event_type == NRF_TIMER_EVENT_COMPARE0)
        {
#ifdef ADC_PRINT_HELP
    NRF_LOG_INFO("Power On\r\n");
#endif
            nrf_drv_gpiote_out_set(POWER_PIN);
        }
#endif

}

//Sets both buffers up for sample conversion when the ADC is restarted
static void convert_buffers(void)
{
    ret_code_t err_code;
    err_code = nrf_drv_saadc_buffer_convert(m_buffer_pool[0], SAMPLES_IN_BUFFER);
    APP_ERROR_CHECK(err_code);
    err_code = nrf_drv_saadc_buffer_convert(m_buffer_pool[1], SAMPLES_IN_BUFFER);
    APP_ERROR_CHECK(err_code);
}

//Handler for SAADC events: full sample buffer or calibration complete
static void saadc_callback(nrf_drv_saadc_evt_t const * p_event)
{

#ifdef ADC_PRINT_HELP
    NRF_LOG_INFO("Callback Start\r\n");
#endif

    if ( (p_event->type == NRF_DRV_SAADC_EVT_DONE) && (p_event->data.done.p_buffer != NULL)) //Extra condition is to prevent the extra event generated from abort from notifying values from a NULL pointer
    {
//Turns off the power source since the sample has already been taken
#ifdef PERIODIC_POWER
        nrf_drv_gpiote_out_clear(POWER_PIN);
#endif

#ifdef ADC_PRINT_HELP
    NRF_LOG_INFO("Power Off\r\n");
#endif

        m_adc_evt_counter++;

#ifdef ADC_PRINT_HELP
    NRF_LOG_INFO("Sample %d\r\n", m_adc_evt_counter);
#endif

        for (uint8_t i = 0; i < SAMPLES_IN_BUFFER; i++)
        {
            float f_value = ((float)(p_event->data.done.p_buffer[i]))*0.825/(0.25*1024);
            m_adc_results_mvolt[i] = (int16_t)(f_value*1000);
             //1000 is the V to mV conversion
             //Formula according to spec: RESULT = (V(p)-V(n))*GAIN/Reference*2^(Resolution-Mode)
             // V(p) = (RESULT * Reference) / (GAIN*2^(Resolution-Mode))
             //Gain = 1/4
             //Reference = VDD/4 = 0.825 V
             //Resolution = 10 bits
             //Mode = 0 for single ended
        }

#ifdef ADC_PRINT_HELP
   NRF_LOG_INFO("mV Calculated\r\n");
#endif

        m_done_sample = true;

        if(m_adc_evt_counter == SAADC_CALIBRATION_INTERVAL) //Evaluate if offset calibration should be performed. Configure the SAADC_CALIBRATION_INTERVAL constant to change the calibration frequency
        {

#ifdef ADC_PRINT_HELP
    NRF_LOG_INFO("Abort Start\r\n");
#endif

            nrf_drv_saadc_abort(); //Abort all ongoing conversions. Calibration cannot be run if SAADC is busy

#ifdef ADC_PRINT_HELP
    NRF_LOG_INFO("Abort End\r\n");
#endif

            m_saadc_calibrate = true; //Set flag to trigger calibration in main context when SAADC is stopped
        }
        else
        {
            ret_code_t err_code;

#ifdef ADC_PRINT_HELP
    NRF_LOG_INFO("Convert Start\r\n");
#endif

            err_code = nrf_drv_saadc_buffer_convert(p_event->data.done.p_buffer, SAMPLES_IN_BUFFER); //Sets the ADC up for conversion

#ifdef ADC_PRINT_HELP
    NRF_LOG_INFO("Convert End\r\n");
#endif

            APP_ERROR_CHECK(err_code);
        }
    }

    else if (p_event->type == NRF_DRV_SAADC_EVT_CALIBRATEDONE) //For event when calibration is done, set up buffers for conversion
    {
        nrf_delay_us(5); //I think only a delay of a few clock cycles to clear the interrupt is ok. It is suggested to read the event register

#ifdef ADC_PRINT_HELP
    NRF_LOG_INFO("Calibrated Event\r\n");
#endif

        convert_buffers();
        m_adc_evt_counter = 0;
    }

#ifdef ADC_PRINT_HELP
    NRF_LOG_INFO("Callback End\r\n");
#endif

}

//Initialize the Timer, PPI, SAADC driver, SAADC channels and RAM buffers
void fsr_adc_init(fsr_adc_init_t * p_params)
{
    m_sample_period = p_params->sample_period_ms;
    m_adc_callback = p_params->evt_handler;

    ret_code_t err_code;
    err_code = nrf_drv_ppi_init();
    APP_ERROR_CHECK(err_code);

    nrf_drv_timer_config_t timer_cfg = NRF_DRV_TIMER_DEFAULT_CONFIG;
    timer_cfg.bit_width = NRF_TIMER_BIT_WIDTH_32; //Number of bits used before overflow
    err_code = nrf_drv_timer_init(&m_timer, &timer_cfg, timer_handler_SAADC);
    APP_ERROR_CHECK(err_code);

//Use a compare event that occurs just before a sample is taken to provide power to the circuit
#ifdef PERIODIC_POWER

    if(!nrf_drv_gpiote_is_init())
    {
        err_code = nrf_drv_gpiote_init();
    }

    nrf_drv_gpiote_out_config_t config = GPIOTE_CONFIG_OUT_SIMPLE(false);
    err_code = nrf_drv_gpiote_out_init(POWER_PIN, &config);
    APP_ERROR_CHECK(err_code);

    uint32_t ticks_power_pin = nrf_drv_timer_ms_to_ticks(&m_timer, (m_sample_period - POWER_PIN_PERIOD_DIFF));

    nrf_drv_timer_compare(&m_timer,
                          NRF_TIMER_CC_CHANNEL0, //Capture/compare channel/register
                          ticks_power_pin,//Value in the CC register
                          true); //Enable the timer interrupt
#endif

    uint32_t ticks_saadc_sample = nrf_drv_timer_ms_to_ticks(&m_timer, m_sample_period); //Number of ticks for the given sample period
    nrf_drv_timer_extended_compare(&m_timer,
                                   NRF_TIMER_CC_CHANNEL1, //Capture/compare channel/register
                                   ticks_saadc_sample,//Value in the CC register
                                   NRF_TIMER_SHORT_COMPARE1_CLEAR_MASK, //Shortcut that clears the counter register when there is a compare event
                                   false); //Don't enable the timer interrupt

    uint32_t timer_compare_event_addr_saadc_sample = nrf_drv_timer_compare_event_address_get(&m_timer,
                                                                                             NRF_TIMER_CC_CHANNEL1);
    uint32_t saadc_sample_task_addr                = nrf_drv_saadc_sample_task_get();

    /* setup ppi channel so that timer compare event is triggering sample task in SAADC */
    err_code = nrf_drv_ppi_channel_alloc(&m_ppi_channel_saadc_sample);
    APP_ERROR_CHECK(err_code);

    err_code = nrf_drv_ppi_channel_assign(m_ppi_channel_saadc_sample,
                                          timer_compare_event_addr_saadc_sample,
                                          saadc_sample_task_addr);
    APP_ERROR_CHECK(err_code);

    //Max voltage is 3.2 V over 10k resistor
    nrf_saadc_channel_config_t channel0_config =
    {
        .resistor_p = NRF_SAADC_RESISTOR_DISABLED,
        .resistor_n = NRF_SAADC_RESISTOR_DISABLED,
        .gain       = NRF_SAADC_GAIN1_4,            //NRF_SAADC_GAIN1_3 NRF_SAADC_GAIN1_4 NRF_SAADC_GAIN1_5
        .reference  = NRF_SAADC_REFERENCE_VDD4, //NRF_SAADC_REFERENCE_INTERNAL NRF_SAADC_REFERENCE_VDD4
        .acq_time   = NRF_SAADC_ACQTIME_10US,
        .mode       = NRF_SAADC_MODE_SINGLE_ENDED,
        .pin_p      = NRF_SAADC_INPUT_AIN5,
        .pin_n      = NRF_SAADC_INPUT_DISABLED
    };

    nrf_saadc_channel_config_t channel1_config = channel0_config;
    channel1_config.pin_p = NRF_SAADC_INPUT_AIN7;

    //From sdk_config.h, the default resolution is 10 bits which is 0-1023
    err_code = nrf_drv_saadc_init(NULL, saadc_callback); //NULL is default config structure
    APP_ERROR_CHECK(err_code);

    err_code = nrf_drv_saadc_channel_init(0, &channel0_config);
    APP_ERROR_CHECK(err_code);
    err_code = nrf_drv_saadc_channel_init(1, &channel1_config);
    APP_ERROR_CHECK(err_code);

    convert_buffers();
}

//Start sampling when enabled via CCCD
void fsr_adc_sample_begin(void)
{
    ret_code_t err_code;
    nrf_drv_timer_enable(&m_timer);
    err_code = nrf_drv_ppi_channel_enable(m_ppi_channel_saadc_sample);
    APP_ERROR_CHECK(err_code);
}

//Stop sampling when disabled via CCCD
void fsr_adc_sample_end(void)
{
    ret_code_t err_code;
    nrf_drv_timer_disable(&m_timer);
    err_code = nrf_drv_ppi_channel_disable(m_ppi_channel_saadc_sample);
    APP_ERROR_CHECK(err_code);

//Turn off power when the sampling ends
#ifdef PERIODIC_POWER
    nrf_drv_gpiote_out_clear(POWER_PIN);
#endif

}

//When flag set to true, notify the new adc result. Function is called from main() loop
void check_saadc_done_sample(void)
{
    if (m_done_sample == true)
    {

#ifdef ADC_PRINT_HELP
    NRF_LOG_INFO("Notify Start\r\n");
#endif

        m_adc_callback(m_adc_results_mvolt);

#ifdef ADC_PRINT_HELP
    NRF_LOG_INFO("Notify Done\r\n");
#endif

        m_done_sample = false;
    }
}

//When flag set to true, perform a calibration. Function is called from main() loop
void check_saadc_calibration(void)
{
    if (m_saadc_calibrate == true)
    {

#ifdef ADC_PRINT_HELP
    NRF_LOG_INFO("Calibrate Start\r\n");
#endif

        while(nrf_drv_saadc_calibrate_offset() != NRF_SUCCESS); //Trigger calibration task

 #ifdef ADC_PRINT_HELP
     NRF_LOG_INFO("Calibrate Done\r\n");
 #endif
        m_saadc_calibrate = false;

    }
}
