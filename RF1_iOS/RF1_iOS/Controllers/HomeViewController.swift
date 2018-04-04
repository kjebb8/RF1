//
//  ViewController.swift
//  RF1_iOS
//
//  Created by Keegan Jebb on 2018-03-12.
//  Copyright © 2018 Keegan Jebb. All rights reserved.
//

import UIKit
import CoreBluetooth

class HomeViewController: UIViewController, BLEManagerDelegate {
    
    var homeBLEManager: BLEManager!
    
    var homeBLEState: BLEState = .notConnected
    
    var alert: UIAlertController?

    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var statusLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        startButton.setTitleColor(UIColor.darkGray, for: .disabled)
        startButton.setTitleColor(UIColor.white, for: .normal)
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        homeBLEManager.setDelegate(to: self)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //MARK: - UI Modification Methods
    
    func showAlert(title: String, message: String, extraAlertAction: UIAlertAction? = nil) {
        
        alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        if let extraAction = extraAlertAction {
            alert?.addAction(extraAction)
        } else {
            let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alert?.addAction(okAction)
        }
        present(alert!, animated: true, completion: nil)
    }
    
    
    func updateForScanningState() {
        
        print("Scanning...")
        statusLabel.text = "Scanning..."
        startButton.isEnabled = false
    }
    
    
    func updateForConnectedState() {
        
        print("Connected")
        alert?.dismiss(animated: true, completion: nil)
        statusLabel.text = "Connected"
        startButton.isEnabled = true
    }
    
    
    func updateForNotConnectedState() {
            
        print("Not Connected")
        alert?.dismiss(animated: true, completion: nil)
        statusLabel.text = "Not Connected"
        startButton.isEnabled = false
    }
    
    
    func updateForBLEOff() {
        
        print("Bluetooth Off")
        statusLabel.text = "Bluetooth Off"
        startButton.isEnabled = false
    }
    
    
    //MARK: - Bluetooth Manager Delegate Methods
    
    func alertForBLEChange(alertMessage: String, askToConnect: Bool) {
    
        var connectAction: UIAlertAction? = nil
        
        if askToConnect {

            connectAction = UIAlertAction(title: "Connect", style: .default) { (reconnectAction) in
                self.homeBLEManager.startScan()
            }
        }
        
        showAlert(title: "Bluetooth Status", message: alertMessage, extraAlertAction: connectAction)
    }
    
    
    func updateUIForBLEState(_ bleState: BLEState) {
        
        homeBLEState = bleState
        
        switch homeBLEState {
        
        case .scanning:
            updateForScanningState()
        
        case .connected:
            updateForConnectedState()
            
        case .notConnected:
            updateForNotConnectedState()
            
        case .bleOff:
            updateForBLEOff()
            
        case .finishedScan:
            //Do Nothing
            return
        }
    }
    
    
    func didReceiveBLEData(data: Data) {
        self.homeBLEManager.turnOffNotifications()
    }
    
    
    //MARK: - Button Pressed Methods
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToCadence" {
            let destinationVC = segue.destination as! CadenceViewController
            destinationVC.cadenceBLEManager = homeBLEManager
        }
    }
    

}

