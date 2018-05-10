//
//  BLEDataProcessor.swift
//  RF1_iOS
//
//  Created by Keegan Jebb on 2018-03-27.
//  Copyright © 2018 Keegan Jebb. All rights reserved.
//

import Foundation
import RealmSwift

protocol BLEDataManagerDelegate {
    func didFinishDataProcessing(withReturn returnValue: BLEDataManagerReturn)
}

enum BLEDataManagerReturn {
    
    case didTakeStep
    case noActionRequired
}


class BLEDataManager {
    
    private var fsrDataArray = [Int16]()
    
    private var delegateVC: BLEDataManagerDelegate?
    
    var heelVoltage: Int = 0 //Could make private if not printing out to label
    
    var forefootVoltage: Int = 0 //Could make private if not printing out to label
    
    private var newHeelDown: Bool = false
    private var oldHeelDown: Bool = false
    
    private var newForefootDown: Bool = false
    private var oldForefootDown: Bool = false
    
    private var logRawData: Bool = false
    private var clearRawData: Bool = false //BIG RED BUTTON
    
    init(delegate: BLEDataManagerDelegate) {
        
        delegateVC = delegate
        initializeFsrDataArray()
        
        if logRawData {
            
            setUpRealm()
            if clearRawData {clearRealm()}
        }
    }
    
    
    private func initializeFsrDataArray() {
        
        for _ in 0..<PeripheralDevice.numberOfSensors {
            fsrDataArray.append(0)
        }
    }
    
    
    func processNewData(updatedData data: Data) { //Public Access
        
        saveFsrData(dataToBeSaved: data)
        
        newForefootDown = forefootVoltage > 2500 ? true : false

        newHeelDown = heelVoltage > 2500 ? true : false
        
        if (oldForefootDown || oldHeelDown) && (!newForefootDown && !newHeelDown) { //When foot lifts up after stepping
            delegateVC?.didFinishDataProcessing(withReturn: .didTakeStep)
        }
        
        oldForefootDown = newForefootDown
        oldHeelDown = newHeelDown
    }
    
    
    private func saveFsrData(dataToBeSaved data: Data) {
        
        //1. Get a pointer (ptr) to the data value (size of Int16) in the Data buffer
        //2. Advance the pointer if necessary
        //3. Put the value ptr points to into the appropriate index of fsrDataArray
        for i in 0...(fsrDataArray.count - 1) {
            fsrDataArray[i] = data.withUnsafeBytes { (ptr: UnsafePointer<Int16>) in
                ptr.advanced(by: i).pointee
            }
        }
        
        heelVoltage = Int(fsrDataArray[0])
        forefootVoltage = Int(fsrDataArray[1])
        
        if logRawData {logData(forefootVoltage, heelVoltage)}
    }
    
    
    
    //MARK: - Realm Content
    
    private var realm: Realm?
    
    private var dataLogIndex: Int?
    
    private func setUpRealm() {
        
        realm = try! Realm()
        dataLogIndex = 0
    }
    
    private func logData(_ forefootVoltage: Int, _ heelVoltage: Int) {
        
        dataLogIndex! += 1
        let newFSRData = FSRData()
        newFSRData.heelVoltageData = heelVoltage
        newFSRData.forefootVoltageData = forefootVoltage
        newFSRData.sampleIndex = dataLogIndex!

        do {
            try realm?.write {
                realm?.add(newFSRData)
            }
        } catch {
            print("Error saving context \(error)")
        }
    }
    
    
    private func clearRealm() {
        
        try! realm?.write {
            realm?.deleteAll()
        }
    }
    
    
}
