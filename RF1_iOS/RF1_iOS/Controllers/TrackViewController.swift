//
//  CadenceViewController.swift
//  RF1_iOS
//
//  Created by Keegan Jebb on 2018-03-15.
//  Copyright © 2018 Keegan Jebb. All rights reserved.
//

import UIKit
import CoreBluetooth
import RealmSwift

class TrackViewController: UIViewController, BLEManagerDelegate, BLEDataManagerDelegate {
    
    let realm = try! Realm()
    
    var bleManager: BLEManager!
    
    var bleDataManager: BLEDataManager!
    
    var cadenceMetrics = CadenceMetrics()
    
    var isTimerPaused: Bool = false
    
    var localBLEState: BLEState = .connected
    
    var alert: UIAlertController?
    
    var runTime: Int = 0 //In seconds
    var runTimer = Timer()
    
    let date = Date()
    
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
            selector: (#selector(TrackViewController.timerIntervalTick)),
            userInfo: nil,
            repeats: true)
    }
    
    
    @objc func timerIntervalTick() {
        
        runTime += 1
        cadenceMetrics.updateCadence(atTimeInSeconds: runTime)
        updateUICadenceValues()
    }
    
    
    func getFormattedRunTimeString() -> (String) {
        
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
            
            let exitSaveAction = UIAlertAction(title: "Exit and Save", style: .default) { (exitSaveAction) in
                
                self.saveData()
                
                self.dismiss(animated: true, completion: nil)
            }
            
            alert?.addAction(exitSaveAction)
            
            if addReconnectAction {
                
                let reconnectAction = UIAlertAction(title: "Reconnect", style: .default) { (reconnectAction) in
                    self.bleManager.startScan()
                }
                
                alert?.addAction(reconnectAction)
                
            } else {
                
                let continueAction = UIAlertAction(title: "Continue Tracking", style: .cancel) { (continueAction) in
                    
                    if self.localBLEState == .connected { //Protecting against running when BLE turned off
                        self.setRunState()
                    }
                }
                
                alert?.addAction(continueAction)
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
        
        timeLabel.text = getFormattedRunTimeString()
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
    
    
    
    //MARK: - Saving Date Functions
    
    func saveData() {
        
        let newRunLogEntry = RunLogEntry()
        
        newRunLogEntry.date = self.getDateString()
        newRunLogEntry.startTime = self.getStartTimeString()
        newRunLogEntry.runDuration = self.getFormattedRunTimeString()
        
        let newCadenceData = self.cadenceMetrics.getCadenceDataForSaving(forRunTime: self.runTime)
        
        newRunLogEntry.cadenceData = newCadenceData
        
        do {
            try self.realm.write {
                self.realm.add(newRunLogEntry)
            }
        } catch {
            print("Error saving context \(error)")
        }
    }
    
    func getDateString() -> (String) {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        dateFormatter.locale = Locale(identifier: "en_US")
        return dateFormatter.string(from: date)
    }
    
    
    func getStartTimeString() -> (String) {
        
        let formatterTime = DateFormatter()
        formatterTime.dateFormat = "hh:mm a"
        return formatterTime.string(from: date)
    }
    
}
