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
struct RequiredChartData {
    
    var includeRawData: Bool = false
    var includeMovingAverage: Bool = false
    var includeWalkingData: Bool = false
}


//MARK: - Cadence Chart

func getFormattedCadenceChartData(forEntry runEntry: RunLogEntry, withData requiredData: RequiredChartData) -> (LineChartData) {
    
    let cadenceLog = runEntry.cadenceLog
    
    var cadenceDataEntries = [ChartDataEntry]()
    
    let numberOfSimpleMAValues: Int = MetricParameters.movingAverageTime / MetricParameters.metricLogTime
    var simpleMAValuesArray = [Double]()
    var simpleMADataEntries = [ChartDataEntry]()

    if requiredData.includeRawData || requiredData.includeMovingAverage {
        
        var cadenceTimeIntervals: Int = 0 //How many cadence values are being used
    
        for i in 0..<cadenceLog.count {
            
            let cadenceValue = cadenceLog[i].cadenceIntervalValue
            
            if !requiredData.includeWalkingData {
                if cadenceValue < MetricParameters.walkingThresholdCadence {continue} //Skip loop iteration if walking
            }
            
            cadenceTimeIntervals += 1
            
            var cadenceTime: Double = 0
        
            if requiredData.includeRawData {
                
                cadenceTime = (Double(cadenceTimeIntervals * MetricParameters.metricLogTime) -  Double(MetricParameters.metricLogTime) / 2.0) / 60.0
                
                cadenceDataEntries.append(ChartDataEntry(x: cadenceTime, y: cadenceValue))
            }
            
            
            if requiredData.includeMovingAverage {
            
                simpleMAValuesArray.append(cadenceValue)
                
                if simpleMAValuesArray.count > numberOfSimpleMAValues {
                    simpleMAValuesArray.remove(at: 0)
                }
                
                let numberOfRawValuesBetweenDataPoints: Int = numberOfSimpleMAValues / 2 //Determines the frequency of simpleMA data points using modulus
                
                if cadenceTimeIntervals % numberOfRawValuesBetweenDataPoints == 0 && simpleMAValuesArray.count == numberOfSimpleMAValues { //SimpleMA using data on either side
                
                    cadenceTime = ((Double(cadenceTimeIntervals - numberOfRawValuesBetweenDataPoints)) * Double(MetricParameters.metricLogTime)) / 60.0 //SimpleMA using data on either side
                    let simpleMA: Double = simpleMAValuesArray.reduce(0, +) / Double(numberOfSimpleMAValues)
                    simpleMADataEntries.append(ChartDataEntry(x: cadenceTime, y: simpleMA))
                }
            }
        }
    }
    
    
    let cadenceDataSet = LineChartDataSet(values: cadenceDataEntries, label: "Raw Data")
    
    let simpleMADataSet = LineChartDataSet(values: simpleMADataEntries, label: "Moving Average")
    
    if requiredData.includeRawData {
    
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
    
    
    if requiredData.includeMovingAverage {
    
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



//MARK: - Footstrike Bar Charts

func getFormattedTrackingFootstrikeBarChartData(recentValues: Dictionary<String,Double>, averageValues: Dictionary<String,Double>) -> (recent: BarChartData, average: BarChartData) {

    let recentDataEntries = [BarChartDataEntry(x: 0, y: recentValues["Fore"]!),
                             BarChartDataEntry(x: 1, y: recentValues["Mid"]!),
                             BarChartDataEntry(x: 2, y: recentValues["Heel"]!)]
    
    let averageDataEntries = [BarChartDataEntry(x: 0, y: averageValues["Fore"]!),
                              BarChartDataEntry(x: 1, y: averageValues["Mid"]!),
                              BarChartDataEntry(x: 2, y: averageValues["Heel"]!)]
    
   return (formattedFootstrikeBarChartData(forEntries: recentDataEntries),
           formattedFootstrikeBarChartData(forEntries: averageDataEntries))
}


func getFormattedRealmFootstrikeBarChartData(forEntry runEntry: RunLogEntry) -> (BarChartData) {
    
    let dataEntries = [BarChartDataEntry(x: 0, y: runEntry.foreStrikePercentage),
                       BarChartDataEntry(x: 1, y: runEntry.midStrikePercentage),
                       BarChartDataEntry(x: 2, y: runEntry.heelStrikePercentage)]
    
    return (formattedFootstrikeBarChartData(forEntries: dataEntries))
}


private func formattedFootstrikeBarChartData(forEntries dataEntries: [BarChartDataEntry]) -> BarChartData {
    
    let dataSet = BarChartDataSet(values: dataEntries, label: "") //Labels won't show up
    
    dataSet.setColor(UIColor.white)
    dataSet.valueTextColor = UIColor.lightGray
    dataSet.valueFont = .boldSystemFont(ofSize: 12)
    
    return BarChartData(dataSet: dataSet)
}


//MARK: - Footstrike Line Charts

func getFormattedFootstrikeLineChartData(forEntry runEntry: RunLogEntry, withData requiredData: RequiredChartData) -> (LineChartData) {
    
    let footstrikeLog = runEntry.footstrikeLog
    let cadenceLog = runEntry.cadenceLog
    
    let numberOfSimpleMAValues: Int = MetricParameters.movingAverageTime / MetricParameters.metricLogTime
    
//    var foreDataEntries = [ChartDataEntry]()
//
//    var midDataEntries = [ChartDataEntry]()
//
//    var heelDataEntries = [ChartDataEntry]()
    
    var foreSimpleMAValuesArray = [Int]()
    var foreSimpleMADataEntries = [ChartDataEntry]()
    
    var midSimpleMAValuesArray = [Int]()
    var midSimpleMADataEntries = [ChartDataEntry]()
    
    var heelSimpleMAValuesArray = [Int]()
    var heelSimpleMADataEntries = [ChartDataEntry]()
    
//    if requiredData.includeRawData || requiredData.includeMovingAverage {
    
        var footstrikeTimeIntervals: Int = 0 //How many cadence values are being used
        
        for i in 0..<footstrikeLog.count {
            
            let cadenceIndex = min(i, cadenceLog.count - 1) //footstrikeLog is potentially 1 element longer than cadenceLog, so make sure the index does not go out of bounds. This means if the last cadence interval was considered walking, then the last two footstrike elements would be considered walking
            
            let cadenceValue = cadenceLog[cadenceIndex].cadenceIntervalValue
            
            if !requiredData.includeWalkingData {
                if cadenceValue < MetricParameters.walkingThresholdCadence {continue} //Skip loop iteration if walking
            }
            
            footstrikeTimeIntervals += 1
            
//            if requiredData.includeRawData {
//
//                footstrikeTime = (Double(footstrikeTimeIntervals * MetricParameters.metricLogTime) -  Double(MetricParameters.metricLogTime) / 2.0) / 60.0
//
//                let foreStrikesInInterval: Int = footstrikeLog[i].foreIntervalValue
//                let midStrikesInInterval: Int = footstrikeLog[i].midIntervalValue
//                let heelStrikesInInterval: Int = footstrikeLog[i].heelIntervalValue
//
//                let totalStrikesInInterval: Int = foreStrikesInInterval + midStrikesInInterval + heelStrikesInInterval
//
//                let heelPercent: Double = Double(heelStrikesInInterval) / Double(totalStrikesInInterval) * 100
//                let midPercent: Double = Double(midStrikesInInterval) / Double(totalStrikesInInterval) * 100 + heelPercent
//
//                foreDataEntries.append(ChartDataEntry(x: footstrikeTime, y: 100)) //Always 100% based on how the data will be graphed
//                midDataEntries.append(ChartDataEntry(x: footstrikeTime, y: midPercent))
//                heelDataEntries.append(ChartDataEntry(x: footstrikeTime, y: heelPercent))
//            }
            
            
            if requiredData.includeMovingAverage {
                
                foreSimpleMAValuesArray.append(footstrikeLog[i].foreIntervalValue)
                midSimpleMAValuesArray.append(footstrikeLog[i].midIntervalValue)
                heelSimpleMAValuesArray.append(footstrikeLog[i].heelIntervalValue)
                
                if foreSimpleMAValuesArray.count > numberOfSimpleMAValues {
                    
                    foreSimpleMAValuesArray.remove(at: 0)
                    midSimpleMAValuesArray.remove(at: 0)
                    heelSimpleMAValuesArray.remove(at: 0)
                }
                
                let numberOfRawValuesBetweenDataPoints: Int = numberOfSimpleMAValues / 2 //Determines the frequency of simpleMA data points using modulus
                
                if footstrikeTimeIntervals % numberOfRawValuesBetweenDataPoints == 0 && foreSimpleMAValuesArray.count == numberOfSimpleMAValues { //SimpleMA using data on either side
                    
                    let footstrikeTime: Double = ((Double(footstrikeTimeIntervals - numberOfRawValuesBetweenDataPoints)) * Double(MetricParameters.metricLogTime)) / 60.0 //SimpleMA using data on either side
                    
                    let foreStrikesInInterval: Int = foreSimpleMAValuesArray.reduce(0, +)
                    let midStrikesInInterval: Int = midSimpleMAValuesArray.reduce(0, +)
                    let heelStrikesInInterval: Int = heelSimpleMAValuesArray.reduce(0, +)
                    
                    let totalStrikesInInterval: Int = foreStrikesInInterval + midStrikesInInterval + heelStrikesInInterval
                    
                    let heelPercent: Double = Double(heelStrikesInInterval) / Double(totalStrikesInInterval) * 100
                    let midPercent: Double = Double(midStrikesInInterval) / Double(totalStrikesInInterval) * 100 + heelPercent
                    
                    foreSimpleMADataEntries.append(ChartDataEntry(x: footstrikeTime, y: 100)) //Always 100% based on how the data will be graphed
                    midSimpleMADataEntries.append(ChartDataEntry(x: footstrikeTime, y: midPercent))
                    heelSimpleMADataEntries.append(ChartDataEntry(x: footstrikeTime, y: heelPercent))
                }
            }
        }
//    }
    
//    let cadenceDataSet = LineChartDataSet(values: cadenceDataEntries, label: "Raw Data")
    
    let foreSimpleMADataSet = LineChartDataSet(values: foreSimpleMADataEntries, label: "Forefoot % Moving Average   ") //Tab puts next legend entry on new line
    let midSimpleMADataSet = LineChartDataSet(values: midSimpleMADataEntries, label: "Midfoot % Moving Average  ")
    let heelSimpleMADataSet = LineChartDataSet(values: heelSimpleMADataEntries, label: "Heel % Moving Average   ")
    
    if requiredData.includeMovingAverage {
        
        foreSimpleMADataSet.setColor(UIColor.lightGray) //Colour of line
        foreSimpleMADataSet.lineWidth = 1
        foreSimpleMADataSet.drawValuesEnabled = false //Doesn't come up if too many points
        foreSimpleMADataSet.drawCirclesEnabled = false
        foreSimpleMADataSet.mode = .cubicBezier //Makes curves smooth
        foreSimpleMADataSet.drawFilledEnabled = true //Fill under the curve
        foreSimpleMADataSet.fillColor = UIColor.lightGray
        foreSimpleMADataSet.fillAlpha = 0.9
        
        midSimpleMADataSet.setColor(UIColor.gray)
        midSimpleMADataSet.lineWidth = 1
        midSimpleMADataSet.drawValuesEnabled = false
        midSimpleMADataSet.drawCirclesEnabled = false
        midSimpleMADataSet.mode = .cubicBezier
        midSimpleMADataSet.drawFilledEnabled = true
        midSimpleMADataSet.fillColor = UIColor.gray
        midSimpleMADataSet.fillAlpha = 0.9
        
        heelSimpleMADataSet.setColor(UIColor.darkGray)
        heelSimpleMADataSet.lineWidth = 1
        heelSimpleMADataSet.drawValuesEnabled = false
        heelSimpleMADataSet.drawCirclesEnabled = false
        heelSimpleMADataSet.mode = .cubicBezier
        heelSimpleMADataSet.drawFilledEnabled = true
        heelSimpleMADataSet.fillColor = UIColor.darkGray
        heelSimpleMADataSet.fillAlpha = 0.9
    }
    
    return LineChartData(dataSets: [foreSimpleMADataSet, midSimpleMADataSet, heelSimpleMADataSet])
}


//MARK: - Formatters

public class IntPercentFormatter: NSObject, IValueFormatter{
    
    public func stringForValue(_ value: Double, entry: ChartDataEntry, dataSetIndex: Int, viewPortHandler: ViewPortHandler?) -> String {
        
        let correctValue = Int(value)
        return String(correctValue) + " %"
    }
}


@objc(BarChartFormatter)
public class FootstrikeBarChartFormatter: NSObject, IAxisValueFormatter{
    
    var xValsFootstrike: [String]! = ["Fore", "Mid", "Heel"]
    
    
    public func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        
        return xValsFootstrike[Int(value)]
    }
}


@objc(LineChartFormatter)
public class IntPercentAxisFormatter: NSObject, IAxisValueFormatter{
    
    var xValsFootstrike: [String]! = ["Fore", "Mid", "Heel"]
    
    
    public func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        
        let correctValue = Int(value)
        return String(correctValue) + "%"
    }
}


@objc(LineChartFormatter)
public class TimeXAxisFormatter: NSObject, IAxisValueFormatter{
    
    var xValsFootstrike: [String]! = ["Fore", "Mid", "Heel"]
    
    
    public func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        
        let correctValue = Int((value * 60).rounded())
        return correctValue.getFormattedRunTimeString()
    }
}


