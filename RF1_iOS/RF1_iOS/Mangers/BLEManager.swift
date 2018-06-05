//
//  BLEManager.swift
//  RF1_iOS
//
//  Created by Keegan Jebb on 2018-03-27.
//  Copyright © 2018 Keegan Jebb. All rights reserved.
//

import Foundation
import CoreBluetooth

protocol BLEManagerDelegate {
    func updateForBLEEvent(_ bleEvent: BLEEvent)
    func updateUIForBLEState(_ bleState: BLEState)
    func didReceiveBLEData(data: Data)
}


class BLEManager: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    private var centralManager: CBCentralManager!
    private var fsrPeripheral: CBPeripheral?
    private var fsrCharacteristic: CBCharacteristic?
    
    private let timerScanInterval:TimeInterval = 5.0
    private var scanTimer = Timer()
    
    private var bleState: BLEState = .notConnected
    
    private var delegateVC: BLEManagerDelegate?
    
    override init() {
        
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    
    private func makeScanTimer() {
        
        scanTimer = Timer.scheduledTimer(
            timeInterval: timerScanInterval,
            target: self,
            selector: #selector(BLEManager.scanTimedOut),
            userInfo: nil,
            repeats: false)
    }
    
    
    //MARK: - Bluetooth Public Methods
    
    func setDelegate(to delegate: BLEManagerDelegate) {
        
        delegateVC = delegate
        delegateVC?.updateUIForBLEState(bleState)
    }
    
    
    func startScan() {
        
        makeScanTimer()
        centralManager.scanForPeripherals(withServices: [PeripheralDevice.fsrServiceUUID], options: nil)
        bleState = .scanning
        delegateVC?.updateUIForBLEState(bleState)
        delegateVC?.updateForBLEEvent(.scanStarted)
    }
    
    
    @objc func scanTimedOut() {
        
        centralManager.stopScan()
        print("Didn't Find Device")
        bleState = .notConnected
        delegateVC?.updateUIForBLEState(bleState)
        delegateVC?.updateForBLEEvent(.scanTimeOut)
    }
    
    
    func disconnectPeripheral() {
        
        turnOffNotifications()
        
        if let peripheral = fsrPeripheral {
            centralManager.cancelPeripheralConnection(peripheral)
        }
    }
    
    
    func turnOnNotifications() {
        
        if let characteristic = fsrCharacteristic {
            fsrPeripheral?.setNotifyValue(true, for: characteristic)
        }
    }
    
    
    func turnOffNotifications() {
        
        if let characteristic = fsrCharacteristic {
            fsrPeripheral?.setNotifyValue(false, for: characteristic)
        }
    }
    
    
    //MARK: - Bluetooth Central Manager Delegate Internal Methods
    
    internal func centralManagerDidUpdateState(_ central: CBCentralManager) {
            
        if central.state == .poweredOff {
            
            scanTimer.invalidate()
            fsrPeripheral = nil
            bleState = .bleOff
            delegateVC?.updateUIForBLEState(bleState)
            delegateVC?.updateForBLEEvent(.bleTurnedOff)
            
        } else if central.state == .poweredOn {
            
            delegateVC?.updateForBLEEvent(.bleTurnedOn)
            return
            
        } else {
            
            //If unsupported, unauthorized, resetting, unknown
            bleState = .bleUnavailable
            delegateVC?.updateUIForBLEState(bleState)
        }
    }
    
    
    internal func centralManager(
        _ central: CBCentralManager,
        didDiscover peripheral: CBPeripheral,
        advertisementData: [String : Any],
        rssi RSSI: NSNumber) {
        
        if let peripheralName = advertisementData[CBAdvertisementDataLocalNameKey] as? String {
            
            print("Name: \(peripheralName)")
            
            if peripheralName == PeripheralDevice.deviceName {
                
                centralManager.stopScan()
                
                fsrPeripheral = peripheral
                fsrPeripheral!.delegate = self as CBPeripheralDelegate
                
                centralManager.connect(fsrPeripheral!, options: nil)
            }
        }
    }
    
    
    internal func centralManager(
        _ central: CBCentralManager,
        didConnect peripheral: CBPeripheral) {
        
        scanTimer.invalidate()
        peripheral.discoverServices([PeripheralDevice.fsrServiceUUID])
    }
    
    
    internal func centralManager(
        _ central: CBCentralManager,
        didFailToConnect peripheral: CBPeripheral,
        error: Error?) {
        
        scanTimer.invalidate()
        fsrPeripheral = nil
        bleState = .notConnected
        delegateVC?.updateUIForBLEState(bleState)
        
        if error != nil {
            
            print("Connection Failed. Error: \(error!)")
            delegateVC?.updateForBLEEvent(.failedToConnect)
        }
    }
    
    
    internal func centralManager(
        _ central: CBCentralManager,
        didDisconnectPeripheral peripheral: CBPeripheral,
        error: Error?) {
        
        fsrPeripheral = nil
        bleState = .notConnected
        delegateVC?.updateUIForBLEState(bleState)
        
        if error != nil {
            
            print("Disconnected. Error: \(error!)")
            delegateVC?.updateForBLEEvent(.disconnected)
        }
    }
    
    
    //MARK: - Bluetooth Peripheral Delegate Internal Methods
    
    internal func peripheral(
        _ peripheral: CBPeripheral,
        didDiscoverServices error: Error?) {
        
        if error != nil {
            print("Error discovering services \(error!)")
            return
        }
        
        if let foundServices = peripheral.services {
            
            for service in foundServices {
                
                if service.uuid == PeripheralDevice.fsrServiceUUID {
                    
                    peripheral.discoverCharacteristics(nil, for: service)
                }
            }
        }
    }
    
    
    internal func peripheral(
        _ peripheral: CBPeripheral,
        didDiscoverCharacteristicsFor service: CBService,
        error: Error?) {
        
        if error != nil {
            print("Error discovering characteristics \(error!)")
            return
        }
        
        if let foundCharacteristics = service.characteristics {
            
            for characteristic in foundCharacteristics {
                
                if characteristic.uuid == PeripheralDevice.fsrDataCharacteristicUUID {
                    
                    fsrCharacteristic = characteristic
                    
                    bleState = .connected
                    delegateVC?.updateUIForBLEState(bleState)
                }
            }
        }
    }
    
        
    internal func peripheral(
        _ peripheral: CBPeripheral,
        didUpdateValueFor characteristic: CBCharacteristic,
        error: Error?) {
        
        if error != nil {
            print("Error updating value \(error!)")
            return
        }
        
        if let foundData = characteristic.value {
            
            if characteristic.uuid == PeripheralDevice.fsrDataCharacteristicUUID {
                
                delegateVC?.didReceiveBLEData(data: foundData)
            }
        }
    }
    
    
}
