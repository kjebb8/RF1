//
//  CadenceValues.swift
//  RF1_iOS
//
//  Created by Keegan Jebb on 2018-04-04.
//  Copyright © 2018 Keegan Jebb. All rights reserved.
//

import Foundation

class CadenceStringValues {
    
    var shortCadenceString: String
    var averageCadenceString: String
    var timeString: String
    var stepsString: String
    
    init(_ shortCadence: Double, _ averageCadence: Double, _ time: String, _ steps: Int) {
        
        shortCadenceString = String((Int(shortCadence.rounded())))
        averageCadenceString = String(Int(averageCadence.rounded()))
        timeString = time
        stepsString = String(steps)
    }
}
