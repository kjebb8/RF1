//
//  averageStatCell.swift
//  RF1_iOS
//
//  Created by Keegan Jebb on 2018-05-14.
//  Copyright © 2018 Keegan Jebb. All rights reserved.
//

import UIKit
import Charts

class CustomMetricCell: UITableViewCell {
 
    @IBOutlet weak var averageStatContainerHeight: NSLayoutConstraint!
    @IBOutlet weak var averageStatContainer: UIView!
    @IBOutlet weak var averageStatLabel: UILabel!
    
    @IBOutlet weak var chartView: LineChartView!
    
    @IBOutlet weak var rawDataContainerHeight: NSLayoutConstraint!
    @IBOutlet weak var rawDataLabel: UILabel?
    @IBOutlet weak var rawDataSwitch: UISwitch?
    
    @IBOutlet weak var movingAverageContainerHeight: NSLayoutConstraint!
    @IBOutlet weak var movingAverageLabel: UILabel?
    @IBOutlet weak var movingAverageSwitch: UISwitch?
    
    @IBOutlet weak var walkingDataSwitch: UISwitch!
    
    var runEntry: RunLogEntry!
    var cellMetric: MetricType!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    
    func setUp(forRunEntry runLogEntry: RunLogEntry, andCellMetric metric: MetricType) { //Only called once
        
        selectionStyle = .none
        layer.borderWidth = 5
        layer.borderColor = UIColor.black.cgColor
        
        runEntry = runLogEntry
        cellMetric = metric
        
        if cellMetric == .footstrike {
            
            averageStatContainerHeight.constant = 90
            rawDataLabel?.removeFromSuperview()
            rawDataSwitch?.removeFromSuperview()
            movingAverageLabel?.removeFromSuperview()
            movingAverageSwitch?.removeFromSuperview()
            rawDataContainerHeight.constant = 0
            movingAverageContainerHeight.constant = 0
            
            chartView.leftAxis.axisMaximum = 100
            chartView.leftAxis.axisMinimum = 0
            chartView.rightAxis.axisMaximum = 100
            chartView.rightAxis.axisMinimum = 0
            
            chartView.leftAxis.valueFormatter = IntPercentAxisFormatter()
            chartView.rightAxis.valueFormatter = IntPercentAxisFormatter()
        }
        
        customizeChartView()
        
        updateUI()
    }
    
    
    
    @IBAction func dataSwitched(_ sender: UISwitch) {
        updateUI()
    }
    
    
    private func updateUI() {

        let requiredChartData = RequiredChartData(includeRawData: rawDataSwitch?.isOn ?? false,
                                                  includeMovingAverage: movingAverageSwitch?.isOn ?? true,
                                                  includeWalkingData: walkingDataSwitch.isOn)
        
        if cellMetric == .cadence {
        
            var specificAverageCadence: Double
            
            if requiredChartData.includeWalkingData {
                specificAverageCadence = runEntry.averageCadence
            } else {
                specificAverageCadence = runEntry.averageCadenceRunningOnly
            }
            
            averageStatLabel.text = "Avg. Cadence: " + specificAverageCadence.roundedIntString + " steps/min"
            
            chartView.rightAxis.removeAllLimitLines()
            let avgCadenceLine = ChartLimitLine(limit: specificAverageCadence)
            avgCadenceLine.lineDashLengths = [5]
            avgCadenceLine.lineColor = .yellow
            chartView.rightAxis.addLimitLine(avgCadenceLine)
            
            let cadenceChartData = getFormattedCadenceChartData(forEntry: runEntry, withData: requiredChartData)
            
            var animateTime: Double = 0
            
            let numDataPoints = cadenceChartData.entryCount
            
            if numDataPoints >= 45 && numDataPoints < 90 {
                animateTime = Double(numDataPoints) / 90 * 1.0 //0.5s for 15 mins to 1.0s for 30 mins (assuming data every 20 seconds)
            } else if numDataPoints >= 90 {
                animateTime = 1.0 //1.0s if longer than 30 mins (assuming data every 20 seconds)
            }
            
            chartView.animate(xAxisDuration: animateTime)
            
            chartView.data = cadenceChartData
            
        } else if cellMetric == .footstrike {
            
            var specificForeStrikePercentage: Double
            var specificMidStrikePercentage: Double
            var specificHeelStrikePercentage: Double
            
            if requiredChartData.includeWalkingData {
            
                specificForeStrikePercentage = runEntry.foreStrikePercentage
                specificMidStrikePercentage = runEntry.midStrikePercentage
                specificHeelStrikePercentage = runEntry.heelStrikePercentage
            
            } else {
            
                specificForeStrikePercentage = runEntry.foreStrikePercentageRunning
                specificMidStrikePercentage = runEntry.midStrikePercentageRunning
                specificHeelStrikePercentage = runEntry.heelStrikePercentageRunning
            }
            
            averageStatLabel.text = "Forefoot Strike: " + specificForeStrikePercentage.roundedIntString + "%\n" + "Midfoot Strike: " + specificMidStrikePercentage.roundedIntString + "%\n" + "Heel Strike: " + specificHeelStrikePercentage.roundedIntString + "%"
            
            let footstrikeChartData = getFormattedFootstrikeLineChartData(forEntry: runEntry, withData: requiredChartData)
            
            var animateTime: Double = 0
            
            let numDataPoints = footstrikeChartData.entryCount
            
            if numDataPoints >= 45 && numDataPoints < 90 {
                animateTime = Double(numDataPoints) / 90 * 1.0 //0.5s for 15 mins to 1.0s for 30 mins (assuming data every 20 seconds)
            } else if numDataPoints >= 90 {
                animateTime = 1.0 //1.0s if longer than 30 mins (assuming data every 20 seconds)
            }
            
            chartView.animate(xAxisDuration: animateTime)
            
            chartView.data = footstrikeChartData
        }
    }
    
    
    private func customizeChartView() { //Only called once
        
        chartView.chartDescription = nil //Label in bottom right corner
        chartView.xAxis.labelPosition = .bottom
        chartView.xAxis.labelTextColor = .white
        chartView.leftAxis.labelTextColor = .white
        chartView.rightAxis.labelTextColor = .white
        chartView.legend.textColor = .white
        
        chartView.xAxis.valueFormatter = TimeXAxisFormatter()
    }


}
