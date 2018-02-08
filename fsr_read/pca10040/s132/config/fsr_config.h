#ifndef FSR_CONFIG_H__
#define FSR_CONFIG_H__

#define NUM_FSR_SENSORS (2)

#define ADC_SAMPLE_PERIOD_MS (10)
// 10 ms is 100 Hz
// 25 ms is 40 Hz
// 50 ms is 20 Hz
// 100 ms is 10 Hz
// 250 ms is 4 Hz
// 1000 ms is 1 Hz

#define POWER_PIN (11)

#define POWER_PIN_PERIOD_DIFF (1) //Number of ms power is turned on before sampling

#endif
