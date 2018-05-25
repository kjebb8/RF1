//
//  StringExtension.swift
//  RF1_iOS
//
//  Created by Keegan Jebb on 2018-05-25.
//  Copyright © 2018 Keegan Jebb. All rights reserved.
//

import Foundation

extension Date {
    
    func getDateString() -> (String) {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        dateFormatter.locale = Locale(identifier: "en_US")
        return dateFormatter.string(from: self)
    }
    
    
    func getStartTimeString() -> (String) {
        
        let formatterTime = DateFormatter()
        formatterTime.dateFormat = "hh:mm a"
        return formatterTime.string(from: self)
    }
}
