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
    
//    var heelVoltage: Int = 0 //Could make private if not printing out to label
//    var forefootVoltage: Int = 0 //Could make private if not printing out to label
    
    private var heelForceFifo: [Double] = []
    private var forefootForceFifo: [Double] = []
    private let forceFifoSize: Int = 4
    
    private var heelReleaseForce: Double = 0
    private var forefootReleaseForce: Double = 0
    
    private var newHeelDown: Bool = false
    private var oldHeelDown: Bool = false
    
    private var newForefootDown: Bool = false
    private var oldForefootDown: Bool = false
    
    private let forceDerivativeLimit: Double = 500 //grams per 0.05 seconds
    private let upperForceLimit: Double = 4500 //grams
    private var lowerForceLimit: Double = 3000 //grams
    
    private let heelConstant1: Double = 1.8
    private let heelConstant2: Double = 2.0
    private let forefootConstant1: Double = 8.0
    private let midConstant1: Double = 3.0
    private let midConstant2: Double = 5.0
    private let midConstant3: Double = 2.0
    
    private let logRawData: Bool = true
    private let clearRawData: Bool = false //BIG RED BUTTON for FSR Data. Must comment out this line in BLEManager "delegateVC?.updateUIForBLEState(bleState)" (line 75)
    
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
    
    
//    func processNewData(updatedData data: Data) { //Public Access
    func analyze(_ heelVoltage: Int, _ forefootVoltage: Int) {
        
//        saveFsrData(dataToBeSaved: data)
        if logRawData {logData(forefootVoltage, heelVoltage)}
        
        if heelForceFifo.count < forceFifoSize {
            
            heelForceFifo.append(calculateForce(forVoltage: heelVoltage))
            forefootForceFifo.append(calculateForce(forVoltage: forefootVoltage))
            
        } else {
        
            heelForceFifo.remove(at: 0)
            heelForceFifo.append(calculateForce(forVoltage: heelVoltage))
        
            let heelDerivativeOld = heelForceFifo[1] - heelForceFifo[0]
            let heelDerivativeMiddle = heelForceFifo[2] - heelForceFifo[1]
            let heelDerivativeNew = heelForceFifo[3] - heelForceFifo[2]
        
            forefootForceFifo.remove(at: 0)
            forefootForceFifo.append(calculateForce(forVoltage: forefootVoltage))
        
            let forefootDerivativeOld = forefootForceFifo[1] - forefootForceFifo[0]
            let forefootDerivativeMiddle = forefootForceFifo[2] - forefootForceFifo[1]
            let forefootDerivativeNew = forefootForceFifo[3] - forefootForceFifo[2]
        
            if
                oldHeelDown && //If heel was down AND
                (heelForceFifo[0] < heelReleaseForce) && (heelForceFifo[1] < heelReleaseForce) { //Oldest two values are below where the pressure started, then heel comes up
                
                newHeelDown = false
               
            } else if
                !oldHeelDown && //If heel was previously up AND
                !oldForefootDown && //Forefoot was previously up (force rises after a minimum when forefoot is pushing off) AND
                    ((heelDerivativeOld > forceDerivativeLimit * heelConstant1) || //If the oldest slope is great enough OR
                        (heelDerivativeOld > forceDerivativeLimit && //If the oldest slope is moderate AND
                            heelDerivativeOld + heelDerivativeMiddle > forceDerivativeLimit * heelConstant2)) { //Sum of slopes is positive enough, then heel is down
                
                newHeelDown = true
//                heelReleaseForce = min(heelForceFifo[0] + 500, lowerForceLimit)
                heelReleaseForce = heelForceFifo[0] + 500
            }
        
            if
                oldForefootDown && //If forefoot was down AND
                (forefootForceFifo[0] < forefootReleaseForce) && (forefootForceFifo[1] < forefootReleaseForce) { //Oldest two values are below where the pressure started, then forefoot comes up when
                
                newForefootDown = false
                
            } else if
                !oldForefootDown && //If forefoot was previously up AND
                    ((forefootDerivativeOld > forceDerivativeLimit && //If the oldest slope is great enough AND
                        forefootDerivativeOld + forefootDerivativeMiddle + forefootDerivativeNew > forceDerivativeLimit * forefootConstant1) || //Sum of all three slopes is significant, then forefoot is down OR
                    forefootForceFifo[1] > upperForceLimit) { //The seconds oldest value is high enough (if there is a slow rise), then the forefoot is down
                
                newForefootDown = true
//                forefootReleaseForce = min(forefootForceFifo[0] + 500, lowerForceLimit)
                forefootReleaseForce = forefootForceFifo[0] + 500
            }
        
            if (oldForefootDown || oldHeelDown) && (!newForefootDown && !newHeelDown) { //When both parts of the foot are up after one of them is down
                delegateVC?.didFinishDataProcessing(withReturn: .didTakeStep)
            }
        
            if (!oldHeelDown && !oldForefootDown) { //If whole foot was up
                
                if (newHeelDown && newForefootDown) { //If heel and forefoot down at the same time
                    
                    //If the heel slope is significantly greater than the forefoot slope, it is a heel strike
                    //The same is done for forefoot, which biases the results to be harder to get midfoot strikes (as it should be)
                    if heelDerivativeOld > forefootDerivativeOld * midConstant1 {delegateVC?.didFinishDataProcessing(withReturn: .heelStrike)}
                    else if forefootDerivativeOld > heelDerivativeOld * midConstant1 {delegateVC?.didFinishDataProcessing(withReturn: .foreStrike)}
                    else {delegateVC?.didFinishDataProcessing(withReturn: .midStrike)}
                }
                    
                else if (newHeelDown) {delegateVC?.didFinishDataProcessing(withReturn: .heelStrike)} //If only heel went down
                    
                else if (newForefootDown){ //If only forefoot went down
                    
                    //If the newest forefoot slope is significantly greater than the earlier two, then:
                    //1)It could be counted as a heel strike if the heel was already going down during the middle slope or
                    //2)Counted as a midfoot strike if the new heel slope is similar to the new forefoot slope
                    if (forefootDerivativeNew > (forefootDerivativeOld + forefootDerivativeMiddle) * midConstant2) {
                        
                        if (heelDerivativeMiddle > forceDerivativeLimit && forefootDerivativeMiddle < 0) {delegateVC?.didFinishDataProcessing(withReturn: .heelStrike)}
                        else if (heelDerivativeNew > forefootDerivativeNew / midConstant3) {delegateVC?.didFinishDataProcessing(withReturn: .midStrike)}
                        else {delegateVC?.didFinishDataProcessing(withReturn: .foreStrike)}
                        
                    } else {delegateVC?.didFinishDataProcessing(withReturn: .foreStrike)}
                }
            }
        
            oldHeelDown = newHeelDown
            oldForefootDown = newForefootDown
        }
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
        
//        heelVoltage = Int(fsrDataArray[0])
//        forefootVoltage = Int(fsrDataArray[1])
//        
//        if logRawData {logData(forefootVoltage, heelVoltage)}
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
