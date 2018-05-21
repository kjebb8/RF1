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
    case foreStrike
    case midStrike
    case heelStrike
    case noActionRequired
}


class BLEDataManager {
    
    private var fsrDataArray = [Int16]()
    
    private var delegateVC: BLEDataManagerDelegate?
    
    var heelVoltage: Int = 0 //Could make private if not printing out to label
    var forefootVoltage: Int = 0 //Could make private if not printing out to label
    
    private var heelVoltageCouple: [Int] = [0,0]
    private var forefootVoltageCouple: [Int] = [0,0]
    
    private var newHeelDown: Bool = false
    private var oldHeelDown: Bool = false
    
    private var newForefootDown: Bool = false
    private var oldForefootDown: Bool = false
    
    private let upperMVLimit: Int = 2900
    private let lowerMVLimit: Int = 2700
    
    private var logRawData: Bool = false
    private var clearRawData: Bool = false //BIG RED BUTTON for FSR Data. Must comment out this line in BLEManager "delegateVC?.updateUIForBLEState(bleState)" (line 75)
    
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
        
        heelVoltageCouple.remove(at: 0)
        heelVoltageCouple.append(heelVoltage)
        
        forefootVoltageCouple.remove(at: 0)
        forefootVoltageCouple.append(forefootVoltage)
        
        if oldHeelDown && (heelVoltageCouple[0] < lowerMVLimit) && (heelVoltageCouple[1] < lowerMVLimit) {
            newHeelDown = false
        } else if !oldHeelDown && ((heelVoltageCouple[0] > upperMVLimit) || (heelVoltageCouple[1] > upperMVLimit)) {
            newHeelDown = true
        }
     
        if oldForefootDown && (forefootVoltageCouple[0] < lowerMVLimit) && (forefootVoltageCouple[1] < lowerMVLimit) {
            newForefootDown = false
        } else if !oldForefootDown && ((forefootVoltageCouple[0] > upperMVLimit) || (forefootVoltageCouple[1] > upperMVLimit)) {
            newForefootDown = true
        }
        
        if (oldHeelDown || oldForefootDown) && (!newHeelDown && !newForefootDown) { //When foot lifts up after stepping
            delegateVC?.didFinishDataProcessing(withReturn: .didTakeStep)
        }
        
        if (!oldHeelDown && !oldForefootDown) {
            
            if (newHeelDown && newForefootDown) {delegateVC?.didFinishDataProcessing(withReturn: .midStrike)}
            else if (newHeelDown) {delegateVC?.didFinishDataProcessing(withReturn: .heelStrike)}
            else if (newForefootDown){delegateVC?.didFinishDataProcessing(withReturn: .foreStrike)}
        }
        
        oldHeelDown = newHeelDown
        oldForefootDown = newForefootDown
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
    
    
    private func clearRealm() { //Must comment out this line in BLEManager "delegateVC?.updateUIForBLEState(bleState)" (line 75)
        
        let oldData: Results<FSRData> = realm!.objects(FSRData.self)
        for fsrResult in oldData {
            do {
                try realm?.write {
                    realm?.delete(fsrResult)
                }
            } catch {
                print("Error deleting \(error)")
            }
        }
    }
    
    
}
