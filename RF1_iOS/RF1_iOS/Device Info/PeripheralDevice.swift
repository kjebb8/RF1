//
//  PeripheralDevice.swift
//  RF1_iOS
//
//  Created by Keegan Jebb on 2018-03-21.
//  Copyright © 2018 Keegan Jebb. All rights reserved.
//

import Foundation
import CoreBluetooth

struct PeripheralDevice {
    
    static let deviceName: String = "FSR_APP"
    
    static let fsrServiceUUID = CBUUID(string: "6c1b0001-4e01-8b6f-9a30-4ab6f2d2937c")
    static let fsrDataCharacteristicUUID = CBUUID(string: "6c1b0002-4e01-8b6f-9a30-4ab6f2d2937c")
    
    static let numberOfSensors: Int = 2
    
    static let samplePeriod: Double = 0.05 //20 Hz on the hardware
}
