//
//  RunStatsTableViewController.swift
//  RF1_iOS
//
//  Created by Keegan Jebb on 2018-04-25.
//  Copyright © 2018 Keegan Jebb. All rights reserved.
//

import UIKit
import Charts


class RunStatsTableViewController: BaseTableViewController {
    
    var selectedRun: RunLogEntry?
    
    let metricKeys: [MetricType] = [.cadence, .footstrike] //Decides the order of Metric cells
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        tableView.register(UINib(nibName: "MetricCell", bundle: nil), forCellReuseIdentifier: "customMetricCell")
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Table View Data Source Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return metricKeys.count
    }
    
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let cellMetric: MetricType = metricKeys[indexPath.row]
        
        var cellHeight: CGFloat = 510
        
        if cellMetric == .footstrike {cellHeight = 500}
        
        return cellHeight
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "customMetricCell", for: indexPath) as! CustomMetricCell
        
        if let runEntry = selectedRun {cell.setUp(forRunEntry: runEntry, andCellMetric: metricKeys[indexPath.row])}
        
        return cell
    }
    

}
