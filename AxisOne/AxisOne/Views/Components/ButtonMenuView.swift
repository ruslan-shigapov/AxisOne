//
//  ButtonMenuView.swift
//  AxisOne
//
//  Created by Ruslan Shigapov on 07.08.2025.
//

import SwiftUI

struct ButtonMenuView<Item: Identifiable>: View {
    
    let title: String
    let items: [Item]
    @Binding var selectedItem: Item
    let itemText: (Item) -> String
    var itemColor: (Item) -> Color? = { _ in nil }
    
    var body: some View {
        Menu {
            ForEach(items) { item in
                Button {
                    selectedItem = item
                } label: {
                    Text(itemText(item))
                }
            }
        } label: {
            LabeledContent {
                Text(itemText(selectedItem))
                    .foregroundStyle(itemColor(selectedItem) ?? .secondary)
                    .fontWeight(.medium)
                Image(systemName: "arrow.up.and.down")
                    .foregroundStyle(.secondary)
                    .imageScale(.small)
            } label: {
                Text(title)
                    .foregroundColor(.primary)
            }
            .frame(maxHeight: .infinity)
            .background(.clear)
        }
        .font(Constants.Fonts.juraBody)
    }
}
