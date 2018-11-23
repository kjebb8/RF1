//
//  TimeFunctionExtensions.swift
//  RF1_iOS
//
//  Created by Keegan Jebb on 2018-03-17.
//  Copyright © 2018 Keegan Jebb. All rights reserved.
//

import Foundation


//MARK: - Extension for time conversions

extension Int {
    
    var inMinutes: Double {return Double(self) / 60}
    
    var hours: Int {return self / 3600}
    var minutes: Int {return self / 60 % 60}
    var seconds: Int {return self % 60}
    
    func getFormattedRunTimeString() -> (String) {
        
        if self.hours >= 1 {
            return String(format: "%i:%02i:%02i", self.hours, self.minutes, self.seconds)
        } else {
            return String(format: "%i:%02i", self.minutes, self.seconds)
        }
    }
}
