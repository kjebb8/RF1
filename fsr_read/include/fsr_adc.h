#ifndef FSR_ADC_H__
#define FSR_ADC_H__


#include <stdint.h>

typedef void (*fsr_adc_evt_handler_t) (int16_t * p_voltage_results); //Calculated in mV

typedef struct
{
    uint32_t sample_period_ms;
    fsr_adc_evt_handler_t evt_handler;
}fsr_adc_init_t;

void fsr_adc_init(fsr_adc_init_t * p_adc_init);

uint32_t fsr_adc_sample_begin(void);

uint32_t fsr_adc_sample_end(void);

void check_saadc_notify();

void check_saadc_calibration();

#endif //FSR_ADC_H__
