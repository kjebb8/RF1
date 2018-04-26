//
//  RunStatsTableViewController.swift
//  RF1_iOS
//
//  Created by Keegan Jebb on 2018-04-25.
//  Copyright © 2018 Keegan Jebb. All rights reserved.
//

import UIKit
import RealmSwift
import Charts
import ChartsRealm

class RunStatsViewController: UIViewController {
    
    let realm = try! Realm()
    
    var selectedRun: RunLogEntry?

    @IBOutlet weak var avgCadenceLabel: UILabel!
    @IBOutlet weak var chartView: BarChartView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        avgCadenceLabel.text = "Avg. Cadence: " + String((Int(selectedRun!.cadenceData!.averageCadence.rounded()))) + " Steps/Min"
        
        setChart(xVals: [1, 2, 3, 4], yVals: [5, 6, 1, 7])
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }    

    
    func setChart(xVals: [Double], yVals: [Double]) {
        
        chartView.noDataText = "You need to provide data for the chart."
        
        var dataEntries = [BarChartDataEntry]()
        
        for i in 0..<xVals.count {
            let dataEntry = BarChartDataEntry(x: xVals[i], y: yVals[i])
            dataEntries.append(dataEntry)
        }
        
        let chartDataSet = BarChartDataSet(values: dataEntries, label: "Units Sold")
        let chartData = BarChartData(dataSets: [chartDataSet])
        chartView.data = chartData
    }

}
