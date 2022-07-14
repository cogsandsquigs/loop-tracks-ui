//
//  WifiView.swift
//  LoopTracksUI
//
//  Created by Ian Pratt on 7/14/22.
//

import SwiftUI

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
                UIApplication.shared.endEditing()
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

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

enum WifiError: Error {
    case NoSSID(String)
    case NoPass(String)
}
