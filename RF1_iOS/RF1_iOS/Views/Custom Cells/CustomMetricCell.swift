//
//  averageStatCell.swift
//  RF1_iOS
//
//  Created by Keegan Jebb on 2018-05-14.
//  Copyright © 2018 Keegan Jebb. All rights reserved.
//

import UIKit
import Charts

protocol MetricCellDelegate {
    
    func loadNewChart(withMetrics requiredMetrics: RequiredMetrics, atRow row: Int)
}


class CustomMetricCell: UITableViewCell {
    
    @IBOutlet weak var averageStatLabel: UILabel!
    
    @IBOutlet weak var chartView: LineChartView!
    
    @IBOutlet weak var rawDataSwitch: UISwitch!
    
    @IBOutlet weak var movingAverageSwitch: UISwitch!
    
    var delegateVC: MetricCellDelegate?
    
    var cellRow: Int = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    
    @IBAction func dataSwitched(_ sender: UISwitch) {
        
        delegateVC?.loadNewChart(withMetrics: RequiredMetrics(includeCadenceRawData: rawDataSwitch.isOn,
                                                              includeCadenceMovingAverage: movingAverageSwitch.isOn), atRow: cellRow)
    }
}
