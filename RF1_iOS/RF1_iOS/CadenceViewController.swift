//
//  CadenceViewController.swift
//  RF1_iOS
//
//  Created by Keegan Jebb on 2018-03-15.
//  Copyright © 2018 Keegan Jebb. All rights reserved.
//

import UIKit

class CadenceViewController: UIViewController {

    @IBOutlet weak var shortCadenceLabelContainer: UIView!
    @IBOutlet weak var shortCadenceValueContainer: UIView!
    @IBOutlet weak var avgCadenceLabelContainer: UIView!
    @IBOutlet weak var avgCadenceValueContainer: UIView!
    @IBOutlet weak var timeLabelContainer: UIView!
    @IBOutlet weak var stepsLabelContainer: UIView!
    @IBOutlet weak var timeValueContainer: UIView!
    @IBOutlet weak var stepsValueContainer: UIView!
    @IBOutlet weak var stopContainer: UIView!
    @IBOutlet weak var pauseContainer: UIView!
    
    @IBOutlet weak var stopButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        stopButton.imageView!.contentMode = UIViewContentMode.scaleAspectFit
    }
    
//    override func viewDidAppear(_ animated: Bool) {
//
//      setUpUI()
//    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func stopButtonPressed(_ sender: UIButton) {
        
        dismiss(animated: true, completion: nil)
    }
    
    
//    func setUpUI() {
//
//
//    }

}
