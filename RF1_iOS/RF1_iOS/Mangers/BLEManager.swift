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
    func alertForBLEChange(alertMessage: String, askToConnect: Bool)
    func updateUIForBLEState(_ bleState: BLEState)
    func didReceiveBLEData(data: Data)
}


enum BLEState {

    case scanning
    case connected
    case notConnected
    case bleOff
    case finishedScan
}


class BLEManager: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    private var centralManager: CBCentralManager!
    private var fsrPeripheral: CBPeripheral?
    private var fsrCharacteristic: CBCharacteristic?
    
    private let timerScanInterval:TimeInterval = 5.0
    private var scanTimer = Timer()
    
    private var isAppInit = false
    
    var bleState: BLEState = .notConnected
    
    private var delegateVC: BLEManagerDelegate?
    
    override init() {
        
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    private func makeScanTimer() {
        
        scanTimer = Timer.scheduledTimer(
            timeInterval: timerScanInterval,
            target: self,
            selector: #selector(BLEManager.stopScan),
            userInfo: nil,
            repeats: false)
    }

    
    private func sendAlertToUI() {
        
        switch bleState {
       
        case .scanning:
            delegateVC?.alertForBLEChange(alertMessage: "Scanning", askToConnect: false)
        
        case .connected:
            return
            
        case .notConnected:
             delegateVC?.alertForBLEChange(alertMessage: "Not Connected to Device", askToConnect: true)
            
        case .bleOff:
            delegateVC?.alertForBLEChange(alertMessage: "Bluetooth is Turned Off", askToConnect: false)
            
        case .finishedScan:
            return
        }
    }
    
    
    //MARK: - Bluetooth Public Methods
    
    func setDelegate(to delegate: BLEManagerDelegate) {
        delegateVC = delegate
        
        if isAppInit {
            
            if bleState == .notConnected {
                startScan()
            } else {
                delegateVC?.updateUIForBLEState(bleState)
                sendAlertToUI()
            }
        }
    }
    
    
    func startScan() {
        
        makeScanTimer()
        centralManager.scanForPeripherals(withServices: [PeripheralDevice.fsrServiceUUID], options: nil)
        bleState = .scanning
        delegateVC?.updateUIForBLEState(bleState)
        sendAlertToUI()
    }
    
    
    @objc func stopScan() {
        
        centralManager.stopScan()
        
        if bleState == .scanning {
            print("Didn't Find Device")
            bleState = .notConnected
            delegateVC?.updateUIForBLEState(bleState)
            sendAlertToUI()
        }
    }
    
    
    func disconnectPeripheral() {
        
        turnOffNotifications()
        
        if let peripheral = fsrPeripheral {
            centralManager.cancelPeripheralConnection(peripheral)
        }
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
    
    
    //MARK: - Bluetooth Central Internal Methods
    
    internal func centralManagerDidUpdateState(_ central: CBCentralManager) {
        
        isAppInit = true
        
        var stateMessage = ""
        
        switch central.state {
            
        case .poweredOff:
            stateMessage = "Bluetooth on this device is currently powered off."
            scanTimer.invalidate()
            fsrPeripheral = nil
            bleState = .bleOff
            delegateVC?.updateUIForBLEState(bleState)
            sendAlertToUI()
            return
            
        case .unsupported:
            stateMessage = "This device does not support Bluetooth Low Energy."
        
        case .unauthorized:
            stateMessage = "This app is not authorized to use Bluetooth Low Energy."
        
        case .resetting:
            stateMessage = "The BLE Manager is resetting; a state update is pending."
       
        case .unknown:
            stateMessage = "The state of the BLE Manager is unknown."
       
        case .poweredOn:
            startScan()
            return
        }

        delegateVC?.alertForBLEChange(alertMessage: stateMessage, askToConnect: false)
    }
    
    
    internal func centralManager(
        _ central: CBCentralManager,
        didDiscover peripheral: CBPeripheral,
        advertisementData: [String : Any],
        rssi RSSI: NSNumber) {
        
        if let peripheralName = advertisementData[CBAdvertisementDataLocalNameKey] as? String {
            
            print("Name: \(peripheralName)")
            
            if peripheralName == PeripheralDevice.deviceName {
                
                bleState = .finishedScan
                scanTimer.invalidate()
                stopScan()
                
                fsrPeripheral = peripheral
                fsrPeripheral!.delegate = self as CBPeripheralDelegate
                
                centralManager.connect(fsrPeripheral!, options: nil)
            }
        }
    }
    
    
    internal func centralManager(
        _ central: CBCentralManager,
        didConnect peripheral: CBPeripheral) {
        
        peripheral.discoverServices([PeripheralDevice.fsrServiceUUID])
    }
    
    
    internal func centralManager(
        _ central: CBCentralManager,
        didFailToConnect peripheral: CBPeripheral,
        error: Error?) {
        
        fsrPeripheral = nil
        bleState = .notConnected
        delegateVC?.updateUIForBLEState(bleState)
        
        if error != nil {
            print("Connection Failed. Error: \(error!)")
            sendAlertToUI()
//            delegateVC?.alertForBLEChange(alertMessage: "Failed to connect", askToConnect: true )
        }
    }
    
    
    internal func centralManager(
        _ central: CBCentralManager,
        didDisconnectPeripheral peripheral: CBPeripheral,
        error: Error?) {
        
        fsrPeripheral = nil
        
        startScan()
//        bleState = .notConnected
//        delegateVC?.updateUIForBLEState(bleState)
        
        if error != nil {
            print("Disconnected. Error: \(error!)")
//            sendAlertToUI()
//            delegateVC?.alertForBLEChange(alertMessage: "Wearable has disconnected. Please reconnect", askToConnect: true)
        }
    }
    
    
    //MARK: - Bluetooth Central Internal Methods
    
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
