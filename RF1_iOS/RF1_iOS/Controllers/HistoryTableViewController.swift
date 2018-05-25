//
//  HistoryTableViewController.swift
//  RF1_iOS
//
//  Created by Keegan Jebb on 2018-04-25.
//  Copyright © 2018 Keegan Jebb. All rights reserved.
//

import UIKit
import RealmSwift
import Charts

class HistoryTableViewController: BaseTableViewController {
    
    var runLog: Results<RunLogEntry>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadRunLog()
        tableView.register(UINib(nibName: "RunLogCell", bundle: nil), forCellReuseIdentifier: "customRunLogCell")
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        loadRunLog()
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    // MARK: - Table View Data Source Methods

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (runLog?.count ?? -1) + 1 //No cell if no run log
    }
    
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        var cellHeight: CGFloat = 140
        
        if indexPath.row == 0 {cellHeight = 40}
        
        return cellHeight
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "tapForStatsCell")
            cell?.textLabel?.text = "Tap a Cell for Details"
            cell?.textLabel?.font = UIFont.boldSystemFont(ofSize: 20)
            cell?.textLabel?.textAlignment = .center
            cell?.backgroundColor = UIColor.clear
            
            return cell!
            
        } else {
        
            let cell = tableView.dequeueReusableCell(withIdentifier: "customRunLogCell", for: indexPath) as! CustomRunLogCell

             if let runEntry = runLog?[indexPath.row - 1] {
                
                let footstrikeData = getFormattedRealmFootstrikeBarChartData(forEntry: runEntry)
                
                cell.chartView.chartDescription = nil
                
                cell.chartView.xAxis.valueFormatter = FootstrikeBarChartFormatter()
                cell.chartView.xAxis.labelPosition = .bottom
                cell.chartView.xAxis.labelTextColor = UIColor.lightGray
                cell.chartView.xAxis.drawGridLinesEnabled = false
                cell.chartView.xAxis.drawAxisLineEnabled = false
                cell.chartView.xAxis.labelCount = 3
                cell.chartView.xAxis.labelFont = .boldSystemFont(ofSize: 10)
                
                cell.chartView.rightAxis.enabled = false
                
                cell.chartView.leftAxis.enabled = false
                
                cell.chartView.legend.enabled = false

                cell.chartView.data = footstrikeData
                cell.chartView.data!.setValueFormatter(IntPercentFormatter())
                
                cell.dateLabel.text = runEntry.date?.getDateString()
                cell.durationLabel.text = runEntry.runDuration.getFormattedRunTimeString()
                cell.timeLabel.text = runEntry.startTime
                cell.cadenceLabel.text = runEntry.averageCadenceRunningOnly.roundedIntString
                cell.layer.borderWidth = 3
                cell.layer.borderColor = UIColor.black.cgColor
            }
            
            return cell
        }
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToRunStats", sender: self)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let destinationVC = segue.destination as! RunStatsTableViewController
        
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedRun = runLog?[indexPath.row - 1]
        }
    }
    
    
    //MARK: - Realm Data Management Methods
    
    func loadRunLog() {
        
        let realm = try! Realm()
        runLog = realm.objects(RunLogEntry.self).sorted(byKeyPath: "date", ascending: false)
        tableView.reloadData()
    }

}
