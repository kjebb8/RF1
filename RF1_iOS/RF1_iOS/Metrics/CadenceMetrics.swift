//
//  CadenceMetrics.swift
//  RF1_iOS
//
//  Created by Keegan Jebb on 2018-03-16.
//  Copyright © 2018 Keegan Jebb. All rights reserved.
//

import Foundation

class CadenceMetrics {
    
    private var recentCadenceSteps: [Int] = [0] //Holds most recent 20s worth of step data
    private var recentCadence: Double = 0 //Cadence for the most recent 20 seconds
    
    private var totalSteps: Int = 0
    private var averageCadence: Double = 0 //Cadence for entire run
    
    private var cadenceLogSteps: Int = 0 //Counts the steps in the current 5s interval
    private var cadenceLog = [Double]() //Each entry has cadence for 5s intervals
    
    
    //MARK: - Public Access Methods
    
    func incrementSteps() { //Called from View Controller when dataProcessor returns that a step was taken
        
        recentCadenceSteps[recentCadenceSteps.count - 1] += 2
        totalSteps += 2
        cadenceLogSteps += 2
    }
    
    
    func updateCadence(atTimeInSeconds currentTime: Int) { //Assumes function is called every second

        recentCadence = Double(recentCadenceSteps.reduce(0, +)) / recentCadenceSteps.count.inMinutes //.inMinutes converts to Double
        averageCadence = Double(totalSteps) /  currentTime.inMinutes
        
        recentCadenceSteps.append(0)
        
        if recentCadenceSteps.count > CadenceParameters.recentCadenceTime {
            recentCadenceSteps.remove(at: 0) //Removes the oldest value so that only 20s of data is collected
        }
        
        if currentTime % CadenceParameters.cadenceLogTime == 0 {
            
            cadenceLog.append(Double(cadenceLogSteps) / CadenceParameters.cadenceLogTime.inMinutes)
            cadenceLogSteps = 0
        }
        
    }
    
    
    func getCadenceStringValues() -> (CadenceStringValues) {
        return CadenceStringValues(recentCadence, averageCadence, totalSteps)
    }
    
    
    func getCadenceDataForSaving(forRunTime runTime: Int) -> (CadenceData) {
        
        let newCadenceData = CadenceData()
        newCadenceData.averageCadence = averageCadence
        
        let remainingTime = runTime % CadenceParameters.cadenceLogTime
        if remainingTime != 0 {cadenceLog.append(Double(cadenceLogSteps) / remainingTime.inMinutes)} //Adds the incomplete cadence data
        
        for data in cadenceLog {
            
            let newCadenceLogEntry = CadenceLogEntry()
            newCadenceLogEntry.cadenceIntervalValue = data
            newCadenceData.cadenceLog.append(newCadenceLogEntry)
        }
        
        return(newCadenceData)
    }
    
    
}


//MARK: - Cadence String Values Class

class CadenceStringValues {
    
    var shortCadenceString: String
    var averageCadenceString: String
    var stepsString: String
    
    init(_ shortCadence: Double, _ averageCadence: Double, _ steps: Int) {
        
        shortCadenceString = String((Int(shortCadence.rounded())))
        averageCadenceString = String(Int(averageCadence.rounded()))
        stepsString = String(steps)
    }
    
    
}
