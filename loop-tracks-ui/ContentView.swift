//
//  ContentView.swift
//  loop-tracks-ui
//
//  Created by Ian Pratt on 7/11/22.
//

import SwiftUI

struct ContentView: View {
    @State private var wifiSSID = "WCL"
    @State private var wifiPass = "atmega328"
    @State private var wifiAlert = false
    @State private var wifiError = ""
    @State private var wifiDone = false
    @State private var city = "cta"
    @State private var setTrainSystem = "" // is used so we can detect if the user set a new city without sending it, so we don't show the color options
    @State private var color = "red"

    @StateObject private var btManager: BluetoothManager = BluetoothManager()
    
    var body: some View {
        NavigationView {
            VStack {
                Spacer()

                Group {
                    Text("Set wifi SSID and password:")
                        .bold()
                    
                    TextField("Set wifi SSID", text: $wifiSSID)
                        .padding()
                    
                    SecureField("Set wifi Password", text: $wifiPass)
                        .padding()
                    
                    Button("Set the wifi to be \(wifiSSID)") {
                        let err = SetWifi()
                        if let err = err {
                            wifiAlert = true
                            wifiError = err
                        } else {
                            wifiAlert = false
                        }
                    }
                        .padding()
                        .overlay(
                            RoundedRectangle(cornerRadius: 10.0)
                                .stroke(.blue)
                        )
                        .alert(wifiError, isPresented: $wifiAlert) {
                            Button("Ok", role: .cancel) {}
                        }
                }
                
                Spacer()
                
                Group {
                    if wifiDone {
                        Text("Select a train system:")
                            .bold()
                        
                        Picker("Select a train system", selection: $city) {
                            Text("cta").tag("cta")
                            Text("mbta").tag("mbta")
                        }
                        
                        Button("Set the train system to the \(city)")  {
                            SetCity()
                        }
                            .padding()
                            .overlay(
                                RoundedRectangle(cornerRadius: 10.0)
                                    .stroke(.blue)
                            )
                        
                        
                        if city != "" && city == setTrainSystem {
                            Spacer()
                            
                            Text("Select a train line color corresponding to the flashing line:")
                                .bold()
                            
                            switch city {
                            case "cta":
                                Picker("Select a train line color", selection: $color) {
                                    Text("pink").tag("pink")
                                    Text("red").tag("red")
                                    Text("orange").tag("orange")
                                    Text("south green").tag("green1")
                                    Text("west green").tag("green2")
                                    Text("blue").tag("blue")
                                    Text("brown/purple").tag("brown")
                                }
                                    .pickerStyle(MenuPickerStyle())
                            case "mbta":
                                Picker("Selecte a train line color", selection: $color) {
                                    Text("red").tag("red")
                                    Text("orange").tag("orange")
                                    Text("blue").tag("blue")
                                    Text("Green Main").tag("green1")
                                    Text("Green E").tag("green2")
                                }
                            default:
                                Picker("Select a train line color", selection: $color) { }
                            }
                            
                            Button("Set Argon to be the \(color) line")  {
                                SetColor()
                            }
                                .padding()
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10.0)
                                        .stroke(.blue)
                                )
                        }
                    }
                }

                Spacer()
            }
                .navigationTitle(
                    btManager.mainPeripheral != nil
                        ? "Connected to \(btManager.mainPeripheral.name ?? "Unknown device")"
                        : "Not Connected"
                )
                .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    func SetWifi() -> String? {
        if wifiSSID == "" {
            return "Please set the wifi SSID"
        } else if wifiPass == "" {
            return "Please set the wifi password"
        } else {
            print("Sending wifi \(wifiSSID)")
            btManager.sendData(data: "wifi:\(wifiSSID),\(wifiPass)")
            wifiDone = true
            return nil
        }
    }
    
    func SetCity() {
        setTrainSystem = city
        print("Sending city \(city)")
        btManager.sendData(data: "city:\(city)")
    }
    
    func SetColor() {
        print("Sending color \(color)")
        btManager.sendData(data: "color:\(color)")
    }
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
