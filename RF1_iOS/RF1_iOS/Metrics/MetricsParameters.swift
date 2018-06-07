//
//  MetricsParameters.swift
//  RF1_iOS
//
//  Created by Keegan Jebb on 2018-05-21.
//  Copyright © 2018 Keegan Jebb. All rights reserved.
//

import Foundation

struct MetricParameters {
    
    static let recentCadenceCount: Int = 10 //Number of most recent steps used for the real-time cadence metrics
    static let recentFootstrikeCount: Int = 10 //Number of most recent footstrike measurements for the real-time metrics
    
    static let walkingThresholdCadence: Double = 130 //Cadence below the threshold is considered walking
    
    static let metricLogTime: Int = 5//Seconds between data points for historical data
    static let movingAverageTime: Int = 20 //Seconds included in moving average calculation. Needs to be an even multiple of cadenceLogTime (6x not 5x)
}
