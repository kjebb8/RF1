//
//  CadenceMetrics.swift
//  RF1_iOS
//
//  Created by Keegan Jebb on 2018-03-16.
//  Copyright © 2018 Keegan Jebb. All rights reserved.
//

import Foundation

protocol CadenceMetricsDelegate {
    func didUpdateCadenceValues(with cadenceStringValues: CadenceStringValues)
}


class CadenceMetrics {
    
    private var intervalTime: Int //Set to 20s usually
    private var intervalTimeSteps: [Int] = [0] //Holds most recent 20s worth of step data
    private var intervalTimeStepsIndex: Int = 0 //Current index of the last value in the intervalTimeSteps array (between 0 and 19)

    private var shortCadence: Double = 0 //Cadence for the most recent 20 seconds
    private var averageCadence: Double = 0
    
    private var runTime: Int = 0 //In seconds
    var runTimer = Timer()
    
    private var totalSteps: Int = 0
    
    private var delegateVC: CadenceMetricsDelegate?
    
    
    //MARK: - Public Access Methods
    
    init(timeForShortCadenceInSeconds timeInSeconds: Int, delegate: CadenceMetricsDelegate) {
        
        delegateVC = delegate
        intervalTime = timeInSeconds
        delegateVC?.didUpdateCadenceValues(with: getCadenceStringValues())
    }
    
    
    func incrementSteps() { //Called from View Controller when dataProcessor returns that a step was taken
        
        intervalTimeSteps[intervalTimeStepsIndex] += 2
        totalSteps += 2
        delegateVC?.didUpdateCadenceValues(with: getCadenceStringValues()) //Updates the step count in real time
    }
    
    
    //MARK: - Timer Methods
    
    func initializeTimer() {
        
        runTimer = Timer.scheduledTimer(
            timeInterval: 1, //Goes off every second
            target: self,
            selector: (#selector(CadenceMetrics.timerIntervalTick)),
            userInfo: nil,
            repeats: true)
    }
    
    
    @objc private func timerIntervalTick() {
        
        runTime += 1
        updateCadence(atTimeInMinutes: runTime)
        delegateVC?.didUpdateCadenceValues(with: getCadenceStringValues())
    }
    
    
    private func getFormattedTimeString() -> (String) {
        
        if runTime.hours >= 1 {
            return String(format: "%i:%02i:%02i", runTime.hours, runTime.minutes, runTime.seconds)
        } else {
            return String(format: "%i:%02i", runTime.minutes, runTime.seconds)
        }
    }
    
    
    //MARK: - Get String Return Values Method
    
    private func getCadenceStringValues() -> (CadenceStringValues) {
        return CadenceStringValues(shortCadence, averageCadence, getFormattedTimeString(), totalSteps)
    }
    
    
    //MARK: - Cadence Calculation Methods
   
    private func updateCadence(atTimeInMinutes currentTime: Int) {

        shortCadence = Double(intervalTimeSteps.reduce(0, +)) / intervalTimeSteps.count.inMinutes //.inMinutes converts to Double
        averageCadence = Double(totalSteps) /  currentTime.inMinutes
        
        intervalTimeSteps.append(0)
        
        if intervalTimeSteps.count <= intervalTime {
            intervalTimeStepsIndex += 1
        } else {
            intervalTimeSteps.remove(at: 0) //Removes the oldest value so that only 20s of data is collected
        }
    }
    
    
}
