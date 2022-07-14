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

// Creates a new BluetoothManager struct, which manages CoreBluetooth functions and objects
final class BluetoothManager: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    private var centralManager: CBCentralManager!
    
    @Published var mainPeripheral: CBPeripheral!
    @Published private var txCharacteristic: CBCharacteristic!
    @Published private var rxCharacteristic: CBCharacteristic!

    @Published var scanning = false
    var peripherals: [CBPeripheral]?
    var stateSubject: PassthroughSubject<CBManagerState, Never> = .init()
    var peripheralSubject: PassthroughSubject<CBPeripheral, Never> = .init()
    
    override init() {
        super.init()
        
        centralManager = .init(delegate: self, queue: .main)
    }
    
    // These are the functions for the central manager
    
    // Is called on the update of the central manager's state
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
      
       switch central.state {
            case .poweredOff:
                print("Bluetooth is off")
            case .poweredOn:
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
    
    // Is called on the discovery of a bluetooth device
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral,advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        print("Discovered peripheral \(peripheral.name ?? "Unknown Device")")
        setMainPeripheral(peripheral: peripheral)
        stopScanning()
        connectToMainPeripheral()
    }
    
    // Is called on the connection to a bluetooth device
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Connected to peripheral \(peripheral.name ?? "Unknown Device")")
        mainPeripheral.discoverServices([CBUUIDs.BLEService_UUID])
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("Failed to connect to peripheral \(peripheral.name ?? "Unknown Device")")
        print("Had error \(error?.localizedDescription ?? "none")")
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("Disconnected from peripheral \(peripheral.name ?? "Unknown Device")")
        startScanning()
        delMainPeripheral()
    }
    
    // These are the functions for the peripheral we discovered

    // Is called on the update of the peripheral's state
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
      switch peripheral.state {
      case .poweredOn:
          print("Peripheral Is Powered On.")
      case .unsupported:
          print("Peripheral Is Unsupported.")
      case .unauthorized:
      print("Peripheral Is Unauthorized.")
      case .unknown:
          print("Peripheral Unknown")
      case .resetting:
          print("Peripheral Resetting")
      case .poweredOff:
        print("Peripheral Is Powered Off.")
      @unknown default:
        print("Error")
      }
    }
    
    // Is called on discovering services
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        print("*******************************************************")

        if ((error) != nil) {
            print("Error discovering services: \(error!.localizedDescription)")
            return
        }
        guard let services = peripheral.services else {
            return
        }
        // We need to discover the all characteristics
        for service in services {
            print("Discovered service: \(service.uuid)")
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    // Is called on discovering characteristics
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
            guard let characteristics = service.characteristics else { return }

            print("Found \(characteristics.count) characteristics.")

            for characteristic in characteristics {
                if characteristic.uuid.isEqual(CBUUIDs.BLE_Characteristic_uuid_Rx)  {
                    setRxCharacteristic(characteristic: characteristic)

                    peripheral.setNotifyValue(true, for: rxCharacteristic!)
                    peripheral.readValue(for: characteristic)

                    print("RX Characteristic: \(rxCharacteristic.uuid)")
                }

                if characteristic.uuid.isEqual(CBUUIDs.BLE_Characteristic_uuid_Tx){
                    setTxCharacteristic(characteristic: characteristic)
                    print("TX Characteristic: \(txCharacteristic.uuid)")
                }
            }
    }
    
    // Is called when we read data from a characteristic
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic:   CBCharacteristic, error: Error?) {
        guard characteristic == rxCharacteristic,
        let characteristicValue = characteristic.value,
        let ASCIIstring = NSString(data: characteristicValue, encoding: String.Encoding.utf8.rawValue) else {
            return
        }

        let read = ASCIIstring as String
        
        switch read {
        case "ok":
            print("Data was sent successfuly")
        case "incorrect railway color":
            print("Railway color does not exist")
        default:
            print("Value Recieved: \(read)")
        }
        
    }
    
    func setMainPeripheral(peripheral: CBPeripheral) {
        mainPeripheral = peripheral
        mainPeripheral.delegate = self
    }
    
    func delMainPeripheral() {
        mainPeripheral = nil
    }
    
    func setRxCharacteristic(characteristic: CBCharacteristic) {
        rxCharacteristic = characteristic
    }
    
    func setTxCharacteristic(characteristic: CBCharacteristic) {
        txCharacteristic = characteristic
    }
    
    func sendData(data: String) {
        let valueString = (data as NSString).data(using: String.Encoding.utf8.rawValue)
        
        if let mainPeripheral = mainPeripheral {
            if let txCharacteristic = txCharacteristic {
                mainPeripheral.writeValue(valueString!, for: txCharacteristic, type: CBCharacteristicWriteType.withoutResponse)
            }
        }
    }
    
    func startScanning() {
        // scans for peripherals to connect to
        centralManager?.scanForPeripherals(withServices: [CBUUIDs.BLEService_UUID])
        scanning = true
        print("started scanning")
    }
    
    func stopScanning() {
        centralManager?.stopScan()
        scanning = false
    }
    
    private func connectToMainPeripheral() {
        centralManager.connect(mainPeripheral)
    }
    
    func disconnectFromMainPeripheral () {
        if mainPeripheral != nil {
            centralManager?.cancelPeripheralConnection(mainPeripheral!)
            mainPeripheral = nil
        }
    }
}

struct CBUUIDs {
    static let kBLEService_UUID = "a73ba101-8192-4a51-b42d-ae9cd14b14a5" // custom service id so we can ID loop-track devices
    static let kBLE_Characteristic_uuid_Tx = "6e400002-b5a3-f393-e0a9-e50e24dcca9e"
    static let kBLE_Characteristic_uuid_Rx = "6e400003-b5a3-f393-e0a9-e50e24dcca9e"

    static let BLEService_UUID = CBUUID(string: kBLEService_UUID)
    static let BLE_Characteristic_uuid_Tx = CBUUID(
        string: kBLE_Characteristic_uuid_Tx
    ) //(Property = Write without response)
    static let BLE_Characteristic_uuid_Rx = CBUUID(
        string: kBLE_Characteristic_uuid_Rx
    ) // (Property = Read/Notify)
}
