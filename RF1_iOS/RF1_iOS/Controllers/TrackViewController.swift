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
import Charts

class TrackViewController: BaseViewController, BLEManagerDelegate, BLEDataManagerDelegate {
    
    var bleManager: BLEManager! //Handles the BLE connection and reports back with events or changes in state
    
    var bleDataManager: BLEDataManager! //Handles the incoming BLE notification data and reports back with run-related events
    
    var cadenceMetrics = CadenceMetrics() //Holds the properties and mehtods used to track user's cadence
    
    var footstrikeMetrics = FootstrikeMetrics() ////Holds the properties and mehtods used to track user's footstrike characteristics
    
    var inRunState: Bool = false //Reflects whether the timer is paused by user or not
    
    var localBLEState: BLEState = .connected //Keeps the BLE state so it can be used anywhere in the class
    
    var alert: UIAlertController?
    
    var runTime: Int = 0 //In seconds
    var runTimer = Timer()
    
    let date = Date()
    
    @IBOutlet weak var recentCadenceTitle: UILabel!
    @IBOutlet weak var recentCadenceLabel: UILabel!
    @IBOutlet weak var recentFootstrikeTitle: UILabel!
    @IBOutlet weak var recentFootstrikeLabel: UILabel!
    @IBOutlet weak var avgCadenceLabel: UILabel!
    @IBOutlet weak var avgFootstrikeLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var stepsLabel: UILabel!
    
    @IBOutlet weak var pauseButton: UIButton!
    
    @IBOutlet weak var hintLabel: UILabel! //May not use this
    @IBOutlet weak var dataLabel: UILabel!
    
    @IBOutlet weak var recentFootstrikeChartView: BarChartView!
    @IBOutlet weak var averageFootstrikeChartView: BarChartView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pauseButton.setTitleColor(UIColor.darkGray, for: .disabled)
        pauseButton.setTitleColor(UIColor.lightGray, for: .normal)
        
        bleManager.setDelegate(to: self)
        
        bleDataManager = BLEDataManager(delegate: self)
        
//        recentCadenceTitle.text = "\(MetricParameters.recentCadenceTime)s Cadence"
        hintLabel.text = ""
        
        formatChart(recentFootstrikeChartView)
        formatChart(averageFootstrikeChartView)
        
        updateUICadenceValues()
        updateUIFootstrikeValues()
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
    
    
    @objc func runTimerIntervalTick() {
        
        runTime += 1
        cadenceMetrics.updateCadence(atTimeInSeconds: runTime)
        updateUICadenceValues()
        
        if runTime % MetricParameters.metricLogTime == 0 {footstrikeMetrics.updateFootstrikeLog()}
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
                            self.cadenceMetrics.initializeStepTimer()
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
        
        runTimer.invalidate()
        cadenceMetrics.stepTimer.invalidate()
        inRunState = false
        bleManager.turnOffNotifications()
        pauseButton.setTitle("Resume", for: .normal)
    }
    
    
    func setRunState() {
        
        initializeRunTimer()
        cadenceMetrics.initializeStepTimer()
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
    
    
    func updateUIFootstrikeValues() {
        
        let footstrikeValues = footstrikeMetrics.getFootstrikeValues()
        
        let footstrikeChartData = getFormattedFootstrikeBarChartData(recentValues: footstrikeValues.recent, averageValues: footstrikeValues.average)
        
        let formatter: CustomIntFormatter = CustomIntFormatter()
        
        recentFootstrikeChartView.data = footstrikeChartData.recent
        recentFootstrikeChartView.data!.setValueFormatter(formatter)
        
        averageFootstrikeChartView.data = footstrikeChartData.average
        averageFootstrikeChartView.data!.setValueFormatter(formatter)
    }
    
    
    func formatChart(_ chartView: BarChartView) {
        
        chartView.chartDescription = nil //Label in bottom right corner
        
        let xlabels: [String] = ["", "         Fore", "         Mid", "         Heel"] //Very sketchy but the labels won't show up and align otherwise...
        
        chartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: xlabels)
        chartView.xAxis.labelPosition = .bottom
        chartView.xAxis.labelTextColor = UIColor.white
        chartView.xAxis.centerAxisLabelsEnabled = true
        chartView.xAxis.drawGridLinesEnabled = false
        chartView.xAxis.drawAxisLineEnabled = false
        
        chartView.rightAxis.enabled = false
        
        chartView.leftAxis.enabled = false

        chartView.legend.enabled = false
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
//        print("\(bleDataManager.forefootVoltage) \(bleDataManager.heelVoltage)")
    }
    
    
    //MARK: - Data Manager Callback
    
    func didFinishDataProcessing(withReturn returnValue: BLEDataManagerReturn) {
        
        if returnValue == .didTakeStep {
            
            cadenceMetrics.incrementSteps()
            updateUICadenceValues()
            
        } else if returnValue == .foreStrike || returnValue == .midStrike || returnValue == .heelStrike {
            
            footstrikeMetrics.processFootstrike(forEvent: returnValue)
            updateUIFootstrikeValues()
        }
    }
    
    
    //MARK: - Button Pressed Methods
    
    @IBAction func exitButtonPressed(_ sender: UIButton) {
        
        if inRunState { //To preserve the state if user continues but stop updates while alert is up
            
            runTimer.invalidate()
            cadenceMetrics.stepTimer.invalidate()
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
        
        let newCadenceLog = self.cadenceMetrics.getCadenceLogForSaving(forRunTime: self.runTime)
        
        newRunLogEntry.cadenceLog = newCadenceLog
        
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
