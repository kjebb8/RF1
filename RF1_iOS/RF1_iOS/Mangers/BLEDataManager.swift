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


class BLEDataManager {
    
    private var fsrDataArray = [Int16]()
    
    private var delegateVC: BLEDataManagerDelegate?
    
    var heelVoltage: Int = 0 //Could make private if not printing out to label
    var forefootVoltage: Int = 0 //Could make private if not printing out to label
    
    private var heelForceCouple: [Double] = [0,0]
    private var forefootForceCouple: [Double] = [0,0]
    
    private var newHeelDown: Bool = false
    private var oldHeelDown: Bool = false
    
    private var newForefootDown: Bool = false
    private var oldForefootDown: Bool = false
    
    private var upperForceLimit: Double = 2650 //In grams
    private var lowerForceLimit: Double = 2300 //In grams
    
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
        
        heelForceCouple.remove(at: 0)
        heelForceCouple.append(calculateForce(forVoltage: heelVoltage))
        
        forefootForceCouple.remove(at: 0)
        forefootForceCouple.append(calculateForce(forVoltage: forefootVoltage))
        
        if oldHeelDown && (heelForceCouple[0] < lowerForceLimit) && (heelForceCouple[1] < lowerForceLimit) {
            newHeelDown = false
        } else if !oldHeelDown && ((heelForceCouple[0] > upperForceLimit) || (heelForceCouple[1] > upperForceLimit)) {
            newHeelDown = true
        }
        
        if oldForefootDown && (forefootForceCouple[0] < lowerForceLimit) && (forefootForceCouple[1] < lowerForceLimit) {
            newForefootDown = false
        } else if !oldForefootDown && ((forefootForceCouple[0] > upperForceLimit) || (forefootForceCouple[1] > upperForceLimit)) {
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
    
    
    private func calculateForce(forVoltage voltageInt: Int) -> Double { //Returns force in grams
        
        let voltage = Double(voltageInt)
        
        var force: Double = 25
        
        if voltage > 413 {
            
            let resistance = (3300 - voltage) * 10000 / voltage
            let logResistance = (log(resistance) / log(10)) //change base to 10
            force = pow(10, -1.391 * logResistance + 7.740) //From FSR data sheet calibration curve
        }
        
        return force
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
