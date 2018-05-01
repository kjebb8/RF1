//
//  DoubleExtension.swift
//  RF1_iOS
//
//  Created by Keegan Jebb on 2018-05-01.
//  Copyright © 2018 Keegan Jebb. All rights reserved.
//

import Foundation

extension Double {
    
    var roundedIntString: String {return String((Int(self.rounded())))} //Used for cadence string conversions
}
