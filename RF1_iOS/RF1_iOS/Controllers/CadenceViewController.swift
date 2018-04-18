//
//  CadenceViewController.swift
//  RF1_iOS
//
//  Created by Keegan Jebb on 2018-03-15.
//  Copyright © 2018 Keegan Jebb. All rights reserved.
//

import UIKit
import CoreBluetooth

class CadenceViewController: UIViewController, BLEManagerDelegate, BLEDataManagerDelegate {
    
    var bleManager: BLEManager!
    
    var bleDataManager: BLEDataManager!
    
    var cadenceMetrics = CadenceMetrics(timeForShortCadenceInSeconds: 20)
    
    var isTimerPaused: Bool = false
    
    var localBLEState: BLEState = .connected
    
    var alert: UIAlertController?
    
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
        
        pauseButton.setTitleColor(UIColor.darkGray, for: .disabled)
        pauseButton.setTitleColor(UIColor.lightGray, for: .normal)
        
        bleDataManager = BLEDataManager(delegate: self)
        
        updateUICadenceValues()
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        bleManager.setDelegate(to: self) //This calls back with .connected state, which calls setRunState()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //MARK: - Timer Methods
    
    func initializeTimer() {
        
        runTimer = Timer.scheduledTimer(
            timeInterval: 1, //Goes off every second
            target: self,
            selector: (#selector(CadenceViewController.timerIntervalTick)),
            userInfo: nil,
            repeats: true)
    }
    
    
    @objc func timerIntervalTick() {
        
        runTime += 1
        cadenceMetrics.updateCadence(atTimeInMinutes: runTime)
        updateUICadenceValues()
    }
    
    
    func getFormattedTimeString() -> (String) {
        
        if runTime.hours >= 1 {
            return String(format: "%i:%02i:%02i", runTime.hours, runTime.minutes, runTime.seconds)
        } else {
            return String(format: "%i:%02i", runTime.minutes, runTime.seconds)
        }
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
                    self.bleManager.startScan()
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
        
        runTimer.invalidate()
        isTimerPaused = true
        bleManager.turnOffNotifications()
        pauseButton.setTitle("Resume", for: .normal)
    }
    
    
    func setRunState() {
        
        initializeTimer()
        isTimerPaused = false
        bleManager.getNotifications()
        pauseButton.setTitle("Pause", for: .normal)
    }
    
    
    func updateUICadenceValues() {
        
        let cadenceStringValues = cadenceMetrics.getCadenceStringValues()
        
        shortCadenceLabel.text = cadenceStringValues.shortCadenceString
        avgCadenceLabel.text = cadenceStringValues.averageCadenceString
        stepsLabel.text = cadenceStringValues.stepsString
        
        timeLabel.text = getFormattedTimeString()
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
            bleManager.startScan()
            
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
        
        bleDataManager.processNewData(updatedData: data)
        dataLabel.text = "Forefoot: \(bleDataManager.forefootVoltage) Heel: \(bleDataManager.heelVoltage)"
        print("\(bleDataManager.forefootVoltage) \(bleDataManager.heelVoltage)")
    }
    
    
    //MARK: - Data Manager Callback
    
    func didFinishDataProcessing(withReturn returnValue: BLEDataManagerReturn) {
        
        if returnValue == .didTakeStep {
            cadenceMetrics.incrementSteps()
            updateUICadenceValues()
        }
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
