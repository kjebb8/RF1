//
//  FootstrikeMetrics.swift
//  RF1_iOS
//
//  Created by Keegan Jebb on 2018-05-21.
//  Copyright © 2018 Keegan Jebb. All rights reserved.
//

import Foundation
import RealmSwift

class FootstrikeMetrics {
    
    private var recentFootstrikes = [FootstrikeType]()
 
    private var totalFore: Int = 0
    private var totalMid: Int = 0
    private var totalHeel: Int = 0
    
    private var totalFootstrikes: Int = 0
    
    private var totalForeRunning: Int = 0
    private var totalMidRunning: Int = 0
    private var totalHeelRunning: Int = 0
    
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
            totalForeRunning += 1
            foreLog[foreLog.count - 1] += 1
            
        } else if footstrikeType == .mid {
            
            totalMid += 1
            totalMidRunning += 1
            midLog[midLog.count - 1] += 1
            
        } else if footstrikeType == .heel {
            
            totalHeel += 1
            totalHeelRunning += 1
            heelLog[heelLog.count - 1] += 1
        }
    }
    
    
    func getFootstrikeValues() -> (recent: Dictionary<FootstrikeType,Double>, average: Dictionary<FootstrikeType,Double>) {  //Called from View Controller right after processFootstrike()
        
        var recentDict: Dictionary<FootstrikeType,Double> = [.fore : 0.0,
                                                             .mid : 0.0,
                                                             .heel : 0.0]
        
        var averageDict: Dictionary<FootstrikeType,Double> = [.fore : 0.0,
                                                              .mid : 0.0,
                                                              .heel : 0.0]
            
        if totalFootstrikes != 0 {
        
            recentDict[.fore] = Double(recentFootstrikes.filter{$0 == .fore}.count) / Double(recentFootstrikes.count) * 100
            recentDict[.mid] = Double(recentFootstrikes.filter{$0 == .mid}.count) / Double(recentFootstrikes.count) * 100
            recentDict[.heel] = Double(recentFootstrikes.filter{$0 == .heel}.count) / Double(recentFootstrikes.count) * 100
            
            averageDict[.fore] = Double(totalFore) / Double(totalFootstrikes) * 100
            averageDict[.mid] = Double(totalMid) / Double(totalFootstrikes) * 100
            averageDict[.heel] = Double(totalHeel) / Double(totalFootstrikes) * 100
        }
        
        return (recentDict, averageDict)
    }
    
    
    func updateFootstrikeLog(runningInInterval: Bool, runEnded: Bool = false) { //Assumes function is called at the correct log time intervals
        
        if !runningInInterval { //If not running, subtract the values from that interval
            
            totalForeRunning -= foreLog[foreLog.count - 1]
            totalMidRunning -= midLog[midLog.count - 1]
            totalHeelRunning -= heelLog[heelLog.count - 1]
        }
        
        if !runEnded {
            
            foreLog.append(0)
            midLog.append(0)
            heelLog.append(0)
        }
    }
    
    
    func getFootstrikeDataForSaving() -> (footstrikeLog: List<FootstrikeLogEntry>, footstrikePercentages: Dictionary<FootstrikeType,Double>, footstrikePercentagesRunning: Dictionary<FootstrikeType,Double>) {
        
        let newFootstrikeLog = List<FootstrikeLogEntry>()
        
        for i in 0..<foreLog.count {
            
            let newFootstrikeLogEntry = FootstrikeLogEntry()
            
            newFootstrikeLogEntry.foreIntervalValue = foreLog[i]
            newFootstrikeLogEntry.midIntervalValue = midLog[i]
            newFootstrikeLogEntry.heelIntervalValue = heelLog[i]
            
            newFootstrikeLog.append(newFootstrikeLogEntry)
        }
        
        let footstrikePercentages: Dictionary<FootstrikeType,Double> = [.fore : Double(totalFore) / max(Double(totalFootstrikes), 1) * 100,
                                                                        .mid : Double(totalMid) / max(Double(totalFootstrikes), 1) * 100,
                                                                        .heel : Double(totalHeel) / max(Double(totalFootstrikes), 1) * 100]
        
        let totalFootstrikesRunning = totalForeRunning + totalMidRunning + totalHeelRunning
        
        let footstrikePercentagesRunning: Dictionary<FootstrikeType,Double> = [.fore : Double(totalForeRunning) / max(Double(totalFootstrikesRunning), 1) * 100,
                                                                               .mid : Double(totalMidRunning) / max(Double(totalFootstrikesRunning), 1) * 100,
                                                                               .heel : Double(totalHeelRunning) / max(Double(totalFootstrikesRunning), 1) * 100]
        
        return(newFootstrikeLog, footstrikePercentages, footstrikePercentagesRunning)
    }
    
    
}
