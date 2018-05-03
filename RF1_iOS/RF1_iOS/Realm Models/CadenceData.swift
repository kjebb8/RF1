//
//  CadenceData.swift
//  RF1_iOS
//
//  Created by Keegan Jebb on 2018-04-20.
//  Copyright © 2018 Keegan Jebb. All rights reserved.
//

import Foundation
import RealmSwift

class CadenceData: Object {
    
    @objc dynamic var averageCadence: Double = 0
    
    let cadenceLog = List<CadenceLogEntry>()
}
