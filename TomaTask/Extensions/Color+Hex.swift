//
//  Color+Hex.swift
//  TomaTask
//

import SwiftUI
import UIKit

extension Color {
    func toHexString() -> String {
        let uiColor = UIColor(self)
        let components = uiColor.cgColor.components ?? [0, 0, 0, 0]
        let r: CGFloat = components[0]
        let g: CGFloat = components.count > 1 ? components[1] : components[0]
        let b: CGFloat = components.count > 2 ? components[2] : components[0]

        return String(format: "#%02X%02X%02X", Int(r * 255), Int(g * 255), Int(b * 255))
    }

    static func fromHexString(_ hex: String) -> Color {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)

        let r = Double((rgb & 0xFF0000) >> 16) / 255.0
        let g = Double((rgb & 0x00FF00) >> 8) / 255.0
        let b = Double(rgb & 0x0000FF) / 255.0

        return Color(red: r, green: g, blue: b)
    }
}
