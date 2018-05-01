//
//  RunLogEntry.swift
//  RF1_iOS
//
//  Created by Keegan Jebb on 2018-04-20.
//  Copyright © 2018 Keegan Jebb. All rights reserved.
//

import Foundation
import RealmSwift

class RunLogEntry: Object {
    
    @objc dynamic var date: String = ""
    @objc dynamic var startTime: String = ""
    @objc dynamic var runDuration: String = ""
    
    @objc dynamic var cadenceData: CadenceData?
}
