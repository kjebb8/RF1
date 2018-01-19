/**
 * Copyright (c) 2014 - 2017, Nordic Semiconductor ASA
 *
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without modification,
 * are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright notice, this
 *    list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form, except as embedded into a Nordic
 *    Semiconductor ASA integrated circuit in a product or a software update for
 *    such product, must reproduce the above copyright notice, this list of
 *    conditions and the following disclaimer in the documentation and/or other
 *    materials provided with the distribution.
 *
 * 3. Neither the name of Nordic Semiconductor ASA nor the names of its
 *    contributors may be used to endorse or promote products derived from this
 *    software without specific prior written permission.
 *
 * 4. This software, with or without modification, must only be used with a
 *    Nordic Semiconductor ASA integrated circuit.
 *
 * 5. Any software provided in binary form under this license must not be reverse
 *    engineered, decompiled, modified and/or disassembled.
 *
 * THIS SOFTWARE IS PROVIDED BY NORDIC SEMICONDUCTOR ASA "AS IS" AND ANY EXPRESS
 * OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
 * OF MERCHANTABILITY, NONINFRINGEMENT, AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL NORDIC SEMICONDUCTOR ASA OR CONTRIBUTORS BE
 * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE
 * GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT
 * OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 */

/** @file
 * @defgroup nrf_adc_example main.c
 * @{
 * @ingroup nrf_adc_example
 * @brief ADC Example Application main file.
 *
 * This file contains the source code for a sample application using ADC.
 *
 * @image html example_board_setup_a.jpg "Use board setup A for this example."
 */

 #include <stdbool.h>
 #include <stdint.h>
 #include <stdio.h>
 #include <string.h>
 #include "nrf.h"
 #include "nrf_drv_saadc.h"
 #include "nrf_drv_ppi.h"
 #include "nrf_drv_timer.h"
 #include "boards.h"
 #include "app_error.h"
 #include "nrf_delay.h"
 #include "app_util_platform.h"
 #include "nrf_pwr_mgmt.h"
 #include "nrf_drv_power.h"
 #include "nrf_drv_gpiote.h"
 #include "app_scheduler.h"
 #include "nordic_common.h"

#define NRF_LOG_MODULE_NAME "APP" //Log Name
#include "nrf_log.h"
#include "nrf_log_ctrl.h"

#define SAMPLES_IN_BUFFER 3

//Not sure what this was for in original SAADC
//volatile uint8_t state = 1;

static const nrf_drv_timer_t m_timer = NRF_DRV_TIMER_INSTANCE(0); //Macro creates an instance of a timer driver with ID 0
static nrf_saadc_value_t     m_buffer_pool[2][SAMPLES_IN_BUFFER]; // typedef int16_t nrf_saadc_value_t, Setting up 2 sample buffers
static nrf_saadc_value_t *   m_buffer_address_copy = NULL; //Copy of pointer to the filled data buffer
static nrf_ppi_channel_t     m_ppi_channel; //Enum for different PPI channels
static int16_t               m_adc_results_mvolt[SAMPLES_IN_BUFFER]; //ADC results converted to mV

// Pins for LED's and buttons.
// The diodes on the DK are connected with the cathodes to the GPIO pin, so
// clearing a pin will light the LED and setting the pin will turn of the LED.
#define LED_1_PIN                       BSP_LED_0     // LED 1 on the nRF51-DK or nRF52-DK
#define LED_2_PIN                       BSP_LED_1     // LED 3 on the nRF51-DK or nRF52-DK

//Scheduler settings
#define SCHED_MAX_EVENT_DATA_SIZE       sizeof(m_buffer_address_copy)
#define SCHED_QUEUE_SIZE                5

// Function for configuring GPIO.
static void gpio_config()
{
    ret_code_t err_code;

    // Initialze driver.
    err_code = nrf_drv_gpiote_init();
    APP_ERROR_CHECK(err_code);

    // Configure 2 output pins for LED's.
    nrf_drv_gpiote_out_config_t out_config = GPIOTE_CONFIG_OUT_SIMPLE(false);
    err_code = nrf_drv_gpiote_out_init(LED_1_PIN, &out_config);
    APP_ERROR_CHECK(err_code);
    err_code = nrf_drv_gpiote_out_init(LED_2_PIN, &out_config);
    APP_ERROR_CHECK(err_code);

    // // Set output pins (this will turn off the LED's).
    nrf_drv_gpiote_out_set(LED_1_PIN);
    nrf_drv_gpiote_out_set(LED_2_PIN);
}


//----------------------------------------------------------------------------------------
//Start of SAADC Example

void timer_handler_SAADC(nrf_timer_event_t event_type, void * p_context)
{
    //Nothing needed
}


void saadc_sampling_event_init(void)
{
    ret_code_t err_code;

    err_code = nrf_drv_ppi_init(); //General programmable peripheral interconnect initialization
    APP_ERROR_CHECK(err_code);

    nrf_drv_timer_config_t timer_cfg = NRF_DRV_TIMER_DEFAULT_CONFIG; //A default timer struct, Parameters defined in sdk_config.h
    timer_cfg.bit_width = NRF_TIMER_BIT_WIDTH_32; //Number of bits used before overflow
    err_code = nrf_drv_timer_init(&m_timer, &timer_cfg, timer_handler_SAADC); //Initialize timer
    APP_ERROR_CHECK(err_code);

    /* setup m_timer for compare event every 400ms */
    uint32_t ticks = nrf_drv_timer_ms_to_ticks(&m_timer, 1000); //Number of ticks for 400ms
    nrf_drv_timer_extended_compare(&m_timer,//Timer instance
                                   NRF_TIMER_CC_CHANNEL0, //Capture/compare channel/register 0
                                   ticks,//Value in the CC register
                                   NRF_TIMER_SHORT_COMPARE0_CLEAR_MASK, //Shortcut that clears the counter register when there is a compare event
                                   false); //Don't enable the timer interrupt
    nrf_drv_timer_enable(&m_timer); //Turn on timer

    uint32_t timer_compare_event_addr = nrf_drv_timer_compare_event_address_get(&m_timer,
                                                                                NRF_TIMER_CC_CHANNEL0); //Returns address of timer compare event end point
    uint32_t saadc_sample_task_addr   = nrf_drv_saadc_sample_task_get(); //Get sampling task endpoint address

    /* setup ppi channel so that timer compare event is triggering sample task in SAADC */
    err_code = nrf_drv_ppi_channel_alloc(&m_ppi_channel); //Allocates a PPI channel
    APP_ERROR_CHECK(err_code);

    //Event on timer translates to task on ADC through the configured PPI
    err_code = nrf_drv_ppi_channel_assign(m_ppi_channel, //Assign task and event to PPI
                                          timer_compare_event_addr, //Event is the compare (400ms)
                                          saadc_sample_task_addr); //Task is the sampling of ADC
    APP_ERROR_CHECK(err_code);
}

void saadc_sampling_event_enable(void)
{
    ret_code_t err_code = nrf_drv_ppi_channel_enable(m_ppi_channel); //Enable the PPI

    APP_ERROR_CHECK(err_code);
}

// The executable event from the scheduler to read and reset the ADC result buffer
void saadc_scheduler_event_handler(void * p_data, uint16_t data_size)
{
    NRF_LOG_RAW_INFO("Handler: 0x%08x\r\n", (uint32_t) *((nrf_saadc_value_t **)p_data));

    ret_code_t err_code;

    err_code = nrf_drv_saadc_buffer_convert(*((nrf_saadc_value_t **)p_data),SAMPLES_IN_BUFFER); //Sets the ADC up for conversion
    APP_ERROR_CHECK(err_code);

    for (uint8_t i = 0; i < SAMPLES_IN_BUFFER; i++)
    {
        m_adc_results_mvolt[i] = (*((nrf_saadc_value_t **)p_data))[i];
    }
    //for (i = 0; i < SAMPLES_IN_BUFFER; i++)
    //{
       NRF_LOG_RAW_INFO("%d %d\r\n", (*((nrf_saadc_value_t **)p_data))[0], (*((nrf_saadc_value_t **)p_data))[1]); // Log the samples in the full buffer
      //NRF_LOG_RAW_HEXDUMP_INFO(p_event->data.done.p_buffer, SAMPLES_IN_BUFFER);
    //}
}

//Once a sample buffer is full, it puts an event in the scheduler
void saadc_callback(nrf_drv_saadc_evt_t const * p_event)
{
    if (p_event->type == NRF_DRV_SAADC_EVT_DONE) //Event when buffer is full of samples
    {
        NRF_LOG_RAW_INFO("Interrupt: 0x%08x\r\n", (uint32_t) (p_event->data.done.p_buffer));
        memcpy(&m_buffer_address_copy, &(p_event->data.done.p_buffer), sizeof(p_event->data.done.p_buffer));
        NRF_LOG_RAW_INFO("Copy: 0x%08x\r\n", (uint32_t) (m_buffer_address_copy));
        NRF_LOG_RAW_INFO("Size Copy: %d\r\n", sizeof(m_buffer_address_copy));

        // Schedule event that handles the new results data in the full buffer
        app_sched_event_put(&m_buffer_address_copy, sizeof(m_buffer_address_copy), saadc_scheduler_event_handler);
        NRF_LOG_INFO("After sched\r\n\n");
    }
}


void saadc_init(void)
{
    ret_code_t err_code;
    nrf_saadc_channel_config_t channel_config =
        NRF_DRV_SAADC_DEFAULT_CHANNEL_CONFIG_SE(NRF_SAADC_INPUT_AIN0); //Default config on AIN0

    err_code = nrf_drv_saadc_init(NULL, saadc_callback); //NULL is default config structure and callback for the event handler
    APP_ERROR_CHECK(err_code);

    err_code = nrf_drv_saadc_channel_init(0, &channel_config); //Initialize channel to given configuration
    APP_ERROR_CHECK(err_code);

    err_code = nrf_drv_saadc_buffer_convert(m_buffer_pool[0], SAMPLES_IN_BUFFER); //Set up buffer 1 for conversion
    APP_ERROR_CHECK(err_code);

    err_code = nrf_drv_saadc_buffer_convert(m_buffer_pool[1], SAMPLES_IN_BUFFER); //Set up buffer 1 for conversion
    APP_ERROR_CHECK(err_code);

    NRF_LOG_RAW_INFO("m_buffer_poolAddress: 0x%08x\r\n", (uint32_t) m_buffer_pool[0]);
    NRF_LOG_RAW_INFO("m_buffer_poolAddress: 0x%08x\r\n", (uint32_t) m_buffer_pool[1]);
}


/**
 * @brief Function for main application entry.
 */
int main(void)
{
    // Configure GPIO's.
    gpio_config();

    APP_SCHED_INIT(SCHED_MAX_EVENT_DATA_SIZE, SCHED_QUEUE_SIZE);

    uint32_t err_code = NRF_LOG_INIT(NULL);
    APP_ERROR_CHECK(err_code);

    err_code = nrf_drv_power_init(NULL);
    APP_ERROR_CHECK(err_code);

    ret_code_t ret_code = nrf_pwr_mgmt_init(0);
    APP_ERROR_CHECK(ret_code);

    NRF_LOG_INFO("SAADC HAL simple example.\r\n");
    saadc_init();
    saadc_sampling_event_init();
    saadc_sampling_event_enable();

    while (1)
    {
        NRF_LOG_INFO("Before Execute\r\n");
        app_sched_execute();
        NRF_LOG_INFO("After Execute.\r\n");
        __WFI();
        //nrf_pwr_mgmt_run();
        NRF_LOG_FLUSH();
    }
}


/** @} */
