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
        tableView.rowHeight = 130
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
        return (runLog?.count ?? 1)
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "customRunLogCell", for: indexPath) as! CustomRunLogCell

         if let runEntry = runLog?[indexPath.row] {
            
            let requiredMetrics = RequiredCadenceMetrics(includeCadenceRawData: false, includeCadenceMovingAverage: true, includeWalkingData: true)
            let returnData = getFormattedCadenceChartData(forEntry: runEntry, withMetrics: requiredMetrics)
            
            let cadenceChartData = returnData.chartData
            let specificAverageCadence = returnData.averageCadence
            
            cell.chartView.chartDescription = nil //Label in bottom right corner
            cell.chartView.xAxis.drawLabelsEnabled = false
            cell.chartView.xAxis.drawGridLinesEnabled = false
            cell.chartView.leftAxis.drawLabelsEnabled = false
            cell.chartView.leftAxis.drawGridLinesEnabled = false
            cell.chartView.rightAxis.enabled = false
            cell.chartView.legend.enabled = false
            cell.chartView.data = cadenceChartData
            
            cell.dateLabel.text = runEntry.date
            cell.durationLabel.text = runEntry.runDuration.getFormattedRunTimeString()
            cell.timeLabel.text = runEntry.startTime
            cell.cadenceLabel.text = specificAverageCadence.roundedIntString
            cell.layer.borderWidth = 5
            cell.layer.borderColor = UIColor.black.cgColor
        }
        
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToRunStats", sender: self)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let destinationVC = segue.destination as! RunStatsTableViewController
        
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedRun = runLog?[indexPath.row]
        }
    }
    
    
    //MARK: - Realm Data Management Methods
    
    func loadRunLog() {
        
        let realm = try! Realm()
        runLog = realm.objects(RunLogEntry.self)
        tableView.reloadData()
    }

}
