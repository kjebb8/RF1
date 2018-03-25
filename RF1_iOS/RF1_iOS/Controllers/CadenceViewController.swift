//
//  CadenceViewController.swift
//  RF1_iOS
//
//  Created by Keegan Jebb on 2018-03-15.
//  Copyright © 2018 Keegan Jebb. All rights reserved.
//

import UIKit
import CoreBluetooth

class CadenceViewController: UIViewController {
    
    @IBOutlet weak var shortCadenceLabel: UILabel!
    @IBOutlet weak var avgCadenceLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var stepsLabel: UILabel!
    
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var pauseButton: UIButton!
    
    let cadenceMetrics = CadenceMetrics(timeForShortCadenceInSeconds: 20)
    
    var isTimerPaused: Bool = false
    
    var runTime: Int = 0 //In seconds
    var runTimer = Timer()
    
    override func viewDidLoad() {
        super.viewDidLoad()

//        stopButton.imageView!.contentMode = UIViewContentMode.scaleAspectFit
//        pauseButton.imageView!.contentMode = UIViewContentMode.scaleAspectFit
        
        updateUI()
        
        initializeTimer()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //MARK: - Timer Methods
    
    func initializeTimer() {
        
        runTimer = Timer.scheduledTimer(
            timeInterval: 1,
            target: self,
            selector: (#selector(CadenceViewController.updateTimer)),
            userInfo: nil,
            repeats: true)
    }
    
    @objc func updateTimer() {
        
        runTime += 1
        cadenceMetrics.incrementSteps() //Will move
        cadenceMetrics.updateCadence(atTimeInMinutes: runTime)
        updateUI()
    }
    
    func updateUI() {
        
        shortCadenceLabel.text = "\(Int(cadenceMetrics.shortCadence.rounded()))"
        avgCadenceLabel.text = "\(Int(cadenceMetrics.averageCadence.rounded()))"
        timeLabel.text = getFormattedTimeString()
        stepsLabel.text = "\(cadenceMetrics.totalSteps)"
    }
    
    func getFormattedTimeString() -> (String) {
        
        if runTime.hours >= 1 {
            return String(format: "%i:%02i:%02i", runTime.hours, runTime.minutes, runTime.seconds)
        } else {
            return String(format: "%i:%02i", runTime.minutes, runTime.seconds)
        }
        
    }
    
    
    //MARK: - Pressed UI button methods
    
    @IBAction func stopButtonPressed(_ sender: UIButton) {
        
        let alert = UIAlertController(title: "Stop Tracking?", message: "Your data will be lost", preferredStyle: .alert)

        let addAction = UIAlertAction(title: "Stop", style: .default) { (addAction) in
            self.runTimer.invalidate()
            self.dismiss(animated: true, completion: nil)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        
        alert.addAction(cancelAction)
        alert.addAction(addAction)
        
        alert.preferredAction = alert.actions[1]
        
        present(alert, animated: true, completion: nil)
    }
    
    
    @IBAction func pauseButtonPressed(_ sender: UIButton) {
        
        if isTimerPaused == false {
            runTimer.invalidate()
            isTimerPaused = true
            pauseButton.setTitle("Resume", for: .normal)
        } else {
            initializeTimer()
            isTimerPaused = false
            pauseButton.setTitle("Pause", for: .normal)
        }
    }
    
    
}


//MARK: - Bluetooth Central Delegate Extension Methods

extension CadenceViewController: CBCentralManagerDelegate {
    
    
    
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        //
    }
    
    
}
