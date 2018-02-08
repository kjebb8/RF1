

#ifndef SDK_CONFIG_H
#define SDK_CONFIG_H
// <<< Use Configuration Wizard in Context Menu >>>\n
#ifdef USE_APP_CONFIG
#include "app_config.h"
#endif

// <h> nRF_BLE

//==========================================================
// <q> BLE_ADVERTISING_ENABLED  - ble_advertising - Advertising module


#ifndef BLE_ADVERTISING_ENABLED
#define BLE_ADVERTISING_ENABLED 1
#endif

// <q> BLE_DTM_ENABLED  - ble_dtm - Module for testing RF/PHY using DTM commands


#ifndef BLE_DTM_ENABLED
#define BLE_DTM_ENABLED 0
#endif

// <q> BLE_RACP_ENABLED  - ble_racp - Record Access Control Point library


#ifndef BLE_RACP_ENABLED
#define BLE_RACP_ENABLED 0
#endif

// <q> NRF_BLE_QWR_ENABLED  - nrf_ble_qwr - Queued writes support module (prepare/execute write)


#ifndef NRF_BLE_QWR_ENABLED
#define NRF_BLE_QWR_ENABLED 0
#endif

// <q> PEER_MANAGER_ENABLED  - peer_manager - Peer Manager


#ifndef PEER_MANAGER_ENABLED
#define PEER_MANAGER_ENABLED 0
#endif

// </h>
//==========================================================

// <h> nRF_BLE_Services

//==========================================================
// <q> BLE_ANCS_C_ENABLED  - ble_ancs_c - Apple Notification Service Client


#ifndef BLE_ANCS_C_ENABLED
#define BLE_ANCS_C_ENABLED 0
#endif

// <q> BLE_ANS_C_ENABLED  - ble_ans_c - Alert Notification Service Client


#ifndef BLE_ANS_C_ENABLED
#define BLE_ANS_C_ENABLED 0
#endif

// <q> BLE_BAS_C_ENABLED  - ble_bas_c - Battery Service Client


#ifndef BLE_BAS_C_ENABLED
#define BLE_BAS_C_ENABLED 0
#endif

// <q> BLE_BAS_ENABLED  - ble_bas - Battery Service


#ifndef BLE_BAS_ENABLED
#define BLE_BAS_ENABLED 0
#endif

// <q> BLE_CSCS_ENABLED  - ble_cscs - Cycling Speed and Cadence Service


#ifndef BLE_CSCS_ENABLED
#define BLE_CSCS_ENABLED 0
#endif

// <q> BLE_CTS_C_ENABLED  - ble_cts_c - Current Time Service Client


#ifndef BLE_CTS_C_ENABLED
#define BLE_CTS_C_ENABLED 0
#endif

// <q> BLE_DIS_ENABLED  - ble_dis - Device Information Service


#ifndef BLE_DIS_ENABLED
#define BLE_DIS_ENABLED 0
#endif

// <q> BLE_GLS_ENABLED  - ble_gls - Glucose Service


#ifndef BLE_GLS_ENABLED
#define BLE_GLS_ENABLED 0
#endif

// <q> BLE_HIDS_ENABLED  - ble_hids - Human Interface Device Service


#ifndef BLE_HIDS_ENABLED
#define BLE_HIDS_ENABLED 0
#endif

// <e> BLE_HRS_C_ENABLED - ble_hrs_c - Heart Rate Service Client
//==========================================================
#ifndef BLE_HRS_C_ENABLED
#define BLE_HRS_C_ENABLED 0
#endif
#if  BLE_HRS_C_ENABLED
// <o> BLE_HRS_C_RR_INTERVALS_MAX_CNT - Maximum number of RR_INTERVALS per notification to be decoded
#ifndef BLE_HRS_C_RR_INTERVALS_MAX_CNT
#define BLE_HRS_C_RR_INTERVALS_MAX_CNT 30
#endif

#endif //BLE_HRS_C_ENABLED
// </e>

// <q> BLE_HRS_ENABLED  - ble_hrs - Heart Rate Service


#ifndef BLE_HRS_ENABLED
#define BLE_HRS_ENABLED 0
#endif

// <q> BLE_HTS_ENABLED  - ble_hts - Health Thermometer Service


#ifndef BLE_HTS_ENABLED
#define BLE_HTS_ENABLED 0
#endif

// <q> BLE_IAS_C_ENABLED  - ble_ias_c - Immediate Alert Service Client


#ifndef BLE_IAS_C_ENABLED
#define BLE_IAS_C_ENABLED 0
#endif

// <q> BLE_IAS_ENABLED  - ble_ias - Immediate Alert Service


#ifndef BLE_IAS_ENABLED
#define BLE_IAS_ENABLED 0
#endif

// <q> BLE_LBS_C_ENABLED  - ble_lbs_c - Nordic LED Button Service Client


#ifndef BLE_LBS_C_ENABLED
#define BLE_LBS_C_ENABLED 0
#endif

// <q> BLE_LBS_ENABLED  - ble_lbs - LED Button Service


#ifndef BLE_LBS_ENABLED
#define BLE_LBS_ENABLED 0
#endif

// <q> BLE_LLS_ENABLED  - ble_lls - Link Loss Service


#ifndef BLE_LLS_ENABLED
#define BLE_LLS_ENABLED 0
#endif

// <q> BLE_NUS_C_ENABLED  - ble_nus_c - Nordic UART Central Service


#ifndef BLE_NUS_C_ENABLED
#define BLE_NUS_C_ENABLED 0
#endif

// <q> BLE_NUS_ENABLED  - ble_nus - Nordic UART Service


#ifndef BLE_NUS_ENABLED
#define BLE_NUS_ENABLED 1
#endif

// <q> BLE_RSCS_C_ENABLED  - ble_rscs_c - Running Speed and Cadence Client


#ifndef BLE_RSCS_C_ENABLED
#define BLE_RSCS_C_ENABLED 0
#endif

// <q> BLE_RSCS_ENABLED  - ble_rscs - Running Speed and Cadence Service


#ifndef BLE_RSCS_ENABLED
#define BLE_RSCS_ENABLED 0
#endif

// <q> BLE_TPS_ENABLED  - ble_tps - TX Power Service


#ifndef BLE_TPS_ENABLED
#define BLE_TPS_ENABLED 0
#endif

// </h>
//==========================================================

// <h> nRF_Drivers

// <e> PERIPHERAL_RESOURCE_SHARING_ENABLED - nrf_drv_common - Peripheral drivers common module
//==========================================================
#ifndef PERIPHERAL_RESOURCE_SHARING_ENABLED
#define PERIPHERAL_RESOURCE_SHARING_ENABLED 0
#endif
#if  PERIPHERAL_RESOURCE_SHARING_ENABLED
// <e> COMMON_CONFIG_LOG_ENABLED - Enables logging in the module.
//==========================================================
#ifndef COMMON_CONFIG_LOG_ENABLED
#define COMMON_CONFIG_LOG_ENABLED 0
#endif
#if  COMMON_CONFIG_LOG_ENABLED
// <o> COMMON_CONFIG_LOG_LEVEL  - Default Severity level

// <0=> Off
// <1=> Error
// <2=> Warning
// <3=> Info
// <4=> Debug

#ifndef COMMON_CONFIG_LOG_LEVEL
#define COMMON_CONFIG_LOG_LEVEL 3
#endif

// <o> COMMON_CONFIG_INFO_COLOR  - ANSI escape code prefix.

// <0=> Default
// <1=> Black
// <2=> Red
// <3=> Green
// <4=> Yellow
// <5=> Blue
// <6=> Magenta
// <7=> Cyan
// <8=> White

#ifndef COMMON_CONFIG_INFO_COLOR
#define COMMON_CONFIG_INFO_COLOR 0
#endif

// <o> COMMON_CONFIG_DEBUG_COLOR  - ANSI escape code prefix.

// <0=> Default
// <1=> Black
// <2=> Red
// <3=> Green
// <4=> Yellow
// <5=> Blue
// <6=> Magenta
// <7=> Cyan
// <8=> White

#ifndef COMMON_CONFIG_DEBUG_COLOR
#define COMMON_CONFIG_DEBUG_COLOR 0
#endif

#endif //COMMON_CONFIG_LOG_ENABLED
// </e>

#endif //PERIPHERAL_RESOURCE_SHARING_ENABLED
// </e>

// <e> POWER_ENABLED - nrf_drv_power - POWER peripheral driver
//==========================================================
#ifndef POWER_ENABLED
#define POWER_ENABLED 0
#endif
#if  POWER_ENABLED
// <o> POWER_CONFIG_IRQ_PRIORITY  - Interrupt priority


// <i> Priorities 0,2 (nRF51) and 0,1,4,5 (nRF52) are reserved for SoftDevice
// <0=> 0 (highest)
// <1=> 1
// <2=> 2
// <3=> 3
// <4=> 4
// <5=> 5
// <6=> 6
// <7=> 7

#ifndef POWER_CONFIG_IRQ_PRIORITY
#define POWER_CONFIG_IRQ_PRIORITY 7
#endif

// <q> POWER_CONFIG_DEFAULT_DCDCEN  - The default configuration of main DCDC regulator


// <i> This settings means only that components for DCDC regulator are installed and it can be enabled.

#ifndef POWER_CONFIG_DEFAULT_DCDCEN
#define POWER_CONFIG_DEFAULT_DCDCEN 1
#endif

// <q> POWER_CONFIG_DEFAULT_DCDCENHV  - The default configuration of High Voltage DCDC regulator


// <i> This settings means only that components for DCDC regulator are installed and it can be enabled.

#ifndef POWER_CONFIG_DEFAULT_DCDCENHV
#define POWER_CONFIG_DEFAULT_DCDCENHV 0
#endif

#endif //POWER_ENABLED
// </e>

// <e> PPI_ENABLED - nrf_drv_ppi - PPI peripheral driver
//==========================================================
#ifndef PPI_ENABLED
#define PPI_ENABLED 1
#endif
#if  PPI_ENABLED
// <e> PPI_CONFIG_LOG_ENABLED - Enables logging in the module.
//==========================================================
#ifndef PPI_CONFIG_LOG_ENABLED
#define PPI_CONFIG_LOG_ENABLED 0
#endif
#if  PPI_CONFIG_LOG_ENABLED
// <o> PPI_CONFIG_LOG_LEVEL  - Default Severity level

// <0=> Off
// <1=> Error
// <2=> Warning
// <3=> Info
// <4=> Debug

#ifndef PPI_CONFIG_LOG_LEVEL
#define PPI_CONFIG_LOG_LEVEL 3
#endif

// <o> PPI_CONFIG_INFO_COLOR  - ANSI escape code prefix.

// <0=> Default
// <1=> Black
// <2=> Red
// <3=> Green
// <4=> Yellow
// <5=> Blue
// <6=> Magenta
// <7=> Cyan
// <8=> White

#ifndef PPI_CONFIG_INFO_COLOR
#define PPI_CONFIG_INFO_COLOR 0
#endif

// <o> PPI_CONFIG_DEBUG_COLOR  - ANSI escape code prefix.

// <0=> Default
// <1=> Black
// <2=> Red
// <3=> Green
// <4=> Yellow
// <5=> Blue
// <6=> Magenta
// <7=> Cyan
// <8=> White

#ifndef PPI_CONFIG_DEBUG_COLOR
#define PPI_CONFIG_DEBUG_COLOR 0
#endif

#endif //PPI_CONFIG_LOG_ENABLED
// </e>

#endif //PPI_ENABLED
// </e>

// <e> SAADC_ENABLED - nrf_drv_saadc - SAADC peripheral driver
//==========================================================
#ifndef SAADC_ENABLED
#define SAADC_ENABLED 1
#endif
#if  SAADC_ENABLED
// <o> SAADC_CONFIG_RESOLUTION  - Resolution

// <0=> 8 bit
// <1=> 10 bit
// <2=> 12 bit
// <3=> 14 bit

#ifndef SAADC_CONFIG_RESOLUTION
#define SAADC_CONFIG_RESOLUTION 1
#endif

// <o> SAADC_CONFIG_OVERSAMPLE  - Sample period

// <0=> Disabled
// <1=> 2x
// <2=> 4x
// <3=> 8x
// <4=> 16x
// <5=> 32x
// <6=> 64x
// <7=> 128x
// <8=> 256x

#ifndef SAADC_CONFIG_OVERSAMPLE
#define SAADC_CONFIG_OVERSAMPLE 0
#endif

// <q> SAADC_CONFIG_LP_MODE  - Enabling low power mode


#ifndef SAADC_CONFIG_LP_MODE
#define SAADC_CONFIG_LP_MODE 0
#endif

// <o> SAADC_CONFIG_IRQ_PRIORITY  - Interrupt priority


// <i> Priorities 0,2 (nRF51) and 0,1,4,5 (nRF52) are reserved for SoftDevice
// <0=> 0 (highest)
// <1=> 1
// <2=> 2
// <3=> 3
// <4=> 4
// <5=> 5
// <6=> 6
// <7=> 7

#ifndef SAADC_CONFIG_IRQ_PRIORITY
#define SAADC_CONFIG_IRQ_PRIORITY 7
#endif

// <e> SAADC_CONFIG_LOG_ENABLED - Enables logging in the module.
//==========================================================
#ifndef SAADC_CONFIG_LOG_ENABLED
#define SAADC_CONFIG_LOG_ENABLED 0
#endif
#if  SAADC_CONFIG_LOG_ENABLED
// <o> SAADC_CONFIG_LOG_LEVEL  - Default Severity level

// <0=> Off
// <1=> Error
// <2=> Warning
// <3=> Info
// <4=> Debug

#ifndef SAADC_CONFIG_LOG_LEVEL
#define SAADC_CONFIG_LOG_LEVEL 3
#endif

// <o> SAADC_CONFIG_INFO_COLOR  - ANSI escape code prefix.

// <0=> Default
// <1=> Black
// <2=> Red
// <3=> Green
// <4=> Yellow
// <5=> Blue
// <6=> Magenta
// <7=> Cyan
// <8=> White

#ifndef SAADC_CONFIG_INFO_COLOR
#define SAADC_CONFIG_INFO_COLOR 0
#endif

// <o> SAADC_CONFIG_DEBUG_COLOR  - ANSI escape code prefix.

// <0=> Default
// <1=> Black
// <2=> Red
// <3=> Green
// <4=> Yellow
// <5=> Blue
// <6=> Magenta
// <7=> Cyan
// <8=> White

#ifndef SAADC_CONFIG_DEBUG_COLOR
#define SAADC_CONFIG_DEBUG_COLOR 0
#endif

#endif //SAADC_CONFIG_LOG_ENABLED
// </e>

#endif //SAADC_ENABLED
// </e>

// <e> RTC_ENABLED - nrf_drv_rtc - RTC peripheral driver
//==========================================================
#ifndef RTC_ENABLED
#define RTC_ENABLED 1
#endif
#if  RTC_ENABLED
// <o> RTC_DEFAULT_CONFIG_FREQUENCY - Frequency  <16-32768>


#ifndef RTC_DEFAULT_CONFIG_FREQUENCY
#define RTC_DEFAULT_CONFIG_FREQUENCY 32768
#endif

// <q> RTC_DEFAULT_CONFIG_RELIABLE  - Ensures safe compare event triggering


#ifndef RTC_DEFAULT_CONFIG_RELIABLE
#define RTC_DEFAULT_CONFIG_RELIABLE 0
#endif

// <o> RTC_DEFAULT_CONFIG_IRQ_PRIORITY  - Interrupt priority


// <i> Priorities 0,2 (nRF51) and 0,1,4,5 (nRF52) are reserved for SoftDevice
// <0=> 0 (highest)
// <1=> 1
// <2=> 2
// <3=> 3
// <4=> 4
// <5=> 5
// <6=> 6
// <7=> 7

#ifndef RTC_DEFAULT_CONFIG_IRQ_PRIORITY
#define RTC_DEFAULT_CONFIG_IRQ_PRIORITY 7
#endif

// <q> RTC0_ENABLED  - Enable RTC0 instance


#ifndef RTC0_ENABLED
#define RTC0_ENABLED 0
#endif

// <q> RTC1_ENABLED  - Enable RTC1 instance


#ifndef RTC1_ENABLED
#define RTC1_ENABLED 0
#endif

// <q> RTC2_ENABLED  - Enable RTC2 instance


#ifndef RTC2_ENABLED
#define RTC2_ENABLED 1
#endif

// <o> NRF_MAXIMUM_LATENCY_US - Maximum possible time[us] in highest priority interrupt
#ifndef NRF_MAXIMUM_LATENCY_US
#define NRF_MAXIMUM_LATENCY_US 2000
#endif

// <e> RTC_CONFIG_LOG_ENABLED - Enables logging in the module.
//==========================================================
#ifndef RTC_CONFIG_LOG_ENABLED
#define RTC_CONFIG_LOG_ENABLED 0
#endif
#if  RTC_CONFIG_LOG_ENABLED
// <o> RTC_CONFIG_LOG_LEVEL  - Default Severity level

// <0=> Off
// <1=> Error
// <2=> Warning
// <3=> Info
// <4=> Debug

#ifndef RTC_CONFIG_LOG_LEVEL
#define RTC_CONFIG_LOG_LEVEL 3
#endif

// <o> RTC_CONFIG_INFO_COLOR  - ANSI escape code prefix.

// <0=> Default
// <1=> Black
// <2=> Red
// <3=> Green
// <4=> Yellow
// <5=> Blue
// <6=> Magenta
// <7=> Cyan
// <8=> White

#ifndef RTC_CONFIG_INFO_COLOR
#define RTC_CONFIG_INFO_COLOR 0
#endif

// <o> RTC_CONFIG_DEBUG_COLOR  - ANSI escape code prefix.

// <0=> Default
// <1=> Black
// <2=> Red
// <3=> Green
// <4=> Yellow
// <5=> Blue
// <6=> Magenta
// <7=> Cyan
// <8=> White

#ifndef RTC_CONFIG_DEBUG_COLOR
#define RTC_CONFIG_DEBUG_COLOR 0
#endif

#endif //RTC_CONFIG_LOG_ENABLED
// </e>

#endif //RTC_ENABLED
// </e>

// <e> TIMER_ENABLED - nrf_drv_timer - TIMER periperal driver
//==========================================================
#ifndef TIMER_ENABLED
#define TIMER_ENABLED 1
#endif
#if  TIMER_ENABLED
// <o> TIMER_DEFAULT_CONFIG_FREQUENCY  - Timer frequency if in Timer mode

// <0=> 16 MHz
// <1=> 8 MHz
// <2=> 4 MHz
// <3=> 2 MHz
// <4=> 1 MHz
// <5=> 500 kHz
// <6=> 250 kHz
// <7=> 125 kHz
// <8=> 62.5 kHz
// <9=> 31.25 kHz

#ifndef TIMER_DEFAULT_CONFIG_FREQUENCY
#define TIMER_DEFAULT_CONFIG_FREQUENCY 0
#endif

// <o> TIMER_DEFAULT_CONFIG_MODE  - Timer mode or operation

// <0=> Timer
// <1=> Counter

#ifndef TIMER_DEFAULT_CONFIG_MODE
#define TIMER_DEFAULT_CONFIG_MODE 0
#endif

// <o> TIMER_DEFAULT_CONFIG_BIT_WIDTH  - Timer counter bit width

// <0=> 16 bit
// <1=> 8 bit
// <2=> 24 bit
// <3=> 32 bit

#ifndef TIMER_DEFAULT_CONFIG_BIT_WIDTH
#define TIMER_DEFAULT_CONFIG_BIT_WIDTH 0
#endif

// <o> TIMER_DEFAULT_CONFIG_IRQ_PRIORITY  - Interrupt priority


// <i> Priorities 0,2 (nRF51) and 0,1,4,5 (nRF52) are reserved for SoftDevice
// <0=> 0 (highest)
// <1=> 1
// <2=> 2
// <3=> 3
// <4=> 4
// <5=> 5
// <6=> 6
// <7=> 7

#ifndef TIMER_DEFAULT_CONFIG_IRQ_PRIORITY
#define TIMER_DEFAULT_CONFIG_IRQ_PRIORITY 7
#endif

// <q> TIMER0_ENABLED  - Enable TIMER0 instance


#ifndef TIMER0_ENABLED
#define TIMER0_ENABLED 0
#endif

// <q> TIMER1_ENABLED  - Enable TIMER1 instance


#ifndef TIMER1_ENABLED
#define TIMER1_ENABLED 1
#endif

// <q> TIMER2_ENABLED  - Enable TIMER2 instance


#ifndef TIMER2_ENABLED
#define TIMER2_ENABLED 1
#endif

// <q> TIMER3_ENABLED  - Enable TIMER3 instance


#ifndef TIMER3_ENABLED
#define TIMER3_ENABLED 0
#endif

// <q> TIMER4_ENABLED  - Enable TIMER4 instance


#ifndef TIMER4_ENABLED
#define TIMER4_ENABLED 0
#endif

// <e> TIMER_CONFIG_LOG_ENABLED - Enables logging in the module.
//==========================================================
#ifndef TIMER_CONFIG_LOG_ENABLED
#define TIMER_CONFIG_LOG_ENABLED 0
#endif
#if  TIMER_CONFIG_LOG_ENABLED
// <o> TIMER_CONFIG_LOG_LEVEL  - Default Severity level

// <0=> Off
// <1=> Error
// <2=> Warning
// <3=> Info
// <4=> Debug

#ifndef TIMER_CONFIG_LOG_LEVEL
#define TIMER_CONFIG_LOG_LEVEL 3
#endif

// <o> TIMER_CONFIG_INFO_COLOR  - ANSI escape code prefix.

// <0=> Default
// <1=> Black
// <2=> Red
// <3=> Green
// <4=> Yellow
// <5=> Blue
// <6=> Magenta
// <7=> Cyan
// <8=> White

#ifndef TIMER_CONFIG_INFO_COLOR
#define TIMER_CONFIG_INFO_COLOR 0
#endif

// <o> TIMER_CONFIG_DEBUG_COLOR  - ANSI escape code prefix.

// <0=> Default
// <1=> Black
// <2=> Red
// <3=> Green
// <4=> Yellow
// <5=> Blue
// <6=> Magenta
// <7=> Cyan
// <8=> White

#ifndef TIMER_CONFIG_DEBUG_COLOR
#define TIMER_CONFIG_DEBUG_COLOR 0
#endif

#endif //TIMER_CONFIG_LOG_ENABLED
// </e>

#endif //TIMER_ENABLED
// </e>

// <e> UART_ENABLED - nrf_drv_uart - UART/UARTE peripheral driver
//==========================================================
#ifndef UART_ENABLED
#define UART_ENABLED 1
#endif
#if  UART_ENABLED
// <o> UART_DEFAULT_CONFIG_HWFC  - Hardware Flow Control

// <0=> Disabled
// <1=> Enabled

#ifndef UART_DEFAULT_CONFIG_HWFC
#define UART_DEFAULT_CONFIG_HWFC 0
#endif

// <o> UART_DEFAULT_CONFIG_PARITY  - Parity

// <0=> Excluded
// <14=> Included

#ifndef UART_DEFAULT_CONFIG_PARITY
#define UART_DEFAULT_CONFIG_PARITY 0
#endif

// <o> UART_DEFAULT_CONFIG_BAUDRATE  - Default Baudrate

// <323584=> 1200 baud
// <643072=> 2400 baud
// <1290240=> 4800 baud
// <2576384=> 9600 baud
// <3862528=> 14400 baud
// <5152768=> 19200 baud
// <7716864=> 28800 baud
// <10289152=> 38400 baud
// <15400960=> 57600 baud
// <20615168=> 76800 baud
// <30801920=> 115200 baud
// <61865984=> 230400 baud
// <67108864=> 250000 baud
// <121634816=> 460800 baud
// <251658240=> 921600 baud
// <268435456=> 57600 baud

#ifndef UART_DEFAULT_CONFIG_BAUDRATE
#define UART_DEFAULT_CONFIG_BAUDRATE 30801920
#endif

// <o> UART_DEFAULT_CONFIG_IRQ_PRIORITY  - Interrupt priority


// <i> Priorities 0,2 (nRF51) and 0,1,4,5 (nRF52) are reserved for SoftDevice
// <0=> 0 (highest)
// <1=> 1
// <2=> 2
// <3=> 3
// <4=> 4
// <5=> 5
// <6=> 6
// <7=> 7

#ifndef UART_DEFAULT_CONFIG_IRQ_PRIORITY
#define UART_DEFAULT_CONFIG_IRQ_PRIORITY 7
#endif

// <q> UART_EASY_DMA_SUPPORT  - Driver supporting EasyDMA


#ifndef UART_EASY_DMA_SUPPORT
#define UART_EASY_DMA_SUPPORT 1
#endif

// <q> UART_LEGACY_SUPPORT  - Driver supporting Legacy mode


#ifndef UART_LEGACY_SUPPORT
#define UART_LEGACY_SUPPORT 1
#endif

// <e> UART0_ENABLED - Enable UART0 instance
//==========================================================
#ifndef UART0_ENABLED
#define UART0_ENABLED 1
#endif
#if  UART0_ENABLED
// <q> UART0_CONFIG_USE_EASY_DMA  - Default setting for using EasyDMA


#ifndef UART0_CONFIG_USE_EASY_DMA
#define UART0_CONFIG_USE_EASY_DMA 1
#endif

#endif //UART0_ENABLED
// </e>

// <e> UART_CONFIG_LOG_ENABLED - Enables logging in the module.
//==========================================================
#ifndef UART_CONFIG_LOG_ENABLED
#define UART_CONFIG_LOG_ENABLED 0
#endif
#if  UART_CONFIG_LOG_ENABLED
// <o> UART_CONFIG_LOG_LEVEL  - Default Severity level

// <0=> Off
// <1=> Error
// <2=> Warning
// <3=> Info
// <4=> Debug

#ifndef UART_CONFIG_LOG_LEVEL
#define UART_CONFIG_LOG_LEVEL 3
#endif

// <o> UART_CONFIG_INFO_COLOR  - ANSI escape code prefix.

// <0=> Default
// <1=> Black
// <2=> Red
// <3=> Green
// <4=> Yellow
// <5=> Blue
// <6=> Magenta
// <7=> Cyan
// <8=> White

#ifndef UART_CONFIG_INFO_COLOR
#define UART_CONFIG_INFO_COLOR 0
#endif

// <o> UART_CONFIG_DEBUG_COLOR  - ANSI escape code prefix.

// <0=> Default
// <1=> Black
// <2=> Red
// <3=> Green
// <4=> Yellow
// <5=> Blue
// <6=> Magenta
// <7=> Cyan
// <8=> White

#ifndef UART_CONFIG_DEBUG_COLOR
#define UART_CONFIG_DEBUG_COLOR 0
#endif

#endif //UART_CONFIG_LOG_ENABLED
// </e>

#endif //UART_ENABLED
// </e>

// </h>
//==========================================================

// <h> nRF_Libraries

//==========================================================

// <e> NRF_PWR_MGMT_ENABLED - nrf_pwr_mgmt - Power management module
//==========================================================
#ifndef NRF_PWR_MGMT_ENABLED
#define NRF_PWR_MGMT_ENABLED 0
#endif
#if  NRF_PWR_MGMT_ENABLED
// <e> NRF_PWR_MGMT_CONFIG_LOG_ENABLED - Enables logging in the module.
//==========================================================
#ifndef NRF_PWR_MGMT_CONFIG_LOG_ENABLED
#define NRF_PWR_MGMT_CONFIG_LOG_ENABLED 0
#endif
#if  NRF_PWR_MGMT_CONFIG_LOG_ENABLED
// <o> NRF_PWR_MGMT_CONFIG_LOG_LEVEL  - Default Severity level

// <0=> Off
// <1=> Error
// <2=> Warning
// <3=> Info
// <4=> Debug

#ifndef NRF_PWR_MGMT_CONFIG_LOG_LEVEL
#define NRF_PWR_MGMT_CONFIG_LOG_LEVEL 3
#endif

// <o> NRF_PWR_MGMT_CONFIG_INFO_COLOR  - ANSI escape code prefix.

// <0=> Default
// <1=> Black
// <2=> Red
// <3=> Green
// <4=> Yellow
// <5=> Blue
// <6=> Magenta
// <7=> Cyan
// <8=> White

#ifndef NRF_PWR_MGMT_CONFIG_INFO_COLOR
#define NRF_PWR_MGMT_CONFIG_INFO_COLOR 0
#endif

// <o> NRF_PWR_MGMT_CONFIG_DEBUG_COLOR  - ANSI escape code prefix.

// <0=> Default
// <1=> Black
// <2=> Red
// <3=> Green
// <4=> Yellow
// <5=> Blue
// <6=> Magenta
// <7=> Cyan
// <8=> White

#ifndef NRF_PWR_MGMT_CONFIG_DEBUG_COLOR
#define NRF_PWR_MGMT_CONFIG_DEBUG_COLOR 0
#endif

#endif //NRF_PWR_MGMT_CONFIG_LOG_ENABLED
// </e>

// <e> NRF_PWR_MGMT_CONFIG_DEBUG_PIN_ENABLED - Enables pin debug in the module.

// <i> Selected pin will be set when CPU is in sleep mode.
//==========================================================
#ifndef NRF_PWR_MGMT_CONFIG_DEBUG_PIN_ENABLED
#define NRF_PWR_MGMT_CONFIG_DEBUG_PIN_ENABLED 0
#endif
#if  NRF_PWR_MGMT_CONFIG_DEBUG_PIN_ENABLED
// <o> NRF_PWR_MGMT_SLEEP_DEBUG_PIN - Pin number  <0-31>


#ifndef NRF_PWR_MGMT_SLEEP_DEBUG_PIN
#define NRF_PWR_MGMT_SLEEP_DEBUG_PIN 31
#endif

#endif //NRF_PWR_MGMT_CONFIG_DEBUG_PIN_ENABLED
// </e>

// <q> NRF_PWR_MGMT_CONFIG_CPU_USAGE_MONITOR_ENABLED  - Enables CPU usage monitor.


// <i> Module will trace percentage of CPU usage in one second intervals.

#ifndef NRF_PWR_MGMT_CONFIG_CPU_USAGE_MONITOR_ENABLED
#define NRF_PWR_MGMT_CONFIG_CPU_USAGE_MONITOR_ENABLED 0
#endif

// <e> NRF_PWR_MGMT_CONFIG_STANDBY_TIMEOUT_ENABLED - Enable standby timeout.
//==========================================================
#ifndef NRF_PWR_MGMT_CONFIG_STANDBY_TIMEOUT_ENABLED
#define NRF_PWR_MGMT_CONFIG_STANDBY_TIMEOUT_ENABLED 0
#endif
#if  NRF_PWR_MGMT_CONFIG_STANDBY_TIMEOUT_ENABLED
// <o> NRF_PWR_MGMT_CONFIG_STANDBY_TIMEOUT_S - Standby timeout (in seconds).
// <i> Shutdown procedure will begin no earlier than after this number of seconds.

#ifndef NRF_PWR_MGMT_CONFIG_STANDBY_TIMEOUT_S
#define NRF_PWR_MGMT_CONFIG_STANDBY_TIMEOUT_S 3
#endif

#endif //NRF_PWR_MGMT_CONFIG_STANDBY_TIMEOUT_ENABLED
// </e>

// <q> NRF_PWR_MGMT_CONFIG_FPU_SUPPORT_ENABLED  - Enables FPU event cleaning.


#ifndef NRF_PWR_MGMT_CONFIG_FPU_SUPPORT_ENABLED
#define NRF_PWR_MGMT_CONFIG_FPU_SUPPORT_ENABLED 0
#endif

// <q> NRF_PWR_MGMT_CONFIG_AUTO_SHUTDOWN_RETRY  - Blocked shutdown procedure will be retried every second.


#ifndef NRF_PWR_MGMT_CONFIG_AUTO_SHUTDOWN_RETRY
#define NRF_PWR_MGMT_CONFIG_AUTO_SHUTDOWN_RETRY 0
#endif

// <q> NRF_PWR_MGMT_CONFIG_USE_SCHEDULER  - Module will use @ref app_scheduler.


#ifndef NRF_PWR_MGMT_CONFIG_USE_SCHEDULER
#define NRF_PWR_MGMT_CONFIG_USE_SCHEDULER 0
#endif

#endif //NRF_PWR_MGMT_ENABLED
// </e>

// </h>
//==========================================================

// <h> nRF_Log

//==========================================================
// <e> NRF_LOG_ENABLED - nrf_log - Logging
//==========================================================
#ifndef NRF_LOG_ENABLED
#define NRF_LOG_ENABLED 1
#endif
#if  NRF_LOG_ENABLED
// <e> NRF_LOG_USES_COLORS - If enabled then ANSI escape code for colors is prefixed to every string
//==========================================================
#ifndef NRF_LOG_USES_COLORS
#define NRF_LOG_USES_COLORS 0
#endif
#if  NRF_LOG_USES_COLORS
// <o> NRF_LOG_COLOR_DEFAULT  - ANSI escape code prefix.

// <0=> Default
// <1=> Black
// <2=> Red
// <3=> Green
// <4=> Yellow
// <5=> Blue
// <6=> Magenta
// <7=> Cyan
// <8=> White

#ifndef NRF_LOG_COLOR_DEFAULT
#define NRF_LOG_COLOR_DEFAULT 0
#endif

// <o> NRF_LOG_ERROR_COLOR  - ANSI escape code prefix.

// <0=> Default
// <1=> Black
// <2=> Red
// <3=> Green
// <4=> Yellow
// <5=> Blue
// <6=> Magenta
// <7=> Cyan
// <8=> White

#ifndef NRF_LOG_ERROR_COLOR
#define NRF_LOG_ERROR_COLOR 0
#endif

// <o> NRF_LOG_WARNING_COLOR  - ANSI escape code prefix.

// <0=> Default
// <1=> Black
// <2=> Red
// <3=> Green
// <4=> Yellow
// <5=> Blue
// <6=> Magenta
// <7=> Cyan
// <8=> White

#ifndef NRF_LOG_WARNING_COLOR
#define NRF_LOG_WARNING_COLOR 0
#endif

#endif //NRF_LOG_USES_COLORS
// </e>

// <o> NRF_LOG_DEFAULT_LEVEL  - Default Severity level

// <0=> Off
// <1=> Error
// <2=> Warning
// <3=> Info
// <4=> Debug

#ifndef NRF_LOG_DEFAULT_LEVEL
#define NRF_LOG_DEFAULT_LEVEL 3
#endif

// <e> NRF_LOG_DEFERRED - Enable deffered logger.

// <i> Log data is buffered and can be processed in idle.
//==========================================================
#ifndef NRF_LOG_DEFERRED
#define NRF_LOG_DEFERRED 1
#endif
#if  NRF_LOG_DEFERRED
// <o> NRF_LOG_DEFERRED_BUFSIZE - Size of the buffer for logs in words.
// <i> Must be power of 2

#ifndef NRF_LOG_DEFERRED_BUFSIZE
#define NRF_LOG_DEFERRED_BUFSIZE 256
#endif

#endif //NRF_LOG_DEFERRED
// </e>

// <q> NRF_LOG_USES_TIMESTAMP  - Enable timestamping


// <i> Function for getting the timestamp is provided by the user

#ifndef NRF_LOG_USES_TIMESTAMP
#define NRF_LOG_USES_TIMESTAMP 0
#endif

#endif //NRF_LOG_ENABLED
// </e>

// <h> nrf_log_backend - Logging sink

//==========================================================
// <o> NRF_LOG_BACKEND_MAX_STRING_LENGTH - Buffer for storing single output string
// <i> Logger backend RAM usage is determined by this value.

#ifndef NRF_LOG_BACKEND_MAX_STRING_LENGTH
#define NRF_LOG_BACKEND_MAX_STRING_LENGTH 256
#endif

// <o> NRF_LOG_TIMESTAMP_DIGITS - Number of digits for timestamp
// <i> If higher resolution timestamp source is used it might be needed to increase that

#ifndef NRF_LOG_TIMESTAMP_DIGITS
#define NRF_LOG_TIMESTAMP_DIGITS 8
#endif

// <e> NRF_LOG_BACKEND_SERIAL_USES_UART - If enabled data is printed over UART
//==========================================================
#ifndef NRF_LOG_BACKEND_SERIAL_USES_UART
#define NRF_LOG_BACKEND_SERIAL_USES_UART 0
#endif
#if  NRF_LOG_BACKEND_SERIAL_USES_UART
// <o> NRF_LOG_BACKEND_SERIAL_UART_BAUDRATE  - Default Baudrate

// <323584=> 1200 baud
// <643072=> 2400 baud
// <1290240=> 4800 baud
// <2576384=> 9600 baud
// <3862528=> 14400 baud
// <5152768=> 19200 baud
// <7716864=> 28800 baud
// <10289152=> 38400 baud
// <15400960=> 57600 baud
// <20615168=> 76800 baud
// <30801920=> 115200 baud
// <61865984=> 230400 baud
// <67108864=> 250000 baud
// <121634816=> 460800 baud
// <251658240=> 921600 baud
// <268435456=> 57600 baud

#ifndef NRF_LOG_BACKEND_SERIAL_UART_BAUDRATE
#define NRF_LOG_BACKEND_SERIAL_UART_BAUDRATE 30801920
#endif

// <o> NRF_LOG_BACKEND_SERIAL_UART_TX_PIN - UART TX pin
#ifndef NRF_LOG_BACKEND_SERIAL_UART_TX_PIN
#define NRF_LOG_BACKEND_SERIAL_UART_TX_PIN 6
#endif

// <o> NRF_LOG_BACKEND_SERIAL_UART_RX_PIN - UART RX pin
#ifndef NRF_LOG_BACKEND_SERIAL_UART_RX_PIN
#define NRF_LOG_BACKEND_SERIAL_UART_RX_PIN 8
#endif

// <o> NRF_LOG_BACKEND_SERIAL_UART_RTS_PIN - UART RTS pin
#ifndef NRF_LOG_BACKEND_SERIAL_UART_RTS_PIN
#define NRF_LOG_BACKEND_SERIAL_UART_RTS_PIN 5
#endif

// <o> NRF_LOG_BACKEND_SERIAL_UART_CTS_PIN - UART CTS pin
#ifndef NRF_LOG_BACKEND_SERIAL_UART_CTS_PIN
#define NRF_LOG_BACKEND_SERIAL_UART_CTS_PIN 7
#endif

// <o> NRF_LOG_BACKEND_SERIAL_UART_FLOW_CONTROL  - Hardware Flow Control

// <0=> Disabled
// <1=> Enabled

#ifndef NRF_LOG_BACKEND_SERIAL_UART_FLOW_CONTROL
#define NRF_LOG_BACKEND_SERIAL_UART_FLOW_CONTROL 0
#endif

// <o> NRF_LOG_BACKEND_UART_INSTANCE  - UART instance used

// <0=> 0

#ifndef NRF_LOG_BACKEND_UART_INSTANCE
#define NRF_LOG_BACKEND_UART_INSTANCE 0
#endif

#endif //NRF_LOG_BACKEND_SERIAL_USES_UART
// </e>

// <e> NRF_LOG_BACKEND_SERIAL_USES_RTT - If enabled data is printed using RTT
//==========================================================
#ifndef NRF_LOG_BACKEND_SERIAL_USES_RTT
#define NRF_LOG_BACKEND_SERIAL_USES_RTT 1
#endif
#if  NRF_LOG_BACKEND_SERIAL_USES_RTT
// <o> NRF_LOG_BACKEND_RTT_OUTPUT_BUFFER_SIZE - RTT output buffer size.
// <i> Should be equal or bigger than \ref NRF_LOG_BACKEND_MAX_STRING_LENGTH.
// <i> This value is used in Segger RTT configuration to set the buffer size
// <i> if it is bigger than default RTT buffer size.

#ifndef NRF_LOG_BACKEND_RTT_OUTPUT_BUFFER_SIZE
#define NRF_LOG_BACKEND_RTT_OUTPUT_BUFFER_SIZE 512
#endif

#endif //NRF_LOG_BACKEND_SERIAL_USES_RTT
// </e>

// </h>
//==========================================================

// </h>
//==========================================================

// <h> nRF_Segger_RTT

//==========================================================
// <h> segger_rtt - SEGGER RTT

//==========================================================
// <o> SEGGER_RTT_CONFIG_BUFFER_SIZE_UP - Size of upstream buffer.
#ifndef SEGGER_RTT_CONFIG_BUFFER_SIZE_UP
#define SEGGER_RTT_CONFIG_BUFFER_SIZE_UP 64
#endif

// <o> SEGGER_RTT_CONFIG_MAX_NUM_UP_BUFFERS - Size of upstream buffer.
#ifndef SEGGER_RTT_CONFIG_MAX_NUM_UP_BUFFERS
#define SEGGER_RTT_CONFIG_MAX_NUM_UP_BUFFERS 2
#endif

// <o> SEGGER_RTT_CONFIG_BUFFER_SIZE_DOWN - Size of upstream buffer.
#ifndef SEGGER_RTT_CONFIG_BUFFER_SIZE_DOWN
#define SEGGER_RTT_CONFIG_BUFFER_SIZE_DOWN 16
#endif

// <o> SEGGER_RTT_CONFIG_MAX_NUM_DOWN_BUFFERS - Size of upstream buffer.
#ifndef SEGGER_RTT_CONFIG_MAX_NUM_DOWN_BUFFERS
#define SEGGER_RTT_CONFIG_MAX_NUM_DOWN_BUFFERS 2
#endif

// </h>
//==========================================================

// <e> APP_UART_ENABLED - app_uart - UART driver
//==========================================================
#ifndef APP_UART_ENABLED
#define APP_UART_ENABLED 1
#endif
#if  APP_UART_ENABLED
// <o> APP_UART_DRIVER_INSTANCE  - UART instance used

// <0=> 0

#ifndef APP_UART_DRIVER_INSTANCE
#define APP_UART_DRIVER_INSTANCE 0
#endif

#endif //APP_UART_ENABLED
// </e>

// <q> APP_USBD_CLASS_AUDIO_ENABLED  - app_usbd_audio - USB AUDIO class


#ifndef APP_USBD_CLASS_AUDIO_ENABLED
#define APP_USBD_CLASS_AUDIO_ENABLED 0
#endif

// <q> APP_USBD_CLASS_HID_ENABLED  - app_usbd_hid - USB HID class


#ifndef APP_USBD_CLASS_HID_ENABLED
#define APP_USBD_CLASS_HID_ENABLED 0
#endif

// <q> APP_USBD_HID_GENERIC_ENABLED  - app_usbd_hid_generic - USB HID generic


#ifndef APP_USBD_HID_GENERIC_ENABLED
#define APP_USBD_HID_GENERIC_ENABLED 0
#endif

// <q> APP_USBD_HID_KBD_ENABLED  - app_usbd_hid_kbd - USB HID keyboard


#ifndef APP_USBD_HID_KBD_ENABLED
#define APP_USBD_HID_KBD_ENABLED 0
#endif

// <q> APP_USBD_HID_MOUSE_ENABLED  - app_usbd_hid_mouse - USB HID mouse


#ifndef APP_USBD_HID_MOUSE_ENABLED
#define APP_USBD_HID_MOUSE_ENABLED 0
#endif

// <q> BUTTON_ENABLED  - app_button - buttons handling module


#ifndef BUTTON_ENABLED
#define BUTTON_ENABLED 1
#endif

// <q> CRC16_ENABLED  - crc16 - CRC16 calculation routines


#ifndef CRC16_ENABLED
#define CRC16_ENABLED 0
#endif

// <q> CRC32_ENABLED  - crc32 - CRC32 calculation routines


#ifndef CRC32_ENABLED
#define CRC32_ENABLED 0
#endif

// <q> ECC_ENABLED  - ecc - Elliptic Curve Cryptography Library


#ifndef ECC_ENABLED
#define ECC_ENABLED 0
#endif

// <e> FSTORAGE_ENABLED - fstorage - Flash storage module
//==========================================================
#ifndef FSTORAGE_ENABLED
#define FSTORAGE_ENABLED 1
#endif
#if  FSTORAGE_ENABLED
// <o> FS_QUEUE_SIZE - Configures the size of the internal queue.
// <i> Increase this if there are many users, or if it is likely that many
// <i> operation will be queued at once without waiting for the previous operations
// <i> to complete. In general, increase the queue size if you frequently receive
// <i> @ref FS_ERR_QUEUE_FULL errors when calling @ref fs_store or @ref fs_erase.

#ifndef FS_QUEUE_SIZE
#define FS_QUEUE_SIZE 4
#endif

// <o> FS_OP_MAX_RETRIES - Number attempts to execute an operation if the SoftDevice fails.
// <i> Increase this value if events return the @ref FS_ERR_OPERATION_TIMEOUT
// <i> error often. The SoftDevice may fail to schedule flash access due to high BLE activity.

#ifndef FS_OP_MAX_RETRIES
#define FS_OP_MAX_RETRIES 3
#endif

// <o> FS_MAX_WRITE_SIZE_WORDS - Maximum number of words to be written to flash in a single operation.
// <i> Tweaking this value can increase the chances of the SoftDevice being
// <i> able to fit flash operations in between radio activity. This value is bound by the
// <i> maximum number of words which the SoftDevice can write to flash in a single call to
// <i> @ref sd_flash_write, which is 256 words for nRF51 ICs and 1024 words for nRF52 ICs.

#ifndef FS_MAX_WRITE_SIZE_WORDS
#define FS_MAX_WRITE_SIZE_WORDS 1024
#endif

#endif //FSTORAGE_ENABLED
// </e>

// <q> HARDFAULT_HANDLER_ENABLED  - hardfault_default - HardFault default handler for debugging and release


#ifndef HARDFAULT_HANDLER_ENABLED
#define HARDFAULT_HANDLER_ENABLED 0
#endif

// <q> NRF_QUEUE_ENABLED  - nrf_queue - Queue module


#ifndef NRF_QUEUE_ENABLED
#define NRF_QUEUE_ENABLED 0
#endif

// <q> RETARGET_ENABLED  - retarget - Retargeting stdio functions


#ifndef RETARGET_ENABLED
#define RETARGET_ENABLED 1
#endif

// <q> SLIP_ENABLED  - slip - SLIP encoding decoding


#ifndef SLIP_ENABLED
#define SLIP_ENABLED 0
#endif

// <e> ADC_ENABLED - nrf_drv_adc - Driver for ADC peripheral (nRF51)
//==========================================================
#ifndef ADC_ENABLED
#define ADC_ENABLED 1
#endif
#if  ADC_ENABLED
// <o> ADC_CONFIG_IRQ_PRIORITY  - Interrupt priority


// <i> Priorities 0,2 (nRF51) and 0,1,4,5 (nRF52) are reserved for SoftDevice
// <0=> 0 (highest)
// <1=> 1
// <2=> 2
// <3=> 3
// <4=> 4
// <5=> 5
// <6=> 6
// <7=> 7

#ifndef ADC_CONFIG_IRQ_PRIORITY
#define ADC_CONFIG_IRQ_PRIORITY 7
#endif

// <e> ADC_CONFIG_LOG_ENABLED - Enables logging in the module.
//==========================================================
#ifndef ADC_CONFIG_LOG_ENABLED
#define ADC_CONFIG_LOG_ENABLED 0
#endif
#if  ADC_CONFIG_LOG_ENABLED
// <o> ADC_CONFIG_LOG_LEVEL  - Default Severity level

// <0=> Off
// <1=> Error
// <2=> Warning
// <3=> Info
// <4=> Debug

#ifndef ADC_CONFIG_LOG_LEVEL
#define ADC_CONFIG_LOG_LEVEL 3
#endif

// <o> ADC_CONFIG_INFO_COLOR  - ANSI escape code prefix.

// <0=> Default
// <1=> Black
// <2=> Red
// <3=> Green
// <4=> Yellow
// <5=> Blue
// <6=> Magenta
// <7=> Cyan
// <8=> White

#ifndef ADC_CONFIG_INFO_COLOR
#define ADC_CONFIG_INFO_COLOR 0
#endif

// <o> ADC_CONFIG_DEBUG_COLOR  - ANSI escape code prefix.

// <0=> Default
// <1=> Black
// <2=> Red
// <3=> Green
// <4=> Yellow
// <5=> Blue
// <6=> Magenta
// <7=> Cyan
// <8=> White

#ifndef ADC_CONFIG_DEBUG_COLOR
#define ADC_CONFIG_DEBUG_COLOR 0
#endif

#endif //ADC_CONFIG_LOG_ENABLED
// </e>

#endif //ADC_ENABLED

// <e> CLOCK_ENABLED - nrf_drv_clock - CLOCK peripheral driver
//==========================================================
#ifndef CLOCK_ENABLED
#define CLOCK_ENABLED 1
#endif
#if  CLOCK_ENABLED
// <o> CLOCK_CONFIG_XTAL_FREQ  - HF XTAL Frequency

// <0=> Default (64 MHz)

#ifndef CLOCK_CONFIG_XTAL_FREQ
#define CLOCK_CONFIG_XTAL_FREQ 0
#endif

// <o> CLOCK_CONFIG_LF_SRC  - LF Clock Source

// <0=> RC
// <1=> XTAL
// <2=> Synth

#ifndef CLOCK_CONFIG_LF_SRC
#define CLOCK_CONFIG_LF_SRC 1
#endif

// <o> CLOCK_CONFIG_IRQ_PRIORITY  - Interrupt priority


// <i> Priorities 0,2 (nRF51) and 0,1,4,5 (nRF52) are reserved for SoftDevice
// <0=> 0 (highest)
// <1=> 1
// <2=> 2
// <3=> 3
// <4=> 4
// <5=> 5
// <6=> 6
// <7=> 7

#ifndef CLOCK_CONFIG_IRQ_PRIORITY
#define CLOCK_CONFIG_IRQ_PRIORITY 7
#endif

// <e> CLOCK_CONFIG_LOG_ENABLED - Enables logging in the module.
//==========================================================
#ifndef CLOCK_CONFIG_LOG_ENABLED
#define CLOCK_CONFIG_LOG_ENABLED 0
#endif
#if  CLOCK_CONFIG_LOG_ENABLED
// <o> CLOCK_CONFIG_LOG_LEVEL  - Default Severity level

// <0=> Off
// <1=> Error
// <2=> Warning
// <3=> Info
// <4=> Debug

#ifndef CLOCK_CONFIG_LOG_LEVEL
#define CLOCK_CONFIG_LOG_LEVEL 3
#endif

// <o> CLOCK_CONFIG_INFO_COLOR  - ANSI escape code prefix.

// <0=> Default
// <1=> Black
// <2=> Red
// <3=> Green
// <4=> Yellow
// <5=> Blue
// <6=> Magenta
// <7=> Cyan
// <8=> White

#ifndef CLOCK_CONFIG_INFO_COLOR
#define CLOCK_CONFIG_INFO_COLOR 0
#endif

// <o> CLOCK_CONFIG_DEBUG_COLOR  - ANSI escape code prefix.

// <0=> Default
// <1=> Black
// <2=> Red
// <3=> Green
// <4=> Yellow
// <5=> Blue
// <6=> Magenta
// <7=> Cyan
// <8=> White

#ifndef CLOCK_CONFIG_DEBUG_COLOR
#define CLOCK_CONFIG_DEBUG_COLOR 0
#endif

#endif //CLOCK_CONFIG_LOG_ENABLED
// </e>

#endif //CLOCK_ENABLED

// <h> nRF_Libraries

//==========================================================
// <q> APP_FIFO_ENABLED  - app_fifo - Software FIFO implementation


#ifndef APP_FIFO_ENABLED
#define APP_FIFO_ENABLED 1
#endif

// <q> APP_GPIOTE_ENABLED  - app_gpiote - GPIOTE events dispatcher


#ifndef APP_GPIOTE_ENABLED
#define APP_GPIOTE_ENABLED 1
#endif

// <e> APP_TIMER_ENABLED - app_timer - Application timer functionality
//==========================================================
#ifndef APP_TIMER_ENABLED
#define APP_TIMER_ENABLED 1
#endif
#if  APP_TIMER_ENABLED
// <q> APP_TIMER_WITH_PROFILER  - Enable app_timer profiling


#ifndef APP_TIMER_WITH_PROFILER
#define APP_TIMER_WITH_PROFILER 0
#endif

// <q> APP_TIMER_KEEPS_RTC_ACTIVE  - Enable RTC always on


// <i> If option is enabled RTC is kept running even if there is no active timers.
// <i> This option can be used when app_timer is used for timestamping.

#ifndef APP_TIMER_KEEPS_RTC_ACTIVE
#define APP_TIMER_KEEPS_RTC_ACTIVE 0
#endif

#endif //APP_TIMER_ENABLED

// <e> GPIOTE_ENABLED - nrf_drv_gpiote - GPIOTE peripheral driver
//==========================================================
#ifndef GPIOTE_ENABLED
#define GPIOTE_ENABLED 1
#endif
#if  GPIOTE_ENABLED
// <o> GPIOTE_CONFIG_NUM_OF_LOW_POWER_EVENTS - Number of lower power input pins
#ifndef GPIOTE_CONFIG_NUM_OF_LOW_POWER_EVENTS
#define GPIOTE_CONFIG_NUM_OF_LOW_POWER_EVENTS 4
#endif

// <o> GPIOTE_CONFIG_IRQ_PRIORITY  - Interrupt priority


// <i> Priorities 0,2 (nRF51) and 0,1,4,5 (nRF52) are reserved for SoftDevice
// <0=> 0 (highest)
// <1=> 1
// <2=> 2
// <3=> 3
// <4=> 4
// <5=> 5
// <6=> 6
// <7=> 7

#ifndef GPIOTE_CONFIG_IRQ_PRIORITY
#define GPIOTE_CONFIG_IRQ_PRIORITY 7
#endif

// <e> GPIOTE_CONFIG_LOG_ENABLED - Enables logging in the module.
//==========================================================
#ifndef GPIOTE_CONFIG_LOG_ENABLED
#define GPIOTE_CONFIG_LOG_ENABLED 0
#endif
#if  GPIOTE_CONFIG_LOG_ENABLED
// <o> GPIOTE_CONFIG_LOG_LEVEL  - Default Severity level

// <0=> Off
// <1=> Error
// <2=> Warning
// <3=> Info
// <4=> Debug

#ifndef GPIOTE_CONFIG_LOG_LEVEL
#define GPIOTE_CONFIG_LOG_LEVEL 3
#endif

// <o> GPIOTE_CONFIG_INFO_COLOR  - ANSI escape code prefix.

// <0=> Default
// <1=> Black
// <2=> Red
// <3=> Green
// <4=> Yellow
// <5=> Blue
// <6=> Magenta
// <7=> Cyan
// <8=> White

#ifndef GPIOTE_CONFIG_INFO_COLOR
#define GPIOTE_CONFIG_INFO_COLOR 0
#endif

// <o> GPIOTE_CONFIG_DEBUG_COLOR  - ANSI escape code prefix.

// <0=> Default
// <1=> Black
// <2=> Red
// <3=> Green
// <4=> Yellow
// <5=> Blue
// <6=> Magenta
// <7=> Cyan
// <8=> White

#ifndef GPIOTE_CONFIG_DEBUG_COLOR
#define GPIOTE_CONFIG_DEBUG_COLOR 0
#endif

#endif //GPIOTE_CONFIG_LOG_ENABLED
// </e>

#endif //GPIOTE_ENABLED

// </h>
//==========================================================

// <<< end of configuration section >>>
#endif //SDK_CONFIG_H
