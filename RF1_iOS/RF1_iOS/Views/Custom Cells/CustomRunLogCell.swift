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
    
    @IBOutlet weak var chartView: LineChartView!

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    
}
