//
//  SubgoalTypeCircleView.swift
//  AxisOne
//
//  Created by Ruslan Shigapov on 14.08.2025.
//

import SwiftUI

struct SubgoalTypeCircleView: View {
    
    let type: Constants.SubgoalTypes
    let count: Int
    
    var body: some View {
        VStack {
            ZStack {
                Circle()
                    .fill(Color(.secondarySystemBackground))
                    .frame(width: 60, height: 60)
                    .overlay {
                        Image(systemName: type.imageName)
                            .foregroundStyle(.accent)
                            .font(.system(size: 34))
                            .fontWeight(.light)
                    }
                Text("\(count)")
                    .font(.custom("Jura-SemiBold", size: 13))
                    .background {
                        Circle()
                            .fill(.ultraThinMaterial)
                            .stroke(.white, lineWidth: 0.4)
                            .frame(width: 24, height: 24)
                    }
                    .offset(x: 22, y: -22)
            }
            Text(type.plural)
                .font(.custom("Jura-Medium", size: 13))
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    ContentView()
        .environment(
            \.managedObjectContext,
             PersistenceController.shared.container.viewContext)
}
