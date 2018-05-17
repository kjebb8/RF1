//
//  CadenceParameters.swift
//  RF1_iOS
//
//  Created by Keegan Jebb on 2018-04-27.
//  Copyright © 2018 Keegan Jebb. All rights reserved.
//

import Foundation

struct CadenceParameters {
    
    static let recentCadenceTime: Int = 20 //Seconds used for finding most recent cadence measurement
    static let cadenceLogTime: Int = 20 //Seconds between data points for historical data
    static let cadenceMovingAverageTime: Int = 120 //Seconds included in moving average calculation. Needs to be an even multiple of cadenceLogTime (6x not 5x)
//    static let removeWalkingData: Bool = true //Determines whether walking data will be excluded from historical data (works best if cadenceLogTime < 10s)
//    static let walkingThreshold: Double = 130 //Cadence below the threshold is considered walking
}
