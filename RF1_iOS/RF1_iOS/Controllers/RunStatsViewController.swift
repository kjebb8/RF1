//
//  RunStatsTableViewController.swift
//  RF1_iOS
//
//  Created by Keegan Jebb on 2018-04-25.
//  Copyright © 2018 Keegan Jebb. All rights reserved.
//

import UIKit
import Charts

class RunStatsViewController: UIViewController {
    
    var selectedRun: RunLogEntry?

    @IBOutlet weak var avgCadenceLabel: UILabel!
    @IBOutlet weak var chartView: LineChartView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        displayUICadenceInfo()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func displayUICadenceInfo() {
        
        if let runCadenceData = selectedRun?.cadenceData {
            
            avgCadenceLabel.text = "Avg. Cadence: " + runCadenceData.averageCadence.roundedIntString + " steps/min"
            
            let cadenceChartData = getFormattedCadenceChartData(forCadenceData: runCadenceData)
            customizeChartView(forChartData: cadenceChartData)
        }
    }

    
    func customizeChartView(forChartData chartData: LineChartData) {
        
        chartView.chartDescription = nil //Label in bottom right corner
        chartView.xAxis.labelPosition = .bottom
        chartView.xAxis.labelTextColor = .white
        chartView.leftAxis.labelTextColor = .white
        chartView.rightAxis.labelTextColor = .white
        chartView.legend.textColor = .white
        
        var animateTime: Double = 0
        
        let numDataPoints = chartData.entryCount
        print(numDataPoints)
        
        if numDataPoints >= 30 && numDataPoints < 90 {
            animateTime = Double(numDataPoints) / 90 * 1.5 //0.5s for 10 mins to 1.5s for 30 mins (assuming data every 20 seconds)
        } else if numDataPoints >= 90 {
            animateTime = 1.5 //1.5s if longer than 30 mins (assuming data every 20 seconds)
        }
        
        chartView.animate(xAxisDuration: animateTime)
        chartView.data = chartData
        
        let avgCadenceLine = ChartLimitLine(limit: (selectedRun?.cadenceData?.averageCadence)! , label: "Avg. Cadence")
        avgCadenceLine.valueTextColor = .white
        avgCadenceLine.labelPosition = .rightTop //Relative to line position
        avgCadenceLine.lineDashLengths = [5]
        avgCadenceLine.lineColor = .yellow
        chartView.rightAxis.addLimitLine(avgCadenceLine)
    }
    

}
