//
//  CadenceMetrics.swift
//  RF1_iOS
//
//  Created by Keegan Jebb on 2018-03-16.
//  Copyright © 2018 Keegan Jebb. All rights reserved.
//

import Foundation
import RealmSwift

class CadenceMetrics {
    
    private var recentStepTimesArray = [Double]() //Holds most recent step time data within time frame given by cadence parameters
    private var recentCadence: Double = 0 //Cadence for the most recent data
    
    private var totalSteps: Int = 0
    private var averageCadence: Double = 0 //Cadence for entire run
    private var runningCadenceValues = [Double]() //For calculating the average cadence for running only
    
    private var stepTimesInLogInterval = [Double]() //Logs the time between each step for each step in an interval
    private var cadenceLog = [Double]() //Each entry has cadence for a given interval time period
    
    private var timeSinceLastStep: Double = 0 //in seconds, Measures the elapsed time since the last step was taken

    var stepTimer = Timer()
    let stepTimeInterval = 0.05 //Goes off every second 50ms or 20 Hz
    
    
    //MARK: - Public Access Methods
    
    func incrementSteps() { //Called from View Controller when dataProcessor returns that a step was taken
        
        recentStepTimesArray.append(timeSinceLastStep)
        if recentStepTimesArray.count > MetricParameters.recentCadenceCount {recentStepTimesArray.remove(at: 0)}
        
        stepTimesInLogInterval.append(timeSinceLastStep)
        totalSteps += 2
        
        timeSinceLastStep = 0
    }
    
    
    func updateUICadenceValues(atTimeInSeconds currentTime: Int) { //Assumes function is called every second
        
        recentCadence = calculateCadence(fromStepTimesArray: recentStepTimesArray)
        averageCadence = Double(totalSteps) /  currentTime.inMinutes
    }
    
    
    func updateCadenceLog() -> (Bool) { //Assumes function is called at the correct log time intervals
        
        var runningInInterval: Bool = false
            
        let intervalCadence = calculateCadence(fromStepTimesArray: stepTimesInLogInterval)
        
        cadenceLog.append(intervalCadence)
        stepTimesInLogInterval.removeAll()
        
        if intervalCadence >= MetricParameters.walkingThresholdCadence {
            
            runningInInterval = true //Sent to other metric modules to say whether the user was running during the interval
            runningCadenceValues.append(intervalCadence)
        }
        
        return runningInInterval
    }
    
    
    func getCadenceStringValues() -> (CadenceStringValues) {
        return CadenceStringValues(recentCadence, averageCadence, totalSteps) //See class below
    }
    
    
    func getCadenceDataForSaving() -> (cadenceLog: List<CadenceLogEntry>, averageCadence: Double, runningCadence: Double) {
        
        //updateCadenceLog() is called right before getting the save data
        
        let newCadenceLog = List<CadenceLogEntry>()
        
        for data in cadenceLog {
            
            let newCadenceLogEntry = CadenceLogEntry()
            newCadenceLogEntry.cadenceIntervalValue = data
            newCadenceLog.append(newCadenceLogEntry)
        }
        
        let runningCadence = runningCadenceValues.reduce(0, +) / max(Double(runningCadenceValues.count), 1)
        
        return(newCadenceLog, averageCadence, runningCadence)
    }
    
    
    //MARK: - Private Helper Methods
    
    private func calculateCadence(fromStepTimesArray stepTimes: [Double]) -> (Double) {
        
        var cadence: Double = 0
        
        let averageStepTime = stepTimes.reduce(0, +) / max(Double(stepTimes.count), 1) / 2 //Factor of two to account for other foot
        
        if averageStepTime != 0 {cadence = 1 / averageStepTime * 60}
        
        return cadence
    }
    
    
    //MARK: - Step Timing Methods
    
    func initializeStepTimer() { //Follows the runTimer in TrackViewController
        
        stepTimer = Timer.scheduledTimer(
            timeInterval: stepTimeInterval,
            target: self,
            selector: (#selector(CadenceMetrics.stepTimerIntervalTick)),
            userInfo: nil,
            repeats: true)
    }
    
    
    @objc private func stepTimerIntervalTick() {
        timeSinceLastStep += stepTimeInterval
    }
    
    
}


//MARK: - Cadence String Values Class

class CadenceStringValues {
    
    var recentCadenceString: String
    var averageCadenceString: String
    var stepsString: String
    
    init(_ recentCadence: Double, _ averageCadence: Double, _ steps: Int) {
        
        recentCadenceString = recentCadence.roundedIntString
        averageCadenceString = averageCadence.roundedIntString
        stepsString = String(steps)
    }
    
    
}
