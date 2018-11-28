# RF1
- Project for wearable device and iOS app that tracks running data including cadence and footstrike
- The data collected from the device helps runners track their technique in real time and make adjustments to improve their energy efficiency and reduce risk of injury
- Wearable consists of 2 force sensing resistors (FSR) and Bluetooth microcontroller. The FSRs are placed under the forefoot and heel while the microcontroller is strapped around the ankle
-The project contains the following two applications:
1. Firmware for Nordic Semiconductor nRF52832 to read FSR circuit resistance and send data with Bluetooth Low Energy to a connected device
2. iOS application to read FSR values, in parallel with other run tracking activites, to determine run time, steps, cadence, and footstrike and store data for finished runs with Realm
