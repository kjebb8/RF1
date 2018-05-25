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
    
    private var recentCadenceSteps: [Int] = [0] //Holds most recent step data within time given by cadence parameters
    private var recentCadence: Double = 0 //Cadence for the most recent step data
    
    private var totalSteps: Int = 0
    private var averageCadence: Double = 0 //Cadence for entire run
    private var runningCadenceValues = [Double]() //For calculating the average cadence for running only
    
    private var cadenceLogSteps: Double = 0 //Counts the steps in the current log interval time. Counts fractions of a step for accuracy
    private var cadenceLog = [Double]() //Each entry has cadence for a given interval time period
    
    private var timeBetweenLastSteps: Double = 0 //in seconds, Measures how much time between consecutive steps
    private var timeSinceLastStep: Double = 0 //in seconds, Measures the elapsed time since the last step was taken
    private var stepSubtractionValue: Double = 0 //Amount of steps needed to be subtracted because a fraction of a step was added to the previous time interval
    var stepTimer = Timer()
    
    
    //MARK: - Public Access Methods
    
    func incrementSteps() { //Called from View Controller when dataProcessor returns that a step was taken
        
        recentCadenceSteps[recentCadenceSteps.count - 1] += 2
        totalSteps += 2
        cadenceLogSteps += 2
        
        if stepSubtractionValue != 0 { //If most of the step occured in the previous interval, subtract that fraction from this interval
            cadenceLogSteps -= stepSubtractionValue
            stepSubtractionValue = 0
        }
        
        timeBetweenLastSteps = timeSinceLastStep
        timeSinceLastStep = 0
    }
    
    
    func updateCadence(atTimeInSeconds currentTime: Int) -> (Bool) { //Assumes function is called every second

        recentCadence = Double(recentCadenceSteps.reduce(0, +)) / recentCadenceSteps.count.inMinutes //.inMinutes converts to Double
        averageCadence = Double(totalSteps) /  currentTime.inMinutes
        
        recentCadenceSteps.append(0)
        
        if recentCadenceSteps.count > MetricParameters.recentCadenceTime {
            recentCadenceSteps.remove(at: 0) //Removes the oldest value so that only a certian time period is included
        }
        
        var runningInInterval: Bool = false
        
        if currentTime % MetricParameters.metricLogTime == 0 {  //Add a value to the cadence log
            
            var steps = Double(cadenceLogSteps)
            
            if timeBetweenLastSteps > 0 && timeBetweenLastSteps < 2.0 && steps != 0 {
                
                let stepFraction = min((timeSinceLastStep / timeBetweenLastSteps), 0.95) //Fraction of next step taken in current interval
                steps += 2 * (stepFraction)
                stepSubtractionValue = 2 * (stepFraction)
            }
            
            let intervalCadence = steps / MetricParameters.metricLogTime.inMinutes
            cadenceLog.append(intervalCadence)
            cadenceLogSteps = 0
            
            if intervalCadence >= MetricParameters.walkingThresholdCadence {
                
                runningInInterval = true //Sent to other metric modules to say whether the user was running during the interval
                runningCadenceValues.append(intervalCadence)
            }
        }
        
        return runningInInterval
    }
    
    
    func getCadenceStringValues() -> (CadenceStringValues) {
        return CadenceStringValues(recentCadence, averageCadence, totalSteps) //See class below
    }
    
    
    func getCadenceDataForSaving(forRunTime runTime: Int) -> (cadenceLog: List<CadenceLogEntry>, averageCadence: Double, runningCadence: Double) {
        
        let newCadenceLog = List<CadenceLogEntry>()
        
        let remainingTime = runTime % MetricParameters.metricLogTime
        
        if remainingTime >= 5 {cadenceLog.append(Double(cadenceLogSteps) / remainingTime.inMinutes)} //Adds the incomplete cadence data if longer than 5 seconds (for accuracy)
        
        for data in cadenceLog {
            
            let newCadenceLogEntry = CadenceLogEntry()
            newCadenceLogEntry.cadenceIntervalValue = data
            newCadenceLog.append(newCadenceLogEntry)
        }
        
        let runningCadence = runningCadenceValues.reduce(0, +) / max(Double(runningCadenceValues.count), 1)
        
        return(newCadenceLog, averageCadence, runningCadence)
    }
    
    
    //MARK: - Step Timing Methods
    
    func initializeStepTimer() { //Follows the runTimer in TrackViewController
        
        stepTimer = Timer.scheduledTimer(
            timeInterval: 0.05, //Goes off every second 10ms
            target: self,
            selector: (#selector(CadenceMetrics.stepTimerIntervalTick)),
            userInfo: nil,
            repeats: true)
    }
    
    
    @objc private func stepTimerIntervalTick() {
        timeSinceLastStep += 0.05
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
