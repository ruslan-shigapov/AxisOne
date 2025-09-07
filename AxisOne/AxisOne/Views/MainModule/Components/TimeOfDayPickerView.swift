//
//  TimeOfDayPickerView.swift
//  AxisOne
//
//  Created by Ruslan Shigapov on 17.08.2025.
//

import SwiftUI

struct TimeOfDayPickerView: View {
        
    private let timesOfDay = TimesOfDay.allCases.dropLast()
    
    @Binding var selectedTimeOfDay: TimesOfDay
    
    var body: some View {
        GeometryReader {
            let size = $0.size
            let segmentWidth = size.width / CGFloat(timesOfDay.count)
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 10)
                    .fill(.accent)
                    .frame(width: segmentWidth, height: size.height)
                    .offset(x: getOffset(for: segmentWidth))
                HStack {
                    ForEach(timesOfDay) { timeOfDay in
                        Image(systemName: timeOfDay.imageName)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .foregroundStyle(
                                selectedTimeOfDay == timeOfDay
                                ? .yellow
                                : .secondary)
                            .contentShape(.rect)
                            .onTapGesture {
                                withAnimation(.snappy) {
                                    selectedTimeOfDay = timeOfDay
                                }
                            }
                    }
                }
            }
            .background {
                RoundedRectangle(cornerRadius: 10)
                    .fillWithShadow()
            }
        }
        .frame(height: 30)
    }
    
    private func getOffset(for segmentWidth: CGFloat) -> CGFloat {
        let index = timesOfDay.firstIndex(of: selectedTimeOfDay) ?? 0
        return segmentWidth * CGFloat(index)
    }
}

#Preview {
    ContentView()
        .environment(
            \.managedObjectContext,
             PersistenceController.shared.container.viewContext)
}
