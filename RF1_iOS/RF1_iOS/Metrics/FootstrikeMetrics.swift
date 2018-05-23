//
//  FootstrikeMetrics.swift
//  RF1_iOS
//
//  Created by Keegan Jebb on 2018-05-21.
//  Copyright © 2018 Keegan Jebb. All rights reserved.
//

import Foundation
import RealmSwift

enum FootstrikeType {
    
    case fore
    case mid
    case heel
}

class FootstrikeMetrics {
    
    private var recentFootstrikes = [FootstrikeType]()
 
    private var totalFore: Int = 0
    private var totalMid: Int = 0
    private var totalHeel: Int = 0
    
    private var totalFootstrikes: Int = 0
    
    private var foreLog: [Int] = [0] //Each entry has number of forefoot strikes for a given interval time period
    private var midLog: [Int] = [0]
    private var heelLog: [Int] = [0]
    
    
    //MARK: - Public Access Methods
    
    func processFootstrike(forEvent event: BLEDataManagerReturn) { //Called from View Controller when dataProcessor returns that a footstrike event
        
        var footstrikeType: FootstrikeType
        
        if event == .foreStrike {footstrikeType = .fore}
        else if event == .midStrike {footstrikeType = .mid}
        else {footstrikeType = .heel}
        
        totalFootstrikes += 1
        
        recentFootstrikes.append(footstrikeType)
        
        if recentFootstrikes.count > MetricParameters.recentFootstrikeCount {recentFootstrikes.remove(at: 0)}
        
        if footstrikeType == .fore {
            
            totalFore += 1
            foreLog[foreLog.count - 1] += 1
            
        } else if footstrikeType == .mid {
            
            totalMid += 1
            midLog[midLog.count - 1] += 1
            
        } else if footstrikeType == .heel {
            
            totalHeel += 1
            heelLog[heelLog.count - 1] += 1
        }
    }
    
    
    func getFootstrikeValues() -> (recent: [Double], average: [Double]) {
        
        var recentForePercent: Double = 0
        var recentMidPercent: Double = 0
        var recentHeelPercent: Double = 0
        
        var averageForePercent: Double = 0
        var averageMidPercent: Double = 0
        var averageHeelPercent: Double = 0
            
        if totalFootstrikes != 0 {
        
            recentForePercent = Double(recentFootstrikes.filter{$0 == .fore}.count) / Double(recentFootstrikes.count) * 100
            recentMidPercent = Double(recentFootstrikes.filter{$0 == .mid}.count) / Double(recentFootstrikes.count) * 100
            recentHeelPercent = Double(recentFootstrikes.filter{$0 == .heel}.count) / Double(recentFootstrikes.count) * 100
            
            averageForePercent = Double(totalFore) / Double(totalFootstrikes) * 100
            averageMidPercent = Double(totalMid) / Double(totalFootstrikes) * 100
            averageHeelPercent = Double(totalHeel) / Double(totalFootstrikes) * 100
        }
        
        return ([recentForePercent, recentMidPercent, recentHeelPercent], [averageForePercent, averageMidPercent, averageHeelPercent])
    }
    
    
    func updateFootstrikeLog() { //Assumes function is called at the correct time intervals
        
        foreLog.append(0)
        midLog.append(0)
        heelLog.append(0)
    }
    
    
    func getFootstrikeLogForSaving() -> (List<FootstrikeLogEntry>) {
        
        let newFootstrikeLog = List<FootstrikeLogEntry>()
        
        for i in 0..<foreLog.count {
            
            let newFootstrikeLogEntry = FootstrikeLogEntry()
            
            newFootstrikeLogEntry.foreIntervalValue = foreLog[i]
            newFootstrikeLogEntry.midIntervalValue = midLog[i]
            newFootstrikeLogEntry.heelIntervalValue = heelLog[i]
            
            newFootstrikeLog.append(newFootstrikeLogEntry)
        }
        
        return(newFootstrikeLog)
    }
    
    
}


//MARK: - Footstrike String Values Class

//class FootstrikeStringValues {
//
//    var recentForePercentString: String
//    var recentMidPercentString: String
//    var recentHeelPercentString: String
//
//    var averageForePercentString: String
//    var averageMidPercentString: String
//    var averageHeelPercentString: String
//
//    init(_ recentForePercent: Double , _ recentMidPercent: Double, _ recentHeelPercent: Double, _ averageForePercent: Double, _ averageMidPercent: Double, _ averageHeelPercent: Double) {
//
//        recentForePercentString = recentForePercent.roundedIntString
//        recentMidPercentString = recentMidPercent.roundedIntString
//        recentHeelPercentString = recentHeelPercent.roundedIntString
//
//        averageForePercentString = averageForePercent.roundedIntString
//        averageMidPercentString = averageMidPercent.roundedIntString
//        averageHeelPercentString = averageHeelPercent.roundedIntString
//    }
//
//
//}
