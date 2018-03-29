//
//  CadenceViewController.swift
//  RF1_iOS
//
//  Created by Keegan Jebb on 2018-03-15.
//  Copyright © 2018 Keegan Jebb. All rights reserved.
//

import UIKit
import CoreBluetooth

class CadenceViewController: UIViewController, CadenceMetricsDelegate {
    
    var cadenceBLEManager: BLEManager!
    
    var bleDataProcessor: BLEDataProcessor!
    
    var cadenceMetrics: CadenceMetrics!
    
    var isTimerPaused: Bool = false
    
    @IBOutlet weak var shortCadenceLabel: UILabel!
    @IBOutlet weak var avgCadenceLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var stepsLabel: UILabel!
    
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var pauseButton: UIButton!
    
    @IBOutlet weak var dataLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cadenceMetrics = CadenceMetrics(timeForShortCadenceInSeconds: 20, delegate: self)
        
        bleDataProcessor = BLEDataProcessor(delegate: cadenceMetrics)

        cadenceBLEManager.fsrPeripheral?.delegate = self

        cadenceBLEManager.getNotifications()
        
        updateUI() //To initialize the view to all zeros

    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //MARK: - Modify the UI Methods
    
    //Called when Cadence timer expiers
    func didUpdateCadenceValues() {
        
        updateUI()
    }
    
    
    func updateUI() {
        
        shortCadenceLabel.text = "\(Int(cadenceMetrics.shortCadence.rounded()))"
        avgCadenceLabel.text = "\(Int(cadenceMetrics.averageCadence.rounded()))"
        timeLabel.text = cadenceMetrics.getFormattedTimeString()
        stepsLabel.text = "\(cadenceMetrics.totalSteps)"
    }
    
    
    //MARK: - Pressed button methods
    
    @IBAction func stopButtonPressed(_ sender: UIButton) {
        
        let alert = UIAlertController(title: "Stop Tracking?", message: "Your data will be lost", preferredStyle: .alert)

        let addAction = UIAlertAction(title: "Stop", style: .default) { (addAction) in
            self.cadenceMetrics.runTimer.invalidate()
            self.cadenceBLEManager.turnOffNotifications()
            self.dismiss(animated: true, completion: nil)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        
        alert.addAction(cancelAction)
        alert.addAction(addAction)
        
        alert.preferredAction = alert.actions[1]
        
        present(alert, animated: true, completion: nil)
    }
    
    
    @IBAction func pauseButtonPressed(_ sender: UIButton) {
        
        if isTimerPaused == false {
            
            cadenceMetrics.runTimer.invalidate()
            isTimerPaused = true
            cadenceBLEManager.turnOffNotifications()
            pauseButton.setTitle("Resume", for: .normal)
            
        } else {
            
            cadenceMetrics.initializeTimer()
            isTimerPaused = false
            cadenceBLEManager.getNotifications()
            pauseButton.setTitle("Pause", for: .normal)
        }
    }
    
    
}


//MARK: - Bluetooth Peripheral Delegate Extension Methods

extension CadenceViewController: CBPeripheralDelegate {
    
    func peripheral(
        _ peripheral: CBPeripheral,
        didUpdateValueFor characteristic: CBCharacteristic,
        error: Error?) {
        
        if error != nil {
            print("Error updating value \(error!)")
            dataLabel.text = "Error updating value \(error!)"
            return
        }
        
        if let foundData = characteristic.value {
            
            if characteristic.uuid == PeripheralDevice.fsrDataCharacteristicUUID {
                
                bleDataProcessor.processNewData(updatedData: foundData)
                dataLabel.text = "Forefoot: \(bleDataProcessor.forefootVoltage) Heel: \(bleDataProcessor.heelVoltage)"
                print("\(bleDataProcessor.forefootVoltage) \(bleDataProcessor.heelVoltage)")
            }
        }
    }
    
    
}
