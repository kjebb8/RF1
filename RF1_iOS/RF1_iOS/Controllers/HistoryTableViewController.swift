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

class HistoryTableViewController: UITableViewController {
    
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
            
            cell.dateLabel.text = runEntry.date
            cell.durationLabel.text = runEntry.runDuration
            cell.timeLabel.text = runEntry.startTime
            cell.cadenceLabel.text = runEntry.cadenceData!.averageCadence.roundedIntString
            cell.layer.borderWidth = 5
            cell.layer.borderColor = UIColor.black.cgColor
            
            
            if let cadenceLog = runEntry.cadenceData?.cadenceLog {
                
                var cadenceDataEntries = [ChartDataEntry]()
                cadenceDataEntries.append(ChartDataEntry(x: 0, y: cadenceLog[0].cadenceIntervalValue))
                
                for i in 0..<cadenceLog.count {
                    
                    let cadenceTime = (Double((i + 1) * CadenceParameters.cadenceLogTime) / 60.0)
                    cadenceDataEntries.append(ChartDataEntry(x: cadenceTime, y: cadenceLog[i].cadenceIntervalValue))
                }
                
                let chartDataSet = LineChartDataSet(values: cadenceDataEntries, label: "Cadence (steps/min)")
                
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
                
                cell.chartView.chartDescription = nil //Label in bottom right corner
                cell.chartView.xAxis.drawLabelsEnabled = false
                cell.chartView.leftAxis.drawLabelsEnabled = false
                cell.chartView.rightAxis.drawLabelsEnabled = false
                cell.chartView.legend.enabled = false
                
                let chartData = LineChartData(dataSet: chartDataSet)
                cell.chartView.data = chartData
            }
            
            
            
        }
        
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToRunStats", sender: self)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! RunStatsViewController
        
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
