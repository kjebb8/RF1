//
//  CadenceViewController.swift
//  RF1_iOS
//
//  Created by Keegan Jebb on 2018-03-15.
//  Copyright © 2018 Keegan Jebb. All rights reserved.
//

import UIKit
import CoreBluetooth

class CadenceViewController: UIViewController {
    
    var cadenceBLEManager: BLEManager!
    
    let bleDataProcessor = BLEDataProcessor()
    
    let cadenceMetrics = CadenceMetrics(timeForShortCadenceInSeconds: 20)
    
    var isTimerPaused: Bool = false
    
    var runTime: Int = 0 //In seconds
    var runTimer = Timer()
    
    @IBOutlet weak var shortCadenceLabel: UILabel!
    @IBOutlet weak var avgCadenceLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var stepsLabel: UILabel!
    
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var pauseButton: UIButton!
    
    @IBOutlet weak var dataLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

//        stopButton.imageView!.contentMode = UIViewContentMode.scaleAspectFit
//        pauseButton.imageView!.contentMode = UIViewContentMode.scaleAspectFit
        
        updateUI()
        
        initializeTimer()
        
        bleDataProcessor.initializeFsrDataArray()

        cadenceBLEManager?.fsrPeripheral?.delegate = self

        cadenceBLEManager?.getNotifications()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //MARK: - Timer Methods
    
    func initializeTimer() {
        
        runTimer = Timer.scheduledTimer(
            timeInterval: 1,
            target: self,
            selector: (#selector(CadenceViewController.updateTimer)),
            userInfo: nil,
            repeats: true)
    }
    
    @objc func updateTimer() {
        
        runTime += 1
        cadenceMetrics.updateCadence(atTimeInMinutes: runTime)
        updateUI()
    }
    
    
    //MARK: - Modify the UI Methods
    
    func updateUI() {
        
        shortCadenceLabel.text = "\(Int(cadenceMetrics.shortCadence.rounded()))"
        avgCadenceLabel.text = "\(Int(cadenceMetrics.averageCadence.rounded()))"
        timeLabel.text = getFormattedTimeString()
        stepsLabel.text = "\(cadenceMetrics.totalSteps)"
    }
    
    func getFormattedTimeString() -> (String) {
        
        if runTime.hours >= 1 {
            return String(format: "%i:%02i:%02i", runTime.hours, runTime.minutes, runTime.seconds)
        } else {
            return String(format: "%i:%02i", runTime.minutes, runTime.seconds)
        }
        
    }
    
    
    //MARK: - Pressed button methods
    
    @IBAction func stopButtonPressed(_ sender: UIButton) {
        
        let alert = UIAlertController(title: "Stop Tracking?", message: "Your data will be lost", preferredStyle: .alert)

        let addAction = UIAlertAction(title: "Stop", style: .default) { (addAction) in
            self.runTimer.invalidate()
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
            runTimer.invalidate()
            isTimerPaused = true
            cadenceBLEManager.turnOffNotifications()
            pauseButton.setTitle("Resume", for: .normal)
        } else {
            initializeTimer()
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
                bleDataProcessor.saveFsrData(updatedData: foundData)
                dataLabel.text = "\(bleDataProcessor.fsrDataArray[0])  \(bleDataProcessor.fsrDataArray[1])"
                
                if bleDataProcessor.fsrDataArray[0] > 1000 {
                    cadenceMetrics.incrementSteps() //Will move
                }
                print(cadenceMetrics.intervalTimeSteps)
            }
        }
    }
    
    
}
