//
//  StepTimeData.swift
//  RF1_iOS
//
//  Created by Keegan Jebb on 2018-06-18.
//  Copyright © 2018 Keegan Jebb. All rights reserved.
//

import Foundation
import RealmSwift

class StepTimeData: Object {
    
    @objc dynamic var stepTime: Double = 0
    @objc dynamic var logInterval: Int = 0
}
