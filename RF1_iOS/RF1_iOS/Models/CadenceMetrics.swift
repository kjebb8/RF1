//
//  CadenceMetrics.swift
//  RF1_iOS
//
//  Created by Keegan Jebb on 2018-03-16.
//  Copyright © 2018 Keegan Jebb. All rights reserved.
//

import Foundation

class CadenceMetrics {
    
    private var intervalTime: Int
    private var intervalTimeSteps: [Int] = [0]
    private var intervalTimeStepsIndex: Int = 0
    
    var totalSteps: Int = 0

    var shortCadence: Double = 0
    var averageCadence: Double = 0
    
    init(timeForShortCadenceInSeconds timeInSeconds: Int) {
        
        intervalTime = timeInSeconds
    }
    
    func incrementSteps() {
        
        intervalTimeSteps[intervalTimeStepsIndex] += 2
        totalSteps += 2
    }
   
    func updateCadence(atTimeInMinutes currentTime: Int) {

        shortCadence = Double(intervalTimeSteps.reduce(0, +)) / intervalTimeSteps.count.inMinutes //.inMinutes converts to Double
        averageCadence = Double(totalSteps) /  currentTime.inMinutes
        
        if intervalTimeSteps.count == intervalTime {
            intervalTimeSteps.remove(at: 0)
        }
        
        intervalTimeSteps.append(0)
        intervalTimeStepsIndex += 1
    }
    
    
}
