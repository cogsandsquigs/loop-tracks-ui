//
//  ContentView.swift
//  loop-tracks-ui
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
            return Errors.WifiError("Please set the wifi SSID")
        } else if wifiPass == "" {
            return Errors.WifiError("Please set the wifi password")
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
        wifiDone = false
        trainSystemDone = false
        print("Sending reset")
        btManager.sendData(data: "reset")
    }
}

struct ScanningView: View {
    @Binding var done: Bool
    @Binding var isScanning: Bool
    
    init(done: Binding<Bool>, isScanning: Binding<Bool>) {
        self._done = done
        self._isScanning = isScanning
    }
    
    var body: some View {
        Text("Scanning...")
            .padding()
            .onChange(of: isScanning) { isScanning in
                done = !isScanning
            }
        ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .blue))
    }
}

// Holds the view for the wifi configuration page
struct WifiView: View {
    @State private var setWifi: (String, String) -> Error?
    @State private var wifiSSID = "WCL"
    @State private var wifiPass = "atmega328"
    @State private var wifiAlert = false
    @State private var wifiError: Error? = nil
    @Binding var done: Bool
    
    init(done: Binding<Bool>, setWifiFunction: @escaping (String, String) -> Error?) {
        self._done = done
        self.setWifi = setWifiFunction
    }
    
    var body: some View {
        Text("Set wifi SSID and password:")
            .bold()
        
        TextField("Set wifi SSID", text: $wifiSSID) {
            UIApplication.shared.endEditing()
        }
            .padding()
        
        SecureField("Set wifi Password", text: $wifiPass) {
            UIApplication.shared.endEditing()
        }
            .padding()
        
        Button("Send the wifi configuration.") {
            let err = setWifi(wifiSSID, wifiPass)
            if let err = err {
                wifiAlert = true
                wifiError = err
            } else {
                wifiAlert = false
                done = true
            }
        }
            .padding()
            .overlay(
                RoundedRectangle(cornerRadius: 10.0)
                    .stroke(.blue)
            )
            .alert(wifiError?.localizedDescription ?? "No Error", isPresented: $wifiAlert) {
                Button("Ok", role: .cancel) {}
            }
    }
}

struct TrainSystemView: View {
    @State private var setTrainSystem: (String) -> Error?
    @State private var lastUpdatedTrainSystem = ""
    @Binding var trainSystem: String
    @Binding var done: Bool
    
    init(done: Binding<Bool>, trainSystem: Binding<String>, setTrainSystemFunction: @escaping (String) -> Error?) {
        self.setTrainSystem = setTrainSystemFunction
        self._done = done
        self._trainSystem = trainSystem
    }
    
    var body: some View {
        Text("Select a train system:")
            .bold()
        
        Picker("Select a train system", selection: $trainSystem.onChange(onPickerChange)) {
            Text("cta").tag("cta")
            Text("mbta").tag("mbta")
        }
            
        
        Button("Set the train system to the \(trainSystem)")  {
            lastUpdatedTrainSystem = trainSystem
            let err = setTrainSystem(trainSystem)
            done = err == nil
        }
            .padding()
            .overlay(
                RoundedRectangle(cornerRadius: 10.0)
                    .stroke(.blue)
            )
    }
    
    func onPickerChange(_ tag: String) {
        done = false
    }
}

struct ColorView: View {
    @State private var setColor: (String) -> Error?
    @State private var color: String = "red"
    
    @State private var ctaEntries = [
        "pink": "Pink",
        "red": "Red",
        "orange": "Orange",
        "green1": "South Green",
        "green2": "West Green",
        "blue": "Blue",
        "brown": "Brown/Purple",
    ]
    @State private var mbtaEntries = [
        "red": "Red",
        "orange": "Orange",
        "green1": "Green Main",
        "green2": "Green E",
        "blue": "Blue",
    ]
    
    @Binding var trainSystem: String
    
    init(trainSystem: Binding<String>, setColorFunction: @escaping (String) -> Error?) {
        self.setColor = setColorFunction
        self._trainSystem = trainSystem
    }
    
    var body: some View {
        Text("Select a train line color corresponding to the flashing line:")
            .bold()
        
        switch trainSystem {
        case "cta":
            Picker("Select a train line color", selection: $color) {
                ForEach(ctaEntries.sorted(by: >), id: \.key) { (tag, name) in
                    Text(name).tag(tag)
                }
            }
                .pickerStyle(MenuPickerStyle())
        case "mbta":
            Picker("Select a train line color", selection: $color) {
                ForEach(mbtaEntries.sorted(by: >), id: \.key) { (tag, name) in
                    Text(name).tag(tag)
                }
            }
                .pickerStyle(MenuPickerStyle())
        default:
            Picker("Select a train line color", selection: $color) { }
        }
        
        Button("Set the train line color")  {
            ctaEntries.removeValue(forKey: color)
            mbtaEntries.removeValue(forKey: color)
            setColor(color)
        }
            .padding()
            .overlay(
                RoundedRectangle(cornerRadius: 10.0)
                    .stroke(.blue)
            )
            .onAppear {
                ctaEntries = [
                    "pink": "Pink",
                    "red": "Red",
                    "orange": "Orange",
                    "green1": "South Green",
                    "green2": "West Green",
                    "blue": "Blue",
                    "brown": "Brown/Purple",
                ]
                mbtaEntries = [
                    "red": "Red",
                    "orange": "Orange",
                    "green1": "Green Main",
                    "green2": "Green E",
                    "blue": "Blue",
                ]
            }
    }
}

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

extension Binding {
    func onChange(_ handler: @escaping (Value) -> Void) -> Binding<Value> {
        return Binding(
            get: { self.wrappedValue },
            set: { selection in
                self.wrappedValue = selection
                handler(selection)
        })
    }
}

enum Errors: Error {
    case WifiError(String)
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
