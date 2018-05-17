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
    
    var chartMetrics = [RequiredMetrics(includeCadenceRawData: false,
                                        includeCadenceMovingAverage: true),
                        RequiredMetrics(includeCadenceRawData: false,
                                        includeCadenceMovingAverage: true)]
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        tableView.register(UINib(nibName: "MetricCell", bundle: nil), forCellReuseIdentifier: "customMetricCell")
        tableView.rowHeight = 500
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Table View Data Source Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "customMetricCell", for: indexPath) as! CustomMetricCell
        
        if let runEntry = selectedRun {
            
            cell.selectionStyle = .none
            cell.layer.borderWidth = 5
            cell.layer.borderColor = UIColor.black.cgColor
            
            cell.delegateVC = self
            
            cell.cellRow = indexPath.row
            
            cell.averageStatLabel.text = "Avg. Cadence: " + (runEntry.cadenceData?.averageCadence.roundedIntString)! + " steps/min"
            
            let cadenceChartData = getFormattedCadenceChartData(forEntry: runEntry, withMetrics: chartMetrics[indexPath.row])
            
            customizeChartView(forChartData: cadenceChartData, usingChartView: cell.chartView)
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
        
        var animateTime: Double = 0
        
        let numDataPoints = chartData.entryCount
        
        if numDataPoints >= 45 && numDataPoints < 90 {
            animateTime = Double(numDataPoints) / 90 * 1.0 //0.5s for 15 mins to 1.0s for 30 mins (assuming data every 20 seconds)
        } else if numDataPoints >= 90 {
            animateTime = 1.0 //1.5s if longer than 30 mins (assuming data every 20 seconds)
        }
        
        chartView.animate(xAxisDuration: animateTime)
        chartView.data = chartData
        
//        let avgCadenceLine = ChartLimitLine(limit: (selectedRun?.cadenceData?.averageCadence)! , label: "Avg. Cadence")
        let avgCadenceLine = ChartLimitLine(limit: (selectedRun?.cadenceData?.averageCadence)!)
//        avgCadenceLine.valueTextColor = .white
//        avgCadenceLine.labelPosition = .rightTop //Relative to line position
        avgCadenceLine.lineDashLengths = [5]
        avgCadenceLine.lineColor = .yellow
        chartView.rightAxis.addLimitLine(avgCadenceLine)
    }
    
    
    //MARK: - Metric Cell Delegate Method
    
    func loadNewChart(withMetrics requiredMetrics: RequiredMetrics, atRow row: Int) {
        
        chartMetrics[row] = requiredMetrics
        tableView.reloadData()
    }

}
