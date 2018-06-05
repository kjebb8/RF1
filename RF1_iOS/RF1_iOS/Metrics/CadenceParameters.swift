//
//  CadenceParameters.swift
//  RF1_iOS
//
//  Created by Keegan Jebb on 2018-04-27.
//  Copyright © 2018 Keegan Jebb. All rights reserved.
//

import Foundation

struct MetricParameters {
    
    static let recentCadenceTime: Int = 15 //Seconds used for finding most recent cadence measurement
    static let cadenceLogTime: Int = 5 //Seconds between data points for historical data
    static let cadenceMovingAverageTime: Int = 20 //Seconds included in moving average calculation. Needs to be an even multiple of cadenceLogTime (6x not 5x)
}
