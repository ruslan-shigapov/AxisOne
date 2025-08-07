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

    let onSelect: (Item) -> Void

    let itemText: (Item) -> String
    
    var itemColor: (Item) -> Color? = { _ in nil }
    
    var body: some View {
        LabeledContent(title) {
           Menu {
               ForEach(items) { item in
                   Button {
                       onSelect(item)
                   } label: {
                       Text(itemText(item))
                   }
               }
           } label: {
               Text(itemText(selectedItem))
                   .foregroundStyle(itemColor(selectedItem) ?? .gray)
                   .fontWeight(.medium)
               Image(systemName: "arrow.up.and.down")
                   .foregroundStyle(.gray)
           }
       }
        .font(.custom("Jura", size: 17))
    }
}
