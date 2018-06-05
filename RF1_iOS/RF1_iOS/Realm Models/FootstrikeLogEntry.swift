//
//  FootstrikeLogEntry.swift
//  RF1_iOS
//
//  Created by Keegan Jebb on 2018-05-21.
//  Copyright © 2018 Keegan Jebb. All rights reserved.
//

import Foundation
import RealmSwift

class FootstrikeLogEntry: Object {
    
    @objc dynamic var foreIntervalValue: Int = 0
    @objc dynamic var midIntervalValue: Int = 0
    @objc dynamic var heelIntervalValue: Int = 0
}
