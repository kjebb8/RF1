//
//  BLEManager.swift
//  RF1_iOS
//
//  Created by Keegan Jebb on 2018-03-27.
//  Copyright © 2018 Keegan Jebb. All rights reserved.
//

import Foundation
import CoreBluetooth

class BLEManager {
    
    var centralManager: CBCentralManager!
    var fsrPeripheral: CBPeripheral?
    var fsrCharacteristic: CBCharacteristic?
    
    
    func disconnectPeripheral() {
        
        turnOffNotifications()
       
        centralManager.cancelPeripheralConnection(fsrPeripheral!)
    }
    
    
    func getNotifications() {
        
        if let characteristic = fsrCharacteristic {
            fsrPeripheral?.setNotifyValue(true, for: characteristic)
        }
    }
    
    
    func turnOffNotifications() {
        
        if let characteristic = fsrCharacteristic {
            fsrPeripheral?.setNotifyValue(false, for: characteristic)
        }
    }
    
    
}
