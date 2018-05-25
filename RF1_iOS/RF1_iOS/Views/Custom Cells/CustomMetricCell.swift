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
    
    func loadNewChart(withData requiredData: RequiredChartData, forMetric metric: MectricType)
}


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
    
    var delegateVC: MetricCellDelegate?
    
    var cellMetric: MectricType!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    
    @IBAction func dataSwitched(_ sender: UISwitch) {
        
        delegateVC?.loadNewChart(withData: RequiredChartData(includeRawData: rawDataSwitch?.isOn ?? false,
                                                              includeMovingAverage: movingAverageSwitch?.isOn ?? true,
                                                              includeWalkingData: walkingDataSwitch.isOn), forMetric: cellMetric)
    }
}
