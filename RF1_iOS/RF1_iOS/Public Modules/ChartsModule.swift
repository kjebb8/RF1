//
//  ChartsViewController.swift
//  RF1_iOS
//
//  Created by Keegan Jebb on 2018-05-02.
//  Copyright © 2018 Keegan Jebb. All rights reserved.
//

import Charts

//Public Charts Module

//MARK: - Cadence Chart

func getFormattedCadenceChartData(forCadenceData cadenceData: CadenceData) -> LineChartData {
    
    var cadenceDataEntries = [ChartDataEntry]()
    
    let cadenceLog = cadenceData.cadenceLog
    
    cadenceDataEntries.append(ChartDataEntry(x: 0, y: cadenceLog[0].cadenceIntervalValue)) //Initial value
    
    for i in 0..<cadenceLog.count {
    
        let cadenceTime = (Double((i + 1) * CadenceParameters.cadenceLogTime) / 60.0)
        cadenceDataEntries.append(ChartDataEntry(x: cadenceTime, y: cadenceLog[i].cadenceIntervalValue))
    }
    
    let cadenceDataSet = LineChartDataSet(values: cadenceDataEntries, label: "Cadence (steps/min)")
    
    cadenceDataSet.setColor(UIColor.cyan) //Colour of line
    cadenceDataSet.lineWidth = 1
    cadenceDataSet.drawValuesEnabled = false //Doesn't come up if too many points
    cadenceDataSet.drawCirclesEnabled = false
    cadenceDataSet.mode = .cubicBezier //Makes curves smooth
    
    let gradientColors = [ChartColorTemplates.colorFromString("#005454").cgColor,
                          UIColor.cyan.cgColor]
    
    let gradient = CGGradient(colorsSpace: nil, colors: gradientColors as CFArray, locations: nil)!
    cadenceDataSet.fillAlpha = 0.8
    cadenceDataSet.fill = Fill(linearGradient: gradient, angle: 90)
    cadenceDataSet.drawFilledEnabled = true //Fill under the curve

    return LineChartData(dataSet: cadenceDataSet)
}
