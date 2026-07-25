//
//  BrandColors.swift
//  TomaTask
//

import SwiftUI

/// Shared tomato brand tokens used by iOS, Watch, and widgets.
enum BrandColors {
    static let tomatoRed = Color(red: 0.86, green: 0.14, blue: 0.14)
    static let breakRed = Color(red: 0.72, green: 0.22, blue: 0.28)

    static func phaseColor(isBreak: Bool) -> Color {
        isBreak ? breakRed : tomatoRed
    }
}
