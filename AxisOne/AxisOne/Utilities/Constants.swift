//
//  Constants.swift
//  AxisOne
//
//  Created by Ruslan Shigapov on 28.06.2025.
//

import SwiftUICore

enum Constants {
    
    // MARK: - Texts
    enum Texts {
        static let edit = "Править"
        static let cancel = "Отменить"
        static let done = "Готово"
        static let today = "Сегодня"
        static let yesterday = "Вчера"
        static let tomorrow = "Завтра"
    }
    
    // MARK: - Fonts
    enum Fonts {
        static let juraLargeTitle = Font.custom("Jura-Bold", size: 34)
        static let juraHeadline = Font.custom("Jura-Bold", size: 17)
        static let juraMediumBody = Font.custom("Jura-Medium", size: 17)
        static let juraBody = Font.custom("Jura", size: 17)
        static let juraLightCallout = Font.custom("Jura-Light", size: 16)
        static let juraBoldSubheadline = Font.custom("Jura-Bold", size: 15)
        static let juraMediumSubheadline = Font.custom("Jura-Medium", size: 15)
        static let juraMediumFootnote = Font.custom("Jura-Medium", size: 13)
        static let juraFootnote = Font.custom("Jura", size: 13)
    }
    
    // MARK: - Colors
    enum Colors {
        static let darkBackground = Color("DarkBackground")
        static let lightBackground = Color("LightBackground")
    }
}
