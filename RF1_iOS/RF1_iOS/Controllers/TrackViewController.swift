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

class TrackViewController: BaseViewController, BLEManagerDelegate, BLEDataManagerDelegate {
    
    var bleManager: BLEManager! //Handles the BLE connection and reports back with events or changes in state
    
    var bleDataManager: BLEDataManager! //Handles the incoming BLE notification data and reports back with run-related events
    
    var cadenceMetrics = CadenceMetrics() //Holds the properties and mehtods used to track user's cadence
    
    var inRunState: Bool = false //Reflects whether notifications are being recieved from the peripheral
    
    var timePausedInRunState: Bool = false //Reflects whether the timer should stop automatically because the user stopped moving but notifications are still on to see when they begin running again
    
    var localBLEState: BLEState = .connected //Keeps the BLE state so it can be used anywhere in the class
    
    var alert: UIAlertController?
    
    var runTime: Int = 0 //In seconds
    var runTimer = Timer()
    
    var runStopTimeInterval = 0.5
    var runStopTimer = Timer() //Used to determine if the user stops moving to turn off the runTimer (makes sure cadence data is clean)
    
    let date = Date()
    
    @IBOutlet weak var recentCadenceTitle: UILabel!
    @IBOutlet weak var recentCadenceLabel: UILabel!
    @IBOutlet weak var avgCadenceLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var stepsLabel: UILabel!
    
    @IBOutlet weak var pauseButton: UIButton!
    
    @IBOutlet weak var hintLabel: UILabel!
    @IBOutlet weak var dataLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pauseButton.setTitleColor(UIColor.darkGray, for: .disabled)
        pauseButton.setTitleColor(UIColor.lightGray, for: .normal)
        
        bleManager.setDelegate(to: self)
        
        bleDataManager = BLEDataManager(delegate: self)
        
        recentCadenceTitle.text = "\(CadenceParameters.recentCadenceTime)s Cadence"
        hintLabel.text = ""
        
        updateUICadenceValues()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //MARK: - Timer Methods
    
    func initializeRunTimer() {
        
        runTimer = Timer.scheduledTimer(
            timeInterval: 1, //Goes off every second
            target: self,
            selector: (#selector(TrackViewController.runTimerIntervalTick)),
            userInfo: nil,
            repeats: true)
    }
    
    
    func initializeRunStopTimer() {
        
        runStopTimer = Timer.scheduledTimer(
            timeInterval: runStopTimeInterval, //Interval time is 0.5s when the view loads or when setRunState is called. While running, the interval is 1.4s. If a step is taken before 0.6s in current second, the time will increment once. If step was after 0.6, the time will increment twice.
            target: self,
            selector: (#selector(TrackViewController.runStopTimerIntervalTick)),
            userInfo: nil,
            repeats: false)
    }
    
    
    @objc func runTimerIntervalTick() {
        
        runTime += 1
        cadenceMetrics.updateCadence(atTimeInSeconds: runTime)
        updateUICadenceValues()
    }
    
    
    @objc func runStopTimerIntervalTick() {
        
        timePausedInRunState = true
        runTimer.invalidate()
        runStopTimer.invalidate()
        hintLabel.text = "Start Running to Begin!"
    }
    
    
    //MARK: - UI Modification Methods
    
    func showCustomAlert(title: String, message: String, addExitAction: Bool = false, addReconnectAction: Bool = false) { //Different from super class method
        
        alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        if addExitAction {
            
            if runTime >= 5 { //Don't save if less than 5 seconds total recorded
                
                let exitSaveAction = UIAlertAction(title: "Exit and Save", style: .default) { (exitSaveAction) in
                    
                    self.saveData()
                    
                    self.dismiss(animated: true, completion: nil)
                }
                
                alert?.addAction(exitSaveAction)
                
            } else {
                
                let exitAction = UIAlertAction(title: "Exit", style: .default) { (exitSaveAction) in
                    
                    self.dismiss(animated: true, completion: nil)
                }
                
                alert?.addAction(exitAction)
            }
            
            if addReconnectAction {
                
                let reconnectAction = UIAlertAction(title: "Reconnect", style: .default) { (reconnectAction) in
                    self.bleManager.startScan()
                }
                
                alert?.addAction(reconnectAction)
                
            } else { //If not giving the reconnect option, give the continue option
                
                let continueAction = UIAlertAction(title: "Continue Tracking", style: .cancel) { (continueAction) in
                    
                    if self.localBLEState == .connected { //Protecting against running when BLE turned off
                        
                        if (self.inRunState) { //Restore state
                            
                            self.initializeRunTimer()
                            self.initializeRunStopTimer()
                            self.bleManager.turnOnNotifications()
                        }
                    }
                }
                
                alert?.addAction(continueAction)
            }
            
        } else { //If not giving exit option, then the only option will be Ok option
            
            if localBLEState != .scanning { //If scanning, don't want to be able to dismiss the alert (locks the screen)
                
                let okAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
                alert?.addAction(okAction)
            }
        }
        
        present(alert!, animated: true, completion: nil)
    }
    
    
    func setPauseState() {
        
        hintLabel.text = ""
        runTimer.invalidate()
        runStopTimer.invalidate()
        inRunState = false
        timePausedInRunState = false //Must be false if inRunState is false
        pauseButton.setTitle("Resume", for: .normal)
        bleManager.turnOffNotifications()
    }
    
    
    func setRunState() {
        
        initializeRunTimer()
        runStopTimeInterval = 0.5
        initializeRunStopTimer()
        inRunState = true
        bleManager.turnOnNotifications()
        pauseButton.setTitle("Pause", for: .normal)
    }
    
    
    func updateUICadenceValues() {
        
        let cadenceStringValues = cadenceMetrics.getCadenceStringValues()
        
        recentCadenceLabel.text = cadenceStringValues.recentCadenceString
        avgCadenceLabel.text = cadenceStringValues.averageCadenceString
        stepsLabel.text = cadenceStringValues.stepsString
        
        timeLabel.text = runTime.getFormattedRunTimeString()
    }
    
    
    //MARK: - Bluetooth Manager Delegate Methods
    
    func updateForBLEEvent(_ bleEvent: BLEEvent) {

        alert?.dismiss(animated: true, completion: nil) //Make sure the new alert is shown

        switch bleEvent {
            
        case .scanStarted:
            showCustomAlert(title: "Scanning", message: "Scanning for nearby device")
        
        case .scanTimeOut:
            showCustomAlert(title: "No Device Found", message: "Make sure device is on and try again", addExitAction: true, addReconnectAction: true)
            
        case .failedToConnect:
            showCustomAlert(title: "Failed to Connect", message: "Make sure device is on and try again", addExitAction: true, addReconnectAction: true)
            
        case .disconnected:
            bleManager.startScan()
            
        case .bleTurnedOff:
            showCustomAlert(title: "Bluetooth Turned Off", message: "Please enable Bluetooth to proceed")
            
        case .bleTurnedOn:
            bleManager.startScan()
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
            
            if timePausedInRunState {
                
                timePausedInRunState = false
                initializeRunTimer()
                hintLabel.text = ""
                
            } else {
                
                runStopTimer.invalidate()
            }
            
            runStopTimeInterval = 1.4
            initializeRunStopTimer() //Start a new timer for 1.4 seconds
            cadenceMetrics.incrementSteps()
            updateUICadenceValues()
        }
    }
    
    
    //MARK: - Button Pressed Methods
    
    @IBAction func exitButtonPressed(_ sender: UIButton) {
        
        if inRunState { //To preserve the state if user continues but stop updates while alert is up
            
            runTimer.invalidate()
            runStopTimer.invalidate()
            bleManager.turnOffNotifications()
        }
        
        showCustomAlert(title: "Stop Tracking?", message: "Your data will be lost", addExitAction: true)
    }
    
    
    @IBAction func pauseButtonPressed(_ sender: UIButton) {
        
        if inRunState {
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
        newRunLogEntry.runDuration = self.runTime
        
        let newCadenceData = self.cadenceMetrics.getCadenceDataForSaving(forRunTime: self.runTime)
        
        newRunLogEntry.cadenceData = newCadenceData
        
        do {
            
            let realm = try! Realm()
            
            try realm.write {
                realm.add(newRunLogEntry)
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
