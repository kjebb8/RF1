//
//  CadenceViewController.swift
//  RF1_iOS
//
//  Created by Keegan Jebb on 2018-03-15.
//  Copyright © 2018 Keegan Jebb. All rights reserved.
//

import UIKit
import CoreBluetooth

class CadenceViewController: UIViewController, BLEManagerDelegate, BLEDataProcessorDelegate, CadenceMetricsDelegate {
    
    var cadenceBLEManager: BLEManager!
    
    var bleDataProcessor: BLEDataProcessor!
    
    var cadenceMetrics: CadenceMetrics!
    
    var isTimerPaused: Bool = false
    
    var alert: UIAlertController?
    
    @IBOutlet weak var shortCadenceLabel: UILabel!
    @IBOutlet weak var avgCadenceLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var stepsLabel: UILabel!
    
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var pauseButton: UIButton!
    
    @IBOutlet weak var dataLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pauseButton.setTitleColor(UIColor.darkGray, for: .disabled)
        pauseButton.setTitleColor(UIColor.lightGray, for: .normal)
        
        cadenceMetrics = CadenceMetrics(timeForShortCadenceInSeconds: 20, delegate: self)
        
        bleDataProcessor = BLEDataProcessor(delegate: self)

        cadenceBLEManager.getNotifications()
        
        updateUI() //To initialize the view to all zeros
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        cadenceBLEManager.setDelegate(to: self)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //MARK: - Bluetooth Manager Delegate Methods and Data Processor Call/Callback
    
    func alertForBLEChange(alertMessage: String, askToConnect: Bool) {
        
        var connectAction: UIAlertAction? = nil
        
        if askToConnect {
            
            connectAction = UIAlertAction(title: "Connect", style: .default) { (reconnectAction) in
                self.cadenceBLEManager.startScan()
            }
        }
        
        showAlert(title: "Bluetooth Status", message: alertMessage, extraAlertAction: connectAction)
    }
    
    
    func updateUIForBLEState(_ bleState: BLEState) {
        
        if bleState != .connected {
            
            setPauseState()
            pauseButton.isEnabled = false
            
            if bleState == .notConnected {
                alert?.dismiss(animated: true, completion: nil)
            }
            
        } else {
            
            setRunState()
            pauseButton.isEnabled = true
            alert?.dismiss(animated: true, completion: nil)
        }
    }
    
    
    func didReceiveBLEData(data: Data) {
        
        bleDataProcessor.processNewData(updatedData: data)
        dataLabel.text = "Forefoot: \(bleDataProcessor.forefootVoltage) Heel: \(bleDataProcessor.heelVoltage)"
        print("\(bleDataProcessor.forefootVoltage) \(bleDataProcessor.heelVoltage)")
    }
    
    
    //MARK: - Data Processor Callback
    
    func didFinishDataProcessing(withReturn returnValue: BLEDataProcessorReturn) {
        
        if returnValue == .didTakeStep {
            cadenceMetrics.incrementSteps()
        }
    }
    
    
    //MARK: - Modify the UI Methods
    
    func showAlert(title: String, message: String, extraAlertAction: UIAlertAction? = nil) {
        
        alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        if let extraAction = extraAlertAction {
            let exitAction = UIAlertAction(title: "Exit Tracking", style: .default) { (exitAction) in
                self.dismiss(animated: true, completion: nil)
            }
            alert?.addAction(exitAction)
            alert?.addAction(extraAction)
        } else {
            let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alert?.addAction(okAction)
        }
        present(alert!, animated: true, completion: nil)
    }
    
    
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
    
    
    func setPauseState() {
        
        cadenceMetrics.runTimer.invalidate()
        isTimerPaused = true
        cadenceBLEManager.turnOffNotifications()
        pauseButton.setTitle("Resume", for: .normal)
    }
    
    
    func setRunState() {
        
        cadenceMetrics.initializeTimer()
        isTimerPaused = false
        cadenceBLEManager.getNotifications()
        pauseButton.setTitle("Pause", for: .normal)
    }
    
    
    //MARK: - Pressed button methods
    
    @IBAction func stopButtonPressed(_ sender: UIButton) {
        
        let alert = UIAlertController(title: "Stop Tracking?", message: "Your data will be lost", preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        
        let stopAction = UIAlertAction(title: "Stop Tracking", style: .default) { (addAction) in
            self.cadenceMetrics.runTimer.invalidate()
            self.cadenceBLEManager.turnOffNotifications()
            self.dismiss(animated: true, completion: nil)
        }
        
        alert.addAction(cancelAction)
        alert.addAction(stopAction)
        
        alert.preferredAction = alert.actions[1]
        
        present(alert, animated: true, completion: nil)
    }
    
    
    @IBAction func pauseButtonPressed(_ sender: UIButton) {
        
        if isTimerPaused == false {
            setPauseState()
        } else {
            setRunState()
        }
    }
    
    
}
