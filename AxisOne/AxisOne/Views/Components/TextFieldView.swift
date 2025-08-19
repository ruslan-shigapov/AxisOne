//
//  TextFieldView.swift
//  AxisOne
//
//  Created by Ruslan Shigapov on 07.08.2025.
//

import SwiftUI

struct TextFieldView: View {
    
    let placeholder: String
    @Binding var text: String
    
    var body: some View {
        TextField(placeholder, text: $text, axis: .vertical)
            .font(Constants.Fonts.juraBody)
    }
}
