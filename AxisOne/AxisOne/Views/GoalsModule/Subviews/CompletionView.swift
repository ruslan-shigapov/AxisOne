//
//  CompletionView.swift
//  AxisOne
//
//  Created by Ruslan Shigapov on 19.08.2025.
//

import SwiftUI

struct CompletionView: View {
    
    @Binding var value: Double
    
    var body: some View {
        VStack {
            LabeledContent("Составляет от цели") {
                Text("\(Int(value)) %")
            }
            Slider(
                value: $value,
                in: 0...100,
                step: 25)
            .onChange(of: value) {
                if $1 == 0 {
                    value = 25
                }
            }
        }
        .font(Constants.Fonts.juraBody)
    }
}
