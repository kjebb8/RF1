// fsr_adc.c

#include "fsr_adc.h"
#include "fsr_config.h"

#include "nrf_drv_saadc.h"
#include "nrf_drv_ppi.h"
#include "nrf_drv_timer.h"

#include "sdk_config.h"

#define SAMPLES_IN_BUFFER NUM_FSR_SENSORS

//Not sure what this was for in original SAADC
volatile uint8_t state = 1;

static const nrf_drv_timer_t    m_timer = NRF_DRV_TIMER_INSTANCE(1); //Macro creates an instance of a timer driver with ID 1
static nrf_saadc_value_t        m_buffer_pool[2][SAMPLES_IN_BUFFER]; // typedef int16_t nrf_saadc_value_t, Setting up 2 sample buffers
static nrf_ppi_channel_t        m_ppi_channel; //Enum for different PPI channels
static uint32_t                 m_sample_period; //ADC sample period
static int16_t                  m_adc_results_mvolt[SAMPLES_IN_BUFFER]; //ADC results converted to mV
static fsr_adc_evt_handler_t    m_adc_callback;


static void timer_handler_SAADC(nrf_timer_event_t event_type, void * p_context)
{
    //Nothing needed
}

//Once a sample buffer is full, it puts an event in the scheduler
static void saadc_callback(nrf_drv_saadc_evt_t const * p_event)
{
    if (p_event->type == NRF_DRV_SAADC_EVT_DONE) //Event when buffer is full of samples
    {
        ret_code_t err_code;

        err_code = nrf_drv_saadc_buffer_convert(p_event->data.done.p_buffer, SAMPLES_IN_BUFFER); //Sets the ADC up for conversion
        APP_ERROR_CHECK(err_code);

        for (uint8_t i = 0; i < SAMPLES_IN_BUFFER; i++)
        {
            float f_value = ((float)(p_event->data.done.p_buffer[i]))*0.825/(0.5*1024);
            m_adc_results_mvolt[i] = (int16_t)(f_value*1000);
             //1000 is the V to mV conversion
             //Formula according to spec: RESULT = (V(p)-V(n))*GAIN/Reference*2^(Resolution-Mode)
             // V(p) = (RESULT * Reference) / (GAIN*2^(Resolution-Mode))
             //Gain = 1/2
             //Reference = VDD/4 = 0.825
             //Resolution = 10 bits
             //Mode = 0 for single ended
        }
        m_adc_callback(m_adc_results_mvolt);
    }
}

void fsr_adc_init(fsr_adc_init_t * p_params)
{
    m_sample_period = p_params->sample_period_ms;
    m_adc_callback = p_params->evt_handler;

    ret_code_t err_code;
    err_code = nrf_drv_ppi_init(); //General programmable peripheral interconnect initialization
    APP_ERROR_CHECK(err_code);

    nrf_drv_timer_config_t timer_cfg = NRF_DRV_TIMER_DEFAULT_CONFIG; //A default timer struct, Parameters defined in sdk_config.h
    timer_cfg.bit_width = NRF_TIMER_BIT_WIDTH_32; //Number of bits used before overflow
    err_code = nrf_drv_timer_init(&m_timer, &timer_cfg, timer_handler_SAADC); //Initialize timer
    APP_ERROR_CHECK(err_code);

    /* setup m_timer for compare event every 400ms */
    uint32_t ticks = nrf_drv_timer_ms_to_ticks(&m_timer, m_sample_period); //Number of ticks for 400ms
    nrf_drv_timer_extended_compare(&m_timer,//Timer instance
                                   NRF_TIMER_CC_CHANNEL1, //Capture/compare channel/register 0
                                   ticks,//Value in the CC register
                                   NRF_TIMER_SHORT_COMPARE1_CLEAR_MASK, //Shortcut that clears the counter register when there is a compare event
                                   false); //Don't enable the timer interrupt
    nrf_drv_timer_enable(&m_timer); //Turn on timer

    uint32_t timer_compare_event_addr = nrf_drv_timer_compare_event_address_get(&m_timer,
                                                                                NRF_TIMER_CC_CHANNEL1); //Returns address of timer compare event end point
    uint32_t saadc_sample_task_addr   = nrf_drv_saadc_sample_task_get(); //Get sampling task endpoint address

    /* setup ppi channel so that timer compare event is triggering sample task in SAADC */
    err_code = nrf_drv_ppi_channel_alloc(&m_ppi_channel); //Allocates a PPI channel
    APP_ERROR_CHECK(err_code);

    //Event on timer translates to task on ADC through the configured PPI
    err_code = nrf_drv_ppi_channel_assign(m_ppi_channel, //Assign task and event to PPI
                                          timer_compare_event_addr, //Event is the compare (400ms)
                                          saadc_sample_task_addr); //Task is the sampling of ADC
    APP_ERROR_CHECK(err_code);

    nrf_saadc_channel_config_t channel0_config =
    {
        .resistor_p = NRF_SAADC_RESISTOR_DISABLED,
        .resistor_n = NRF_SAADC_RESISTOR_DISABLED,
        .gain       = NRF_SAADC_GAIN1_2,
        .reference  = NRF_SAADC_REFERENCE_VDD4,
        .acq_time   = NRF_SAADC_ACQTIME_10US,
        .mode       = NRF_SAADC_MODE_SINGLE_ENDED,
        .pin_p      = NRF_SAADC_INPUT_AIN0,
        .pin_n      = NRF_SAADC_INPUT_DISABLED
    };

    nrf_saadc_channel_config_t channel1_config = channel0_config;
    channel1_config.pin_p = NRF_SAADC_INPUT_AIN1;

    err_code = nrf_drv_saadc_init(NULL, saadc_callback); //NULL is default config structure and callback for the event handler
    APP_ERROR_CHECK(err_code);

    err_code = nrf_drv_saadc_channel_init(0, &channel0_config); //Initialize channel to given configuration
    APP_ERROR_CHECK(err_code);
    err_code = nrf_drv_saadc_channel_init(1, &channel1_config); //Initialize channel to given configuration
    APP_ERROR_CHECK(err_code);

    err_code = nrf_drv_saadc_buffer_convert(m_buffer_pool[0], SAMPLES_IN_BUFFER); //Set up buffer 1 for conversion
    APP_ERROR_CHECK(err_code);

    err_code = nrf_drv_saadc_buffer_convert(m_buffer_pool[1], SAMPLES_IN_BUFFER); //Set up buffer 1 for conversion
    APP_ERROR_CHECK(err_code);
}

uint32_t fsr_adc_sample_begin(void)
{
    nrf_drv_timer_enable(&m_timer);
    return nrf_drv_ppi_channel_enable(m_ppi_channel); //Enable the PPI
}

uint32_t fsr_adc_sample_end(void)
{
    nrf_drv_timer_disable(&m_timer);
    return nrf_drv_ppi_channel_disable(m_ppi_channel);
}
