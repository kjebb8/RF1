#ifndef FSR_DATA_TYPES_H__
#define FSR_DATA_TYPES_H__

#include <stdint.h>

typedef struct
{
    int16_t *   p_fsr_data_array;
    uint16_t    fsr_data_array_size;
} fsr_data_t;

#endif //FSR_DATA_TYPES_H__
