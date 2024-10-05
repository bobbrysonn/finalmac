//
//  AsyncButton.swift
//  Based Reviews
//
//  Created by Bob Moriasi on 10/4/24.
//

import SwiftUI

struct AsyncButton<Label: View>: View {
    @ViewBuilder var label: () -> Label
    @State private var isPerformingTask: Bool = false
    
    var action: () async -> Void
    
    var body: some View {
        Button {
            
        } label: {
            ZStack {
                // Reduce opacity so that size doesn't change
                label()
                    .opacity(isPerformingTask ? 0 : 1)
                
                // Show progress
                if isPerformingTask {
                    ProgressView()
                }
            }
        }
        .disabled(isPerformingTask)
    }
}
