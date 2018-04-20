//
//  CadenceMetrics.swift
//  RF1_iOS
//
//  Created by Keegan Jebb on 2018-03-16.
//  Copyright © 2018 Keegan Jebb. All rights reserved.
//

import Foundation

class CadenceMetrics {
    
    private var recentCadenceIntervalTime: Int = 20 //Set to 20s usually
    private var recentCadenceIntervalTimeSteps: [Int] = [0] //Holds most recent 20s worth of step data
    private var recentCadence: Double = 0 //Cadence for the most recent 20 seconds
    
    private var totalSteps: Int = 0
    private var averageCadence: Double = 0 //Cadence for entire run
    
    private var cadenceIntervalLogTime: Int = 5 //5 second batches
    private var cadenceIntervalSteps: Int = 0 //Counts the steps in the current 5s interval
    private var cadenceIntervalLog = [Double]() //Each entry has cadence for 5s intervals
    
    
    //MARK: - Public Access Methods
    
    func incrementSteps() { //Called from View Controller when dataProcessor returns that a step was taken
        
        recentCadenceIntervalTimeSteps[recentCadenceIntervalTimeSteps.count - 1] += 2
        totalSteps += 2
        cadenceIntervalSteps += 2
    }
    
    
    func updateCadence(atTimeInSeconds currentTime: Int) { //Assumes function is called every second

        recentCadence = Double(recentCadenceIntervalTimeSteps.reduce(0, +)) / recentCadenceIntervalTimeSteps.count.inMinutes //.inMinutes converts to Double
        averageCadence = Double(totalSteps) /  currentTime.inMinutes
        
        recentCadenceIntervalTimeSteps.append(0)
        
        if recentCadenceIntervalTimeSteps.count > recentCadenceIntervalTime {
            recentCadenceIntervalTimeSteps.remove(at: 0) //Removes the oldest value so that only 20s of data is collected
        }
        
        if currentTime % cadenceIntervalLogTime == 0 {
            
            cadenceIntervalLog.append(Double(cadenceIntervalSteps) / cadenceIntervalLogTime.inMinutes)
            cadenceIntervalSteps = 0
            print(cadenceIntervalLog)
        }
        
    }
    
    
    func getCadenceStringValues() -> (CadenceStringValues) {
        return CadenceStringValues(recentCadence, averageCadence, totalSteps)
    }
    
    
    func saveCadenceData(forRunTime runTime: Int) -> (cadenceData: CadenceData, cadenceLog: [Double]) {
        
        let cadenceData = CadenceData()
        cadenceData.averageCadence = averageCadence
        
        return(cadenceData, cadenceIntervalLog)
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
