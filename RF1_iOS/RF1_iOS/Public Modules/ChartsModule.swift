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
    var includeWalkingData: Bool = false
}


//MARK: - Cadence Chart

func getFormattedCadenceChartData(forEntry runEntry: RunLogEntry, withMetrics requiredMetrics: RequiredMetrics) -> (chartData: LineChartData, averageCadence: Double) {
    
    guard let cadenceLog = runEntry.cadenceData?.cadenceLog else {fatalError()}
    
    let walkingThreshold: Double = 130 //Cadence below the threshold is considered walking
    
    var allCadenceValues = [Double]() //For calculating the average cadence for the particular data displayed on the chart
    
    var cadenceDataEntries = [ChartDataEntry]()
    
    let numberOfSimpleMAValues: Int = CadenceParameters.cadenceMovingAverageTime / CadenceParameters.cadenceLogTime
    var simpleMAValuesArray = [Double]()
    var simpleMA: Double = 0
    var simpleMADataEntries = [ChartDataEntry]()

    if requiredMetrics.includeCadenceRawData || requiredMetrics.includeCadenceMovingAverage {
        
        var cadenceTimeIntervals: Int = 0 //How many cadence values are being used
    
        for i in 0..<cadenceLog.count {
            
            let cadenceValue = cadenceLog[i].cadenceIntervalValue
            
            if !requiredMetrics.includeWalkingData {
                if cadenceValue < walkingThreshold {continue} //Skip loop iteration if walking
            }
            
            cadenceTimeIntervals += 1
            
            allCadenceValues.append(cadenceValue)
            
            var cadenceTime: Double = 0
        
            if requiredMetrics.includeCadenceRawData {
                
                cadenceTime = (Double(cadenceTimeIntervals * CadenceParameters.cadenceLogTime) -  Double(CadenceParameters.cadenceLogTime) / 2.0) / 60.0

//                if i == cadenceLog.count - 1 { //Last entry is likely shorter (minimum 5 seconds)
//                    cadenceTime = runEntry.runDuration.inMinutes
//                } else {
//                    cadenceTime = (Double(cadenceTimeIntervals * CadenceParameters.cadenceLogTime) -  Double(CadenceParameters.cadenceLogTime) / 2.0) / 60.0
//                }
                
                cadenceDataEntries.append(ChartDataEntry(x: cadenceTime, y: cadenceValue))
            }
            
            
            if requiredMetrics.includeCadenceMovingAverage {
            
                simpleMAValuesArray.append(cadenceValue)
                
                if simpleMAValuesArray.count > numberOfSimpleMAValues {
                    simpleMAValuesArray.remove(at: 0)
                }
                
                let numberOfRawValuesBetweenDataPoints: Int = numberOfSimpleMAValues / 2 //Determines the frequency of simpleMA data points using modulus
                
                if cadenceTimeIntervals % numberOfRawValuesBetweenDataPoints == 0 && simpleMAValuesArray.count == numberOfSimpleMAValues { //SimpleMA using data on either side
                
                    cadenceTime = ((Double(cadenceTimeIntervals - numberOfRawValuesBetweenDataPoints)) * Double(CadenceParameters.cadenceLogTime)) / 60.0 //SimpleMA using data on either side
                    simpleMA = simpleMAValuesArray.reduce(0, +) / Double(numberOfSimpleMAValues)
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
    
    let chartData = LineChartData(dataSets: [cadenceDataSet, simpleMADataSet])
    
    let averageCadence = allCadenceValues.count != 0 ? allCadenceValues.reduce(0, +) / Double(allCadenceValues.count) : 0

    return (chartData, averageCadence)
}
