//
//  ContentView.swift
//  LoopTracksUI
//
//  Created by Ian Pratt on 7/11/22.
//

import SwiftUI

struct ContentView: View {
    @State private var scanningDone = false
    @State private var wifiDone = false
    @State private var trainSystemDone = false
    @State private var trainSystem = "cta"
    @State private var resetConfirmation = false
    
    
    @ObservedObject private var btManager: BluetoothManager = BluetoothManager()
    
    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                if scanningDone {
                    WifiView(done: $wifiDone, setWifiFunction: SetWifi)
                
                    if wifiDone {
                        Spacer()
                        
                        TrainSystemView(done: $trainSystemDone, trainSystem: $trainSystem, setTrainSystemFunction: SetTrainSystem)

                        if trainSystemDone {
                            Spacer()
                            
                            ColorView(trainSystem: $trainSystem, setColorFunction: SetColor)
                        }
                    }
                    
                    Spacer()
                    
                    Button("Reset config", role: .destructive) {
                        resetConfirmation = true
                    }
                    .padding()
                    .confirmationDialog("Are you sure you want to reset?", isPresented: $resetConfirmation) {
                        Button("Yes", role: .destructive) {
                            Reset()
                        }
                    }
                } else {
                    ScanningView(done: $scanningDone, isScanning: $btManager.scanning)
                }
            }
                .navigationTitle(
                    btManager.mainPeripheral != nil
                        ? "Connected to \(btManager.mainPeripheral.name ?? "Unknown device")"
                        : "Not Connected"
                )
                .navigationBarTitleDisplayMode(.inline)
                .onChange(of: btManager.scanning) { isScanning in
                    scanningDone = false
                }
        }
    }
    
    func SetWifi(wifiSSID: String, wifiPass: String) -> Error? {
        if wifiSSID == "" {
            return WifiError.NoSSID("Please set the wifi SSID")
        } else if wifiPass == "" {
            return WifiError.NoPass("Please set the wifi password")
        } else {
            print("Sending wifi \(wifiSSID)")
            btManager.sendData(data: "wifi:\(wifiSSID),\(wifiPass)")
            wifiDone = true
            return nil
        }
    }
    
    func SetTrainSystem(trainSystem: String) -> Error? {
        print("Sending train system \(trainSystem)")
        btManager.sendData(data: "city:\(trainSystem)")
        return nil
    }
    
    func SetColor(color: String) -> Error? {
        print("Sending color \(color)")
        btManager.sendData(data: "color:\(color)")
        return nil
    }
    
    func Reset() {
        scanningDone = !btManager.scanning
        // we skip past the wifiDone b/c argon remembers wifi
        trainSystemDone = false
        print("Sending reset")
        btManager.sendData(data: "reset")
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
