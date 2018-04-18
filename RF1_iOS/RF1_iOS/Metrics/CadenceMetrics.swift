//
//  CadenceMetrics.swift
//  RF1_iOS
//
//  Created by Keegan Jebb on 2018-03-16.
//  Copyright © 2018 Keegan Jebb. All rights reserved.
//

import Foundation

class CadenceMetrics {
    
    private var intervalTime: Int //Set to 20s usually
    private var intervalTimeSteps: [Int] = [0] //Holds most recent 20s worth of step data
    private var intervalTimeStepsIndex: Int = 0 //Current index of the last value in the intervalTimeSteps array (between 0 and 19)

    private var shortCadence: Double = 0 //Cadence for the most recent 20 seconds
    private var averageCadence: Double = 0 //Cadence for entire run
    
    private var totalSteps: Int = 0
    
    init(timeForShortCadenceInSeconds timeInSeconds: Int) {
        intervalTime = timeInSeconds
    }
    
    
    //MARK: - Public Access Methods
    
    func incrementSteps() { //Called from View Controller when dataProcessor returns that a step was taken
        
        intervalTimeSteps[intervalTimeStepsIndex] += 2
        totalSteps += 2
    }
    
    
    func updateCadence(atTimeInMinutes currentTime: Int) {

        shortCadence = Double(intervalTimeSteps.reduce(0, +)) / intervalTimeSteps.count.inMinutes //.inMinutes converts to Double
        averageCadence = Double(totalSteps) /  currentTime.inMinutes
        
        intervalTimeSteps.append(0)
        
        if intervalTimeSteps.count <= intervalTime {
            intervalTimeStepsIndex += 1
        } else {
            intervalTimeSteps.remove(at: 0) //Removes the oldest value so that only 20s of data is collected
        }
    }
    
    
    func getCadenceStringValues() -> (CadenceStringValues) {
        return CadenceStringValues(shortCadence, averageCadence, totalSteps)
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
