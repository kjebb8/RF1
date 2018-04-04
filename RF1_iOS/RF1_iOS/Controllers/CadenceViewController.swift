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
    
    var localBLEState: BLEState = .connected
    
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
        
        bleDataProcessor = BLEDataProcessor(delegate: self)
        
        cadenceMetrics = CadenceMetrics(timeForShortCadenceInSeconds: 20, delegate: self) //Automatically calls back with zeroed cadence data
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        cadenceBLEManager.setDelegate(to: self) //This calls back with .connected state, which calls setRunState()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //MARK: - UI Modification Methods
    
    func showAlert(title: String, message: String, addExitAction: Bool = false, addReconnectAction: Bool = false) {
        
        alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        if addExitAction {
            
            let exitAction = UIAlertAction(title: "Exit Tracking", style: .default) { (exitAction) in
                self.dismiss(animated: true, completion: nil)
            }
            
            alert?.addAction(exitAction)
            
            if addReconnectAction {
                
                let reconnectAction = UIAlertAction(title: "Reconnect", style: .default) { (exitAction) in
                    self.cadenceBLEManager.startScan()
                }
                
                alert?.addAction(reconnectAction)
                
            } else {
                
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (cancelAction) in
                    
                    if self.localBLEState == .connected { //Protecting against running when BLE turned off
                        self.setRunState()
                    }
                }
                
                alert?.addAction(cancelAction)
            }
            
        } else {
            
            if localBLEState != .scanning { //If scanning, don't want to be able to dismiss the alert
                
                let okAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
                alert?.addAction(okAction)
            }
        }
        
        present(alert!, animated: true, completion: nil)
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
    
    
    //MARK: - Data Processor Callback
    
    func didFinishDataProcessing(withReturn returnValue: BLEDataProcessorReturn) {
        
        if returnValue == .didTakeStep {
            cadenceMetrics.incrementSteps()
        }
    }
    
    
    //MARK: - Cadence Metrics Callback

    func didUpdateCadenceValues(with cadenceStringValues: CadenceStringValues) { //Called when initialized, when runTimer expiers or when step is taken

        shortCadenceLabel.text = cadenceStringValues.shortCadenceString
        avgCadenceLabel.text = cadenceStringValues.averageCadenceString
        timeLabel.text = cadenceStringValues.timeString
        stepsLabel.text = cadenceStringValues.stepsString
    }
    
    
    //MARK: - Bluetooth Manager Delegate Methods
    
    func updateForBLEEvent(_ bleEvent: BLEEvent) {

        alert?.dismiss(animated: true, completion: nil) //Make sure the new alert is shown

        switch bleEvent {
            
        case .scanStarted:
            showAlert(title: "Scanning", message: "Scanning for nearby device")
        
        case .scanTimeOut:
            showAlert(title: "No Device Found", message: "Make sure device is on and try again", addExitAction: true, addReconnectAction: true)
            
        case .failedToConnect:
            showAlert(title: "Failed to Connect", message: "Make sure device is on and try again", addExitAction: true, addReconnectAction: true)
            
        case .disconnected:
            cadenceBLEManager.startScan()
            
        case .bleTurnedOff:
            showAlert(title: "Bluetooth Turned Off", message: "Please enable Bluetooth to proceed")
        }
    }
    
    
    func updateUIForBLEState(_ bleState: BLEState) {
        
        localBLEState = bleState
        
        switch localBLEState {
            
        case .scanning:
            break
            
        case .connected:
            setRunState()
            pauseButton.isEnabled = true
            alert?.dismiss(animated: true, completion: nil)
            return
            
        case .notConnected:
            break
            
        case .bleOff, .bleUnavailable:
            break
        }
        
        setPauseState()
        pauseButton.isEnabled = false
    }
    
    
    func didReceiveBLEData(data: Data) {
        
        bleDataProcessor.processNewData(updatedData: data)
        dataLabel.text = "Forefoot: \(bleDataProcessor.forefootVoltage) Heel: \(bleDataProcessor.heelVoltage)"
        print("\(bleDataProcessor.forefootVoltage) \(bleDataProcessor.heelVoltage)")
    }
    
    
    //MARK: - Button Pressed Methods
    
    @IBAction func stopButtonPressed(_ sender: UIButton) {
        
        setPauseState()
        showAlert(title: "Stop Tracking?", message: "Your data will be lost", addExitAction: true)
    }
    
    
    @IBAction func pauseButtonPressed(_ sender: UIButton) {
        
        if isTimerPaused == false {
            setPauseState()
        } else {
            setRunState()
        }
    }
    
    
}
