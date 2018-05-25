//
//  Enums.swift
//  RF1_iOS
//
//  Created by Keegan Jebb on 2018-05-24.
//  Copyright © 2018 Keegan Jebb. All rights reserved.
//

import Foundation

enum FootstrikeType { //Used in FootstrikeMetrics to filter the type of action to be taken
    
    case fore
    case mid
    case heel
}


enum BLEEvent { //Used by BLEManager to notify Delegate VC of any events
    
    case scanStarted
    case scanTimeOut
    case failedToConnect
    case disconnected
    case bleTurnedOff
    case bleTurnedOn
}


enum BLEState { //Used by BLEManager to track state internally and notify Delegate VC of changes
    
    case scanning
    case connected
    case notConnected
    case bleOff
    case bleUnavailable
}


enum BLEDataManagerReturn { //Lists the possible events that can occur as a result of FSR Data Processing. Delegate VC notified.
    
    case didTakeStep
    case foreStrike
    case midStrike
    case heelStrike
}


enum MectricType { //Used in RunStatsVC to track the type of metric being used for tableView cells
    
    case cadence
    case footstrike
}
