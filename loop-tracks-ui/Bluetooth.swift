//
//  Bluetooth.swift
//  loop-tracks-ui
//
//  Created by Ian Pratt on 7/13/22.
//

import SwiftUI
import Foundation
import Combine
import CoreBluetooth

// manages bluetooth stuff for our app
final class BluetoothManager: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    private var centralManager: CBCentralManager!
    
    var stateSubject: PassthroughSubject<CBManagerState, Never> = .init()
    var peripheralSubject: PassthroughSubject<CBPeripheral, Never> = .init()
        
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
      
       switch central.state {
            case .poweredOff:
                print("Bluetooth is off")
            case .poweredOn:
                print("Bluetooth is on")
                //startScanning()
            case .unsupported:
                print("Bluetooth is unsupported")
            case .unauthorized:
                print("Bluetooth is unauthorized")
            case .unknown:
                print("Unknown state")
            case .resetting:
                print("Resetting...")
            @unknown default:
              print("Error")
            }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        peripheralSubject.send(peripheral)
    }
    
    func start() {
        centralManager = .init(delegate: self, queue: .main)
    }
    
    func connect(_ peripheral: CBPeripheral) {
        centralManager.stopScan()
        peripheral.delegate = self
        centralManager.connect(peripheral)
    }
}
