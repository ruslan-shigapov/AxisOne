//
//  TimeOfDayPickerView.swift
//  AxisOne
//
//  Created by Ruslan Shigapov on 17.08.2025.
//

import SwiftUI

struct TimeOfDayPickerView: View {
        
    @State private var excessSegmentWidth: CGFloat = .zero
    @State private var minX: CGFloat = .zero
    
    private let timesOfDay = Constants.TimesOfDay.allCases.dropLast()
    
    @Binding var selectedTimeOfDay: Constants.TimesOfDay
        
    var body: some View {
        GeometryReader {
            let size = $0.size
            let widthForEachSegment = size.width / CGFloat(timesOfDay.count)
            HStack(spacing: 0) {
                ForEach(timesOfDay) { timeOfDay in
                    Image(systemName: timeOfDay.imageName)
                        .font(.body)
                        .foregroundStyle(selectedTimeOfDay == timeOfDay
                                         ? .yellow
                                         : .secondary)
                        .animation(.snappy, value: selectedTimeOfDay)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .contentShape(.rect)
                        .onTapGesture {
                            if let index = timesOfDay.firstIndex(of: timeOfDay),
                               let activeIndex = timesOfDay.firstIndex(
                                of: selectedTimeOfDay
                               ) {
                                selectedTimeOfDay = timeOfDay
                                withAnimation(
                                    .snappy(duration: 0.25, extraBounce: 0),
                                    completionCriteria: .logicallyComplete) {
                                        excessSegmentWidth = widthForEachSegment * CGFloat(index - activeIndex)
                                    } completion: {
                                        withAnimation(
                                            .snappy(duration: 0.25, extraBounce: 0)
                                        ) {
                                            minX = widthForEachSegment * CGFloat(index)
                                            excessSegmentWidth = 0
                                        }
                                    }
                            }
                    }
                    .background(alignment: .leading) {
                        if timesOfDay.first == timeOfDay {
                            GeometryReader {
                                let size = $0.size
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(.blue)
                                    .frame(height: size.height)
                                    .frame(maxHeight: .infinity, alignment: .bottom)
                                    .frame(
                                        width: size.width + (excessSegmentWidth < 0 ? -excessSegmentWidth : excessSegmentWidth),
                                        height: size.height)
                                    .frame(width: size.width, alignment: excessSegmentWidth < 0 ? .trailing : .leading)
                                    .offset(x: minX)
                            }
                        }
                    }
                }
            }
            .background {
                RoundedRectangle(cornerRadius: 10)
                    .fill(.ultraThinMaterial)
                    .ignoresSafeArea()
                
            }
            .preference(key: SizeKey.self, value: size)
            .onPreferenceChange(SizeKey.self) { size in
                if let index = timesOfDay.firstIndex(of: selectedTimeOfDay) {
                    minX = widthForEachSegment * CGFloat(index)
                    excessSegmentWidth = 0
                }
            }
        }
        .frame(height: 35)
    }
}

fileprivate struct SizeKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}

#Preview {
    ContentView()
        .environment(
            \.managedObjectContext,
             PersistenceController.shared.container.viewContext)
}
