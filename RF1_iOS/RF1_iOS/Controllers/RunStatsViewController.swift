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
        
        showCadenceInfo()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func showCadenceInfo() {
        
        avgCadenceLabel.text = "Avg. Cadence: " + String((Int(selectedRun!.cadenceData!.averageCadence.rounded()))) + " steps/min"
        
        if let cadenceLog = selectedRun?.cadenceData?.cadenceLog {
        
            var cadenceDataEntries = [ChartDataEntry]()
        
            for i in 0..<cadenceLog.count {
                
                let cadenceTime = (Double((i + 1) * CadenceParameters.cadenceLogTime) / 60.0)
                cadenceDataEntries.append(ChartDataEntry(x: cadenceTime, y: cadenceLog[i].cadenceIntervalValue))
            }
        
            setChart(withData: cadenceDataEntries, dataLabel: "Cadence (steps/min)")
        }
    }

    
    func setChart(withData chartDataEntries: [ChartDataEntry], dataLabel: String) {
        
        let chartDataSet = LineChartDataSet(values: chartDataEntries, label: dataLabel)
        
        chartDataSet.setColor(UIColor.cyan) //Colour of line
        chartDataSet.lineWidth = 1
        chartDataSet.drawValuesEnabled = false //Doesn't come up if too many points
        chartDataSet.drawCirclesEnabled = false
        chartDataSet.mode = .cubicBezier //Makes curves smooth
        
        let gradientColors = [ChartColorTemplates.colorFromString("#005454").cgColor,
                              UIColor.cyan.cgColor]
        
        let gradient = CGGradient(colorsSpace: nil, colors: gradientColors as CFArray, locations: nil)!
        chartDataSet.fillAlpha = 0.8
        chartDataSet.fill = Fill(linearGradient: gradient, angle: 90)
        chartDataSet.drawFilledEnabled = true //Fill under the curve
        
        chartView.chartDescription = nil //Label in bottom right corner
        chartView.xAxis.labelPosition = .bottom
        chartView.xAxis.labelTextColor = .white
        chartView.leftAxis.labelTextColor = .white
        chartView.rightAxis.labelTextColor = .white
        chartView.legend.textColor = .white
        
        chartView.animate(xAxisDuration: 1.5)
        
        let chartData = LineChartData(dataSet: chartDataSet)
        chartView.data = chartData
        
        let avgCadenceLine = ChartLimitLine(limit: (selectedRun?.cadenceData?.averageCadence)! , label: "Avg. Cadence")
        avgCadenceLine.valueTextColor = .white
        avgCadenceLine.labelPosition = .rightTop //Relative to line position
        avgCadenceLine.lineDashLengths = [5]
        avgCadenceLine.lineColor = .yellow
        chartView.rightAxis.addLimitLine(avgCadenceLine)
    }
    

}
