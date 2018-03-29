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
    
    var homeBLEManager: BLEManager!
    
    var connectedState: Bool = false
    var scanState: Bool = true
    
    let timerScanInterval:TimeInterval = 5.0
    var scanTimer = Timer()

    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var connectButton: UIButton!
    @IBOutlet weak var statusLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //startButton.isEnabled = false
        startButton.setTitleColor(UIColor.darkGray, for: .disabled)
        startButton.setTitleColor(UIColor.white, for: .normal)
        
        connectButton.setTitleColor(UIColor.darkGray, for: .disabled)
        connectButton.setTitleColor(UIColor.white, for: .normal)
        
        homeBLEManager.centralManager = CBCentralManager(delegate: self, queue: nil)
//        centralManager = CBCentralManager(delegate: self, queue: nil, options: [CBCentralManagerOptionRestoreIdentifierKey : Device.restoreIdentifier])
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        homeBLEManager.fsrPeripheral?.delegate = self
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
            homeBLEManager.disconnectPeripheral()
        }
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
            homeBLEManager.fsrPeripheral = nil
            statusLabel.text = "Not Connected"
            connectedState = false
            connectButton.isEnabled = true //Needs to be here if called by the scanTimer
            connectButton.setTitle("Connect", for: .normal)
            startButton.isEnabled = false
        } //else will be in the Bluetooth Off State and want it to stay that way
    }
    
    func updateForBluetoothOff() {
        
        print("Bluetooth Off")
        homeBLEManager.fsrPeripheral = nil
        statusLabel.text = "Bluetooth Off"
        connectedState = false
        scanState = false
        connectButton.isEnabled = false //Needs to be here if called by the scanTimer
        connectButton.setTitle("Turn On Bluetooth", for: .disabled)
        startButton.isEnabled = false
    }
    
    
    // MARK: - Bluetooth scanning methods
    
    @objc func stopScan() {
        
        homeBLEManager.centralManager.stopScan()
        
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
        
        homeBLEManager.centralManager.scanForPeripherals(withServices: [PeripheralDevice.fsrServiceUUID], options: nil)
    }
    
    
    //MARK: - Prepare for Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToCadence" {
            let destinationVC = segue.destination as! CadenceViewController
            destinationVC.cadenceBLEManager = homeBLEManager
        }
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
                
                homeBLEManager.fsrPeripheral = peripheral
                homeBLEManager.fsrPeripheral!.delegate = self as CBPeripheralDelegate
                
                homeBLEManager.centralManager.connect(homeBLEManager.fsrPeripheral!, options: nil)
            }
        }
    }
    
    
    func centralManager(
        _ central: CBCentralManager,
        didConnect peripheral: CBPeripheral) {

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
                    
                    homeBLEManager.fsrCharacteristic = characteristic
                    
                    updateForConnectedState()
                }
            }
        }
    }
    

}

