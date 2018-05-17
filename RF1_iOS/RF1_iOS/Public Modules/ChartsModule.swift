//
//  ChartsViewController.swift
//  RF1_iOS
//
//  Created by Keegan Jebb on 2018-05-02.
//  Copyright © 2018 Keegan Jebb. All rights reserved.
//

import Charts

//Public Charts Module

//Used to determine what data the user wants displayed
struct RequiredMetrics {
    
    var includeCadenceRawData: Bool = false
    var includeCadenceMovingAverage: Bool = false
}


//MARK: - Cadence Chart

func getFormattedCadenceChartData(forEntry runEntry: RunLogEntry, withMetrics requiredMetrics: RequiredMetrics) -> LineChartData {
    
    guard let cadenceLog = runEntry.cadenceData?.cadenceLog else {fatalError()}
    
    var cadenceDataEntries = [ChartDataEntry]()
    
    let numberOfSimpleMAValues: Int = CadenceParameters.cadenceMovingAverageTime / CadenceParameters.cadenceLogTime
    var simpleMAValuesArray = [Double]()
    var simpleMA: Double = 0
    var simpleMADataEntries = [ChartDataEntry]()
    
    if requiredMetrics.includeCadenceRawData {
        cadenceDataEntries.append(ChartDataEntry(x: 0, y: cadenceLog[0].cadenceIntervalValue)) //Initial value
    }
    

    if requiredMetrics.includeCadenceRawData || requiredMetrics.includeCadenceMovingAverage {
    
        for i in 0..<cadenceLog.count {
            
            var cadenceTime: Double = 0
        
            if requiredMetrics.includeCadenceRawData {
                
                cadenceTime = (Double((i + 1) * CadenceParameters.cadenceLogTime) / 60.0)
                
//                if i == cadenceLog.count - 1 { //Last entry is likely shorter (minimum 5 seconds)
//                    cadenceTime = runEntry.runDuration.inMinutes
//                } else {
//                    cadenceTime = (Double((i + 1) * CadenceParameters.cadenceLogTime) / 60.0)
//                }
                
                cadenceDataEntries.append(ChartDataEntry(x: cadenceTime, y: cadenceLog[i].cadenceIntervalValue))
            }
            
            
            if requiredMetrics.includeCadenceMovingAverage {
            
                simpleMAValuesArray.append(cadenceLog[i].cadenceIntervalValue)
                
                if simpleMAValuesArray.count > numberOfSimpleMAValues {
                    simpleMAValuesArray.remove(at: 0)
                }
                
                let numberOfRawValuesBetweenDataPoints: Int = numberOfSimpleMAValues / 2 //Determines the frequency of simpleMA data points using modulus
                
                if (i + 1) % numberOfRawValuesBetweenDataPoints == 0 && simpleMAValuesArray.count == numberOfSimpleMAValues { //SimpleMA using data on either side
                
                    cadenceTime = ((Double(i) + 1 - Double(numberOfRawValuesBetweenDataPoints)) * Double(CadenceParameters.cadenceLogTime)) / 60.0 //SimpleMA using data on either side
                    simpleMA = simpleMAValuesArray.reduce(0, +) / Double(simpleMAValuesArray.count)
                    simpleMADataEntries.append(ChartDataEntry(x: cadenceTime, y: simpleMA))
                }
            }
        }
    }
    
    
    let cadenceDataSet = LineChartDataSet(values: cadenceDataEntries, label: "Raw Data")
    
    let simpleMADataSet = LineChartDataSet(values: simpleMADataEntries, label: "Moving Average")
    
    if requiredMetrics.includeCadenceRawData {
    
        cadenceDataSet.setColor(UIColor.cyan) //Colour of line
        cadenceDataSet.lineWidth = 1
        cadenceDataSet.drawValuesEnabled = false //Doesn't come up if too many points
        cadenceDataSet.drawCirclesEnabled = false
        cadenceDataSet.mode = .cubicBezier //Makes curves smooth
        
        let gradientColors = [ChartColorTemplates.colorFromString("#005454").cgColor,
                              UIColor.cyan.cgColor]

        let gradient = CGGradient(colorsSpace: nil, colors: gradientColors as CFArray, locations: nil)!
        cadenceDataSet.fillAlpha = 0.5
        cadenceDataSet.fill = Fill(linearGradient: gradient, angle: 90)
        cadenceDataSet.drawFilledEnabled = true //Fill under the curve
    }
    
    
    if requiredMetrics.includeCadenceMovingAverage {
    
        simpleMADataSet.setColor(UIColor.green) //Colour of line
        simpleMADataSet.lineWidth = 1
        simpleMADataSet.drawValuesEnabled = false //Doesn't come up if too many points
        simpleMADataSet.drawCirclesEnabled = false
        simpleMADataSet.mode = .cubicBezier //Makes curves smooth
        
        let gradientColors = [ChartColorTemplates.colorFromString("#004B00").cgColor,
                              UIColor.green.cgColor]

        let gradient = CGGradient(colorsSpace: nil, colors: gradientColors as CFArray, locations: nil)!
        simpleMADataSet.fillAlpha = 0.5
        simpleMADataSet.fill = Fill(linearGradient: gradient, angle: 90)
        simpleMADataSet.drawFilledEnabled = true //Fill under the curve
    }
    
    return LineChartData(dataSets: [cadenceDataSet, simpleMADataSet])
}


//MARK: - Extra Stuff That was Removed

//    var cumulativeMA: Double = cadenceLog[0].cadenceIntervalValue
//    var cumulativeMADataEntries = [ChartDataEntry]()
//    cumulativeMADataEntries.append(ChartDataEntry(x: 0, y: cumulativeMA)) //Initial value
//        cumulativeMA = (cumulativeMA * Double(i + 1) + cadenceLog[i].cadenceIntervalValue) / Double(i + 2)
//        cumulativeMADataEntries.append(ChartDataEntry(x: cadenceTime, y: cumulativeMA))
//    let cumulativeMADataSet = LineChartDataSet(values: cumulativeMADataEntries, label: "Cumulative Moving Average")
//    cumulativeMADataSet.setColor(UIColor.red) //Colour of line
//    cumulativeMADataSet.lineWidth = 1
//    cumulativeMADataSet.drawValuesEnabled = false //Doesn't come up if too many points
//    cumulativeMADataSet.drawCirclesEnabled = false
//    cumulativeMADataSet.mode = .cubicBezier //Makes curves smooth

//        if (i + 1) % Int(numberOfRawValuesBetweenDataPoints) == 0 { //SimpleMA using only previous data

