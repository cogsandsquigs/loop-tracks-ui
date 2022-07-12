//
//  ContentView.swift
//  loop-tracks-ui
//
//  Created by Ian Pratt on 7/11/22.
//

import SwiftUI

struct ContentView: View {
    @State private var colorSelection = "pink";
    
    var body: some View {
        VStack {
            Text("Select a train line color corresponding to the flashing Argon:")
                .bold()
            Picker("Select a train line color", selection: $colorSelection) {
                Text("pink").tag("pink")
                Text("red").tag("red")
                Text("orange").tag("orange")
                Text("green").tag("green")
                Text("blue").tag("blue")
                Text("purple").tag("purple")
                Text("brown").tag("brown")
            }
                .pickerStyle(MenuPickerStyle())
            Button(action:SetArgonColor) {
                Text("Set Argon to be the " + colorSelection + " line")
            }
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 10.0)
                        .stroke(.gray)
                )
        }
    }
    
    
    func SetArgonColor() {
        print(colorSelection)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
