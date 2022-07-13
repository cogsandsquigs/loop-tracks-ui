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

/// Creates a new BluetoothManager struct, which manages CoreBluetooth functions and objects
final class BluetoothManager: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    private var centralManager: CBCentralManager!
    
    var mainPeripheral: CBPeripheral!

    var btOn = false
    var peripherals: [CBPeripheral]?
    var stateSubject: PassthroughSubject<CBManagerState, Never> = .init()
    var peripheralSubject: PassthroughSubject<CBPeripheral, Never> = .init()
    
    override init() {
        super.init()
        
        centralManager = .init(delegate: self, queue: .main)
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
      
       switch central.state {
            case .poweredOff:
                btOn = false
                print("Bluetooth is off")
            case .poweredOn:
                btOn = true
                print("Bluetooth is on")
                startScanning()
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
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral,advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        setMainPeripheral(peripheral: peripheral)

        print("Peripheral Discovered: \(peripheral)")
        print("Peripheral name: \(String(describing: peripheral.name))")
        print ("Advertisement Data : \(advertisementData)")
            
        stopScanning()
    }
    
    func setMainPeripheral(peripheral: CBPeripheral) {
        mainPeripheral = peripheral
        mainPeripheral.delegate = self
        objectWillChange.send()
    }
    
    func startScanning() {
        // scans for peripherals to connect to
        centralManager?.scanForPeripherals(withServices: [CBUUIDs.BLEService_UUID])
    }
    
    func stopScanning() {
        centralManager?.stopScan()
    }
    
    private func connect(_ peripheral: CBPeripheral) {
        centralManager.stopScan()
        peripheral.delegate = self
        centralManager.connect(peripheral)
    }
}

struct CBUUIDs {
    static let kBLEService_UUID = "123A"
    static let kBLE_Characteristic_uuid_Tx = "123B"
    static let kBLE_Characteristic_uuid_Rx = "123C"

    static let BLEService_UUID = CBUUID(string: kBLEService_UUID)
    static let BLE_Characteristic_uuid_Tx = CBUUID(
        string: kBLE_Characteristic_uuid_Tx
    ) //(Property = Write without response)
    static let BLE_Characteristic_uuid_Rx = CBUUID(
        string: kBLE_Characteristic_uuid_Rx
    ) // (Property = Read/Notify)
}
