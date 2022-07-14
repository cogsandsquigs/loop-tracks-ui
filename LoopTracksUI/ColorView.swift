//
//  ColorView.swift
//  LoopTracksUI
//
//  Created by Ian Pratt on 7/14/22.
//

import SwiftUI

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
            let _ = setColor(color)
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
