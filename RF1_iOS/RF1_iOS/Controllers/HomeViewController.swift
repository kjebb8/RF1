//
//  ViewController.swift
//  RF1_iOS
//
//  Created by Keegan Jebb on 2018-03-12.
//  Copyright © 2018 Keegan Jebb. All rights reserved.
//

import UIKit
import CoreBluetooth

class HomeViewController: BaseViewController, BLEManagerDelegate {
    
    var bleManager: BLEManager!

    @IBOutlet weak var statusButton: UIButton!
    @IBOutlet weak var startButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bleManager = BLEManager()
        print("New BLE Manger")
        
        statusButton.setTitleColor(UIColor.darkGray, for: .disabled)
        statusButton.setTitleColor(UIColor.white, for: .normal)
        
        startButton.setTitleColor(UIColor.darkGray, for: .disabled)
        startButton.setTitleColor(UIColor.white, for: .normal)
    }
    
    
    override func viewDidAppear(_ animated: Bool) { //Called every time the view is displayed
        bleManager.setDelegate(to: self)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //MARK: - UI Modification Methods
    
    func updateForScanningState() {
        
        print("Scanning...")
        statusButton.isEnabled = false
        statusButton.setTitle("Scanning...", for: .disabled)
        startButton.isEnabled = false
    }
    
    
    func updateForConnectedState() {
        
        print("Connected!")
        statusButton.isEnabled = false
        statusButton.setTitle("Connected!", for: .disabled)
        startButton.isEnabled = true
    }
    
    
    func updateForNotConnectedState() {
            
        print("Not Connected")
        statusButton.isEnabled = true
        statusButton.setTitle("Connect", for: .normal)
        startButton.isEnabled = false
    }
    
    
    func updateForBLEOff() {
        
        print("Bluetooth Off")
        statusButton.isEnabled = false
        statusButton.setTitle("Turn On Bluetooth", for: .disabled)
        startButton.isEnabled = false
    }
    
    
    func updateForBLEUnavailable() {
        
        print("Bluetooth Unavailable")
        statusButton.isEnabled = false
        statusButton.setTitle("Bluetooth Unavailable", for: .disabled)
        startButton.isEnabled = false
    }
    
    
    //MARK: - Bluetooth Manager Delegate Methods
    
    func updateForBLEEvent(_ bleEvent: BLEEvent) {
        
        switch bleEvent {
            
        case .scanStarted:
            return
            
        case .scanTimeOut:
            showAlert(title: "No Device Found", message: "Make sure device is on and try again")
            
        case .failedToConnect:
            showAlert(title: "Failed to Connect", message: "Make sure device is on and try again")
        
        case .disconnected:
            showAlert(title: "Disconnected from Device", message: "Please reconnect to start tracking")
        
        case .bleTurnedOff:
            showAlert(title: "Bluetooth Turned Off", message: "Please enable Bluetooth to proceed")
            
        case .bleTurnedOn:
            updateForNotConnectedState()
        }
    }
    
    
    func updateUIForBLEState(_ bleState: BLEState) {
        
        switch bleState {
        
        case .scanning:
            updateForScanningState()
        
        case .connected:
            updateForConnectedState()
            
        case .notConnected:
            updateForNotConnectedState()
            
        case .bleOff:
            updateForBLEOff()
            
        case .bleUnavailable:
            updateForBLEUnavailable()
        }
    }
    
    
    func didReceiveBLEData(data: Data) {
        self.bleManager.turnOffNotifications() //Don't want notifications on the home screen
    }
    
    
    //MARK: - Button Pressed Methods
    
    @IBAction func statusButtonPressed(_ sender: UIButton) {
        bleManager.startScan() //Only enabled when ready to connect
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToCadence" {
            let destinationVC = segue.destination as! TrackViewController
            destinationVC.bleManager = bleManager
        }
    }
    
    
}

