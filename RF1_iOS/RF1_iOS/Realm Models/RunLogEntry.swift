//
//  RunLogEntry.swift
//  RF1_iOS
//
//  Created by Keegan Jebb on 2018-04-20.
//  Copyright © 2018 Keegan Jebb. All rights reserved.
//

import Foundation
import RealmSwift

class RunLogEntry: Object {
    
    @objc dynamic var date: String = ""
    @objc dynamic var startTime: String = ""
    @objc dynamic var runDuration: Int = 0 //In seconds
    
    @objc dynamic var averageCadence: Double = 0
    @objc dynamic var averageCadenceRunningOnly: Double = 0
    var cadenceLog = List<CadenceLogEntry>()
    
    @objc dynamic var foreStrikePercentage: Double = 0
    @objc dynamic var midStrikePercentage: Double = 0
    @objc dynamic var heelStrikePercentage: Double = 0
    var footstrikeLog = List<FootstrikeLogEntry>()
}
