//
//  CadenceMetrics.swift
//  RF1_iOS
//
//  Created by Keegan Jebb on 2018-03-16.
//  Copyright © 2018 Keegan Jebb. All rights reserved.
//

import Foundation

protocol CadenceMetricsDelegate {
    func didUpdateCadenceValues()
}


class CadenceMetrics {
    
    private var intervalTime: Int
    private var intervalTimeSteps: [Int] = [0]
    private var intervalTimeStepsIndex: Int = 0
    
    var totalSteps: Int = 0

    var shortCadence: Double = 0
    var averageCadence: Double = 0
    
    var runTime: Int = 0 //In seconds
    var runTimer = Timer()
    
    private var delegateVC: CadenceMetricsDelegate?
    
    init(timeForShortCadenceInSeconds timeInSeconds: Int, delegate: CadenceMetricsDelegate) {
        
        delegateVC = delegate
        intervalTime = timeInSeconds
    }
    
    
    //MARK: - Timer Methods
    
    func initializeTimer() {
        
        runTimer = Timer.scheduledTimer(
            timeInterval: 1,
            target: self,
            selector: (#selector(CadenceMetrics.timerIntervalTick)),
            userInfo: nil,
            repeats: true)
    }
    
    
    @objc private func timerIntervalTick() {
        
        runTime += 1
        updateCadence(atTimeInMinutes: runTime)
        delegateVC?.didUpdateCadenceValues()
    }
    
    
    func getFormattedTimeString() -> (String) {
        
        if runTime.hours >= 1 {
            return String(format: "%i:%02i:%02i", runTime.hours, runTime.minutes, runTime.seconds)
        } else {
            return String(format: "%i:%02i", runTime.minutes, runTime.seconds)
        }
    }
    
    
    //MARK: - Cadence Calculation Methods
    
    //Called from View Controller
    func incrementSteps() {
        
        intervalTimeSteps[intervalTimeStepsIndex] += 2
        totalSteps += 2
        delegateVC?.didUpdateCadenceValues()
    }
    
   
    private func updateCadence(atTimeInMinutes currentTime: Int) {

        shortCadence = Double(intervalTimeSteps.reduce(0, +)) / intervalTimeSteps.count.inMinutes //.inMinutes converts to Double
        averageCadence = Double(totalSteps) /  currentTime.inMinutes
        
        intervalTimeSteps.append(0)
        
        if intervalTimeSteps.count <= intervalTime {
            intervalTimeStepsIndex += 1
        } else {
            intervalTimeSteps.remove(at: 0)
        }
    }
    
    
}
