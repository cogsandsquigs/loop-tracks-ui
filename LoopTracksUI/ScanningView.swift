//
//  ScanningView.swift
//  LoopTracksUI
//
//  Created by Ian Pratt on 7/14/22.
//

import SwiftUI

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
