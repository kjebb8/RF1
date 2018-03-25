//
//  ViewController.swift
//  RF1_iOS
//
//  Created by Keegan Jebb on 2018-03-12.
//  Copyright © 2018 Keegan Jebb. All rights reserved.
//

import UIKit
import CoreBluetooth

class HomeViewController: UIViewController {
    
    var centralManager: CBCentralManager!
    var fsrPeripheral: CBPeripheral?
    var fsrCharacteristic: CBCharacteristic?
    
    var fsrDataArray = [Int16]()
    
    var connectedState: Bool = false
    var scanState: Bool = true
    
    let timerScanInterval:TimeInterval = 5.0
    var scanTimer = Timer()

    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var connectButton: UIButton!
    @IBOutlet weak var statusLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        startButton.imageView!.contentMode = UIViewContentMode.scaleAspectFit
        startButton.isEnabled = false
        startButton.setTitleColor(UIColor.darkGray, for: .disabled)
        startButton.setTitleColor(UIColor.lightGray, for: .normal)
        
        connectButton.setTitleColor(UIColor.darkGray, for: .disabled)
        connectButton.setTitleColor(UIColor.lightGray, for: .normal)
        
        initializeFsrDataArray()
        
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    
    func initializeFsrDataArray() {
        
        for _ in 0..<PeripheralDevice.numberOfSensors {
            fsrDataArray.append(0)
        }
    }
    
    
    func makeScanTimer() {
        
        scanTimer = Timer.scheduledTimer(
            timeInterval: timerScanInterval,
            target: self,
            selector: #selector(HomeViewController.stopScan),
            userInfo: nil,
            repeats: false)
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //MARK: - UI Modification Methods
    
    func showAlert(title: String, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    
    
    @IBAction func connectButtonPressed(_ sender: UIButton) {
        
        if !connectedState {
            startPeripheralScan()
        } else {
   
            //When the button says "Disconnect"
            disconnectPeripheral()
        }
    }
    
    func disconnectPeripheral() {
        
        if let chtx = fsrCharacteristic {
            fsrPeripheral?.setNotifyValue(false, for: chtx)
        }
        centralManager.cancelPeripheralConnection(fsrPeripheral!)
    }
    
    
    func updateForConnectedState() {
        
        print("Connected")
        statusLabel.text = "Connected"
        connectedState = true
        connectButton.isEnabled = true
        connectButton.setTitle("Disconnect", for: .normal)
        startButton.isEnabled = true
    }
    
    
    func updateForUnconnectedState(failedToConnect: Bool = false) {
        
        if scanState == true || connectedState == true || failedToConnect == true {
            
            print("Not Connected")
            fsrPeripheral = nil
            statusLabel.text = "Not Connected"
            connectedState = false
            connectButton.isEnabled = true //Needs to be here if called by the scanTimer
            connectButton.setTitle("Connect", for: .normal)
            startButton.isEnabled = false
        } //else will be in the Bluetooth Off State and want it to stay that way
    }
    
    func updateForBluetoothOff() {
        
        print("Bluetooth Off")
        fsrPeripheral = nil
        statusLabel.text = "Bluetooth Off"
        connectedState = false
        scanState = false
        connectButton.isEnabled = false //Needs to be here if called by the scanTimer
        connectButton.setTitle("Turn On Bluetooth", for: .disabled)
        startButton.isEnabled = false
    }
    
    
    // MARK: - Bluetooth scanning methods
    
    @objc func stopScan() {
        
        centralManager.stopScan()
        
        if scanState { //If the scan timer timed out
            
            print("Didn't Find Device")
            statusLabel.text = "Didn't Find Services"
            showAlert(title: "Scan Failed", message: "Could not find a device")
            updateForUnconnectedState()
        }
    }
    
    @objc func startPeripheralScan() {
        
        print("Scanning...")
        statusLabel.text = "Scanning..."
        scanState = true
        connectButton.isEnabled = false
        connectButton.setTitle("Scanning...", for: .disabled)
        
        makeScanTimer()
        
        centralManager.scanForPeripherals(withServices: [PeripheralDevice.fsrServiceUUID], options: nil)
    }
    
    
    //MARK: - Data Manipulation and Processing Methods
    
    func saveFsrData(updatedData data: Data) {
        
        //1. Get a pointer (ptr) to the data value (size of Int16) in the Data buffer
        //2. Advance the pointer if necessary
        //3. Put the value ptr points to into the appropriate index of fsrDataArray
        for i in 0...(fsrDataArray.count - 1) {
            fsrDataArray[i] = data.withUnsafeBytes { (ptr: UnsafePointer<Int16>) in
                ptr.advanced(by: i).pointee
            }
        }
        print(fsrDataArray)
        statusLabel.text = "\(fsrDataArray[0])  \(fsrDataArray[1])"
    }
    
    
}


//MARK: - Bluetooth Delegate Extension Methods

extension HomeViewController: CBCentralManagerDelegate, CBPeripheralDelegate {
    
    // Invoked when the central manager’s state is updated.
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        var shouldShowAlert = true
        var message = ""
        
        switch central.state {
            
            case .poweredOff:
                message = "Bluetooth on this device is currently powered off."
                updateForBluetoothOff()
            case .unsupported:
                message = "This device does not support Bluetooth Low Energy."
            case .unauthorized:
                message = "This app is not authorized to use Bluetooth Low Energy."
            case .resetting:
                message = "The BLE Manager is resetting; a state update is pending."
            case .unknown:
                message = "The state of the BLE Manager is unknown."
            case .poweredOn:
                shouldShowAlert = false
                message = "Bluetooth LE is turned on and ready for communication."
                print(message)
                startPeripheralScan()
        }
        
        if shouldShowAlert {
            showAlert(title: "Bluetooth State", message: message)
        }
    }

    
    
    func centralManager(
        _ central: CBCentralManager,
        didDiscover peripheral: CBPeripheral,
        advertisementData: [String : Any],
        rssi RSSI: NSNumber) {
        
        if let peripheralName = advertisementData[CBAdvertisementDataLocalNameKey] as? String {
            
            print("Name: \(peripheralName)")
            
            if peripheralName == PeripheralDevice.deviceName {
                
                scanTimer.invalidate()
                scanState = false
                stopScan()
                
                fsrPeripheral = peripheral
                fsrPeripheral!.delegate = self as CBPeripheralDelegate
                
                centralManager.connect(fsrPeripheral!, options: nil)
            }
        }
    }
    
    
    func centralManager(
        _ central: CBCentralManager,
        didConnect peripheral: CBPeripheral) {
        
        updateForConnectedState()
        peripheral.discoverServices([PeripheralDevice.fsrServiceUUID])
    }
    
    
    func centralManager(
        _ central: CBCentralManager,
        didFailToConnect peripheral: CBPeripheral,
        error: Error?) {
        
        if error != nil {
            print("Connection Failed. Error: \(error!)")
            statusLabel.text = "Connection Failed. Error: \(error!)"
        }
        
        updateForUnconnectedState(failedToConnect: true)
    }
    
    
    func centralManager(
        _ central: CBCentralManager,
        didDisconnectPeripheral peripheral: CBPeripheral,
        error: Error?) {
        
        updateForUnconnectedState()
        
        if error != nil {
            print("Disconnected. Error: \(error!)")
            statusLabel.text = "Disconnected. Error: \(error!)"
        }
    }
    
    
    //MARK: - Bluetooth CBPeripheral Delegate Methods
    
    func peripheral(
        _ peripheral: CBPeripheral,
        didDiscoverServices error: Error?) {
        
        if error != nil {
            print("Error discovering services \(error!)")
            statusLabel.text = "Error discovering services \(error!)"
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
    
    
    func peripheral(
        _ peripheral: CBPeripheral,
        didDiscoverCharacteristicsFor service: CBService,
        error: Error?) {
        
        if error != nil {
            print("Error discovering characteristics \(error!)")
            statusLabel.text = "Error discovering characteristics \(error!)"
            return
        }
     
        if let foundCharacteristics = service.characteristics {
            
            for characteristic in foundCharacteristics {
                
                if characteristic.uuid == PeripheralDevice.fsrDataCharacteristicUUID {
                    
                    fsrCharacteristic = characteristic
                    fsrPeripheral?.setNotifyValue(true, for: fsrCharacteristic!)
                }
            }
        }
    }
    
    
    func peripheral(
        _ peripheral: CBPeripheral,
        didUpdateValueFor characteristic: CBCharacteristic,
        error: Error?) {
        
        if error != nil {
            print("Error updating value \(error!)")
            statusLabel.text = "Error updating value \(error!)"
            return
        }
        
        if let foundData = characteristic.value {
        
            if characteristic.uuid == PeripheralDevice.fsrDataCharacteristicUUID {
                saveFsrData(updatedData: foundData)
            }
        }
    }
    

}

