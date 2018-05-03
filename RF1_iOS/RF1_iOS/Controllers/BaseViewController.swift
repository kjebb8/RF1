//
//  BaseViewController.swift
//  RF1_iOS
//
//  Created by Keegan Jebb on 2018-05-03.
//  Copyright © 2018 Keegan Jebb. All rights reserved.
//

import UIKit
import MessageUI

class BaseViewController: UIViewController, MFMailComposeViewControllerDelegate {
    
    @IBOutlet weak var feedbackButton: UIButton?
    @IBOutlet weak var feedbackBarButton: UIBarButtonItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        setFeedbackButtonDesign() //Creates an outline around the button
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func showAlert(title: String, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
        alert.addAction(okAction)
        
        present(alert, animated: true, completion: nil)
    }
    

    //MARK: - Feedback Email Methods
    
    func setFeedbackButtonDesign() {
        
        feedbackButton?.frame = CGRect(x: 0, y: 0, width: 100, height: 100) //width and height seem arbitrary
        feedbackButton?.layer.borderWidth = 1.0
        feedbackButton?.layer.borderColor = UIColor(white: 0.8, alpha: 1.0).cgColor
    }
    
    
    @IBAction func feedbackButtonPressed(_ sender: UIButton) {
        showFeedbackEmail()
    }
    
    
    @IBAction func feedbackBarButtonPressed(_ sender: Any) {
        showFeedbackEmail()
    }
    
    
    func showFeedbackEmail() {
        
        if MFMailComposeViewController.canSendMail() {
            
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["enpact.tech@gmail.com"])
            mail.setSubject("Enpact App Feedback")
            mail.setMessageBody("", isHTML: false)
            present(mail, animated: true, completion: nil)
            
        } else {
            
            showAlert(title: "Could Not Send Email", message: "Device could not send e-mail")
            print("Failed Email")
        }
    }
    
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    
}
