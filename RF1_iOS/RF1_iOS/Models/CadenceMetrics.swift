//
//  CadenceMetrics.swift
//  RF1_iOS
//
//  Created by Keegan Jebb on 2018-03-16.
//  Copyright © 2018 Keegan Jebb. All rights reserved.
//

import Foundation

class CadenceMetrics {
    
    private var shortTime: Int
    private var intervalSteps: Int = 0
    private var shortTimeSteps = [Int]()
    
    var totalSteps: Int = 0

    var shortCadence: Double = 0
    var averageCadence: Double = 0
    
    init(timeForShortCadenceInSeconds timeInSeconds: Int) {
        
        shortTime = timeInSeconds
    }
    
    func incrementSteps() {
        
        intervalSteps += 2
        totalSteps += 2
    }
   
    func updateCadence(atTimeInMinutes currentTime: Int) {
        
        shortTimeSteps.append(intervalSteps)
        intervalSteps = 0
        
        if shortTimeSteps.count == shortTime {
            
            shortTimeSteps.remove(at: 0)
        }

        shortCadence = Double(shortTimeSteps.reduce(0, +)) / shortTimeSteps.count.inMinutes //.inMinutes converts to Double
        averageCadence = Double(totalSteps) /  currentTime.inMinutes
    }
    
    
}
