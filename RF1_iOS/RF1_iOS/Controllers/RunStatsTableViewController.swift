//
//  RunStatsTableViewController.swift
//  RF1_iOS
//
//  Created by Keegan Jebb on 2018-04-25.
//  Copyright © 2018 Keegan Jebb. All rights reserved.
//

import UIKit
import Charts


class RunStatsTableViewController: BaseTableViewController, MetricCellDelegate {
    
    var selectedRun: RunLogEntry?
    
    var specificAverageCadence: Double = 0
    
    let metricKeys: [MectricType] = [.cadence, .footstrike] //Decides the order of Metric cells
    
    var chartMetricsRequiredData = [MectricType : RequiredChartData]()
                                                              
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        tableView.register(UINib(nibName: "MetricCell", bundle: nil), forCellReuseIdentifier: "customMetricCell")
        initializeChartMetricsRequiredDataDictionary()
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func initializeChartMetricsRequiredDataDictionary() {
        
        let initialRequiredChartData = RequiredChartData(includeRawData: false,
                                                       includeMovingAverage: true,
                                                       includeWalkingData: false)
        
        for metric in metricKeys {
            chartMetricsRequiredData[metric] = initialRequiredChartData
        }
    }
    
    
    // MARK: - Table View Data Source Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chartMetricsRequiredData.count
    }
    
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let cellMetric: MectricType = metricKeys[indexPath.row]
        
        var cellHeight: CGFloat = 510
        
        if cellMetric == .footstrike {cellHeight = 500}
        
        return cellHeight
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "customMetricCell", for: indexPath) as! CustomMetricCell
        
        if let runEntry = selectedRun {
            
            let cellMetric: MectricType = metricKeys[indexPath.row]
            
            let requiredChartData: RequiredChartData = chartMetricsRequiredData[cellMetric]!
            
            cell.selectionStyle = .none
            cell.layer.borderWidth = 5
            cell.layer.borderColor = UIColor.black.cgColor
            
            cell.delegateVC = self
            
            cell.cellMetric = cellMetric
            
            if cellMetric == .cadence {
                
                if requiredChartData.includeWalkingData {
                    specificAverageCadence = runEntry.averageCadence
                } else {
                    specificAverageCadence = runEntry.averageCadenceRunningOnly
                }
                
                cell.averageStatLabel.text = "Avg. Cadence: " + specificAverageCadence.roundedIntString + " steps/min"
            
                let cadenceChartData = getFormattedCadenceChartData(forEntry: runEntry, withData: requiredChartData)
                
                cell.chartView.rightAxis.removeAllLimitLines()
                let avgCadenceLine = ChartLimitLine(limit: specificAverageCadence)
                avgCadenceLine.lineDashLengths = [5]
                avgCadenceLine.lineColor = .yellow
                cell.chartView.rightAxis.addLimitLine(avgCadenceLine)
                
                customizeChartView(forChartData: cadenceChartData, usingChartView: cell.chartView)
            
            } else if cellMetric == .footstrike {
                
                cell.averageStatContainerHeight.constant = 90
                cell.rawDataLabel?.removeFromSuperview()
                cell.rawDataSwitch?.removeFromSuperview()
                cell.movingAverageLabel?.removeFromSuperview()
                cell.movingAverageSwitch?.removeFromSuperview()
                cell.rawDataContainerHeight.constant = 0
                cell.movingAverageContainerHeight.constant = 0
                
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
                
                cell.averageStatLabel.text = "Forefoot Strike: " + specificForeStrikePercentage.roundedIntString + "%\n" + "Midfoot Strike: " + specificMidStrikePercentage.roundedIntString + "%\n" + "Heel Strike: " + specificHeelStrikePercentage.roundedIntString + "%"
                
                let footstrikeChartData = getFormattedFootstrikeLineChartData(forEntry: runEntry, withData: requiredChartData)
                
                cell.chartView.leftAxis.axisMaximum = 100
                cell.chartView.leftAxis.axisMinimum = 0
                cell.chartView.rightAxis.axisMaximum = 100
                cell.chartView.rightAxis.axisMinimum = 0
                
                cell.chartView.leftAxis.valueFormatter = IntPercentAxisFormatter()
                cell.chartView.rightAxis.valueFormatter = IntPercentAxisFormatter()

                customizeChartView(forChartData: footstrikeChartData, usingChartView: cell.chartView)
            }
        }
        
        return cell
    }

    
    func customizeChartView(forChartData chartData: LineChartData, usingChartView chartView: LineChartView) {
        
        chartView.chartDescription = nil //Label in bottom right corner
        chartView.xAxis.labelPosition = .bottom
        chartView.xAxis.labelTextColor = .white
        chartView.leftAxis.labelTextColor = .white
        chartView.rightAxis.labelTextColor = .white
        chartView.legend.textColor = .white
        
        chartView.xAxis.valueFormatter = TimeXAxisFormatter()
        
        var animateTime: Double = 0
        
        let numDataPoints = chartData.entryCount
        
        if numDataPoints >= 45 && numDataPoints < 90 {
            animateTime = Double(numDataPoints) / 90 * 1.0 //0.5s for 15 mins to 1.0s for 30 mins (assuming data every 20 seconds)
        } else if numDataPoints >= 90 {
            animateTime = 1.0 //1.0s if longer than 30 mins (assuming data every 20 seconds)
        }
        
        chartView.animate(xAxisDuration: animateTime)
        chartView.data = chartData
    }
    
    
    //MARK: - Metric Cell Delegate Method
    
    func loadNewChart(withData requiredData: RequiredChartData, forMetric metric: MectricType) {
        
        chartMetricsRequiredData[metric] = requiredData
        tableView.reloadData()
    }

}
