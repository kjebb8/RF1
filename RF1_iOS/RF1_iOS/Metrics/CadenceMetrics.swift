//
//  CadenceMetrics.swift
//  RF1_iOS
//
//  Created by Keegan Jebb on 2018-03-16.
//  Copyright © 2018 Keegan Jebb. All rights reserved.
//

import Foundation

class CadenceMetrics {
    
    private var recentCadenceSteps: [Int] = [0] //Holds most recent step data within time given by cadence parameters
    private var recentCadence: Double = 0 //Cadence for the most recent step data
    
    private var totalSteps: Int = 0
    private var averageCadence: Double = 0 //Cadence for entire run
    
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
        
        if stepSubtractionValue > 0 { //If most of the step occured in the previous interval, subtract that fraction from this interval
            cadenceLogSteps -= stepSubtractionValue
            stepSubtractionValue = 0
        }
        
        timeBetweenLastSteps = timeSinceLastStep
        timeSinceLastStep = 0
    }
    
    
    func updateCadence(atTimeInSeconds currentTime: Int) { //Assumes function is called every second

        recentCadence = Double(recentCadenceSteps.reduce(0, +)) / recentCadenceSteps.count.inMinutes //.inMinutes converts to Double
        averageCadence = Double(totalSteps) /  currentTime.inMinutes
        
        recentCadenceSteps.append(0)
        
        if recentCadenceSteps.count > CadenceParameters.recentCadenceTime {
            recentCadenceSteps.remove(at: 0) //Removes the oldest value so that only a certian time period is included
        }
        
        if currentTime % CadenceParameters.cadenceLogTime == 0 {  //Add a value to the cadence log
            
            var steps = Double(cadenceLogSteps)
            
            if timeBetweenLastSteps > 0 && timeBetweenLastSteps < 2.0 && steps != 0 {
                
                let stepFraction = min((timeSinceLastStep / timeBetweenLastSteps), 0.95) //Fraction of next step taken in current interval
                steps += 2 * (stepFraction)
                stepSubtractionValue = 2 * (stepFraction)
            }
            
            cadenceLog.append(steps / CadenceParameters.cadenceLogTime.inMinutes)
            cadenceLogSteps = 0
        }
    }
    
    
    func getCadenceStringValues() -> (CadenceStringValues) {
        return CadenceStringValues(recentCadence, averageCadence, totalSteps) //See class below
    }
    
    
    func getCadenceDataForSaving(forRunTime runTime: Int) -> (CadenceData) {
        
        let newCadenceData = CadenceData()
        
//        newCadenceData.averageCadence = averageCadence
        
        let remainingTime = runTime % CadenceParameters.cadenceLogTime
        
        if remainingTime >= 5 {cadenceLog.append(Double(cadenceLogSteps) / remainingTime.inMinutes)} //Adds the incomplete cadence data if longer than 5 seconds (for accuracy)
        
        for data in cadenceLog {
            
            let newCadenceLogEntry = CadenceLogEntry()
            newCadenceLogEntry.cadenceIntervalValue = data
            newCadenceData.cadenceLog.append(newCadenceLogEntry)
        }
        
        return(newCadenceData)
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
