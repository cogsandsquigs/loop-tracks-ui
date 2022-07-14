//
//  TrainSystemView.swift
//  loop-tracks-ui
//
//  Created by admin on 7/14/22.
//

import SwiftUI

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
