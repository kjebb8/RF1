//
//  RunLogCell.swift
//  RF1_iOS
//
//  Created by Keegan Jebb on 2018-04-26.
//  Copyright © 2018 Keegan Jebb. All rights reserved.
//

import UIKit
import Charts

class CustomRunLogCell: UITableViewCell {
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var cadenceLabel: UILabel!
    
    @IBOutlet weak var chartView: BarChartView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    
    func setCellUI(forRunEntry runEntry: RunLogEntry) {
        
        let footstrikeData = getFormattedRealmFootstrikeBarChartData(forEntry: runEntry)
        
        chartView.chartDescription = nil
        
        chartView.xAxis.valueFormatter = FootstrikeBarChartFormatter()
        chartView.xAxis.labelPosition = .bottom
        chartView.xAxis.labelTextColor = UIColor.lightGray
        chartView.xAxis.drawGridLinesEnabled = false
        chartView.xAxis.drawAxisLineEnabled = false
        chartView.xAxis.labelCount = 3
        chartView.xAxis.labelFont = .boldSystemFont(ofSize: 10)
        
        chartView.rightAxis.enabled = false
        
        chartView.leftAxis.enabled = false
        
        chartView.legend.enabled = false
        
        chartView.data = footstrikeData
        chartView.data!.setValueFormatter(IntPercentFormatter())
        
        dateLabel.text = runEntry.date?.getDateString()
        durationLabel.text = runEntry.runDuration.getFormattedRunTimeString()
        timeLabel.text = runEntry.startTime
        cadenceLabel.text = runEntry.averageCadenceRunningOnly.roundedIntString
        layer.borderWidth = 3
        layer.borderColor = UIColor.black.cgColor
    }
    
    
}
