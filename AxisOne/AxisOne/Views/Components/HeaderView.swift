//
//  HeaderView.swift
//  AxisOne
//
//  Created by Ruslan Shigapov on 07.08.2025.
//

import SwiftUI

struct HeaderView: View {
    
    let text: String
    
    var body: some View {
        Text(text)
            .font(.custom("Jura", size: 14))
    }
}
