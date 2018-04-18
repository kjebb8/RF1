//
//  FSRDataLog.swift
//  RF1_iOS
//
//  Created by Keegan Jebb on 2018-04-16.
//  Copyright © 2018 Keegan Jebb. All rights reserved.
//

import Foundation
import RealmSwift

class FSRData: Object {
    
    @objc dynamic var forefootVoltageData: Int = 0
    @objc dynamic var heelVoltageData: Int = 0
    @objc dynamic var sampleIndex: Int = 0
}
