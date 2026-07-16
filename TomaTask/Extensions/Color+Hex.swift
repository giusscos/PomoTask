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
    
    /// Relative luminance (0…1) for contrast decisions.
    var relativeLuminance: Double {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        
        let uiColor = UIColor(self)
        if !uiColor.getRed(&r, green: &g, blue: &b, alpha: &a) {
            guard let converted = uiColor.cgColor.converted(
                to: CGColorSpaceCreateDeviceRGB(),
                intent: .defaultIntent,
                options: nil
            ), let components = converted.components, components.count >= 3 else {
                return 0.5
            }
            r = components[0]
            g = components[1]
            b = components[2]
        }
        
        return 0.2126 * Double(r) + 0.7152 * Double(g) + 0.0722 * Double(b)
    }
    
    var isLight: Bool {
        relativeLuminance > 0.55
    }
    
    /// Black or white, whichever stays readable on this color.
    var contrastingForeground: Color {
        isLight ? .black : .white
    }
    
    static func blended(_ colors: [Color]) -> Color {
        guard !colors.isEmpty else { return .black }
        
        var totalR: CGFloat = 0
        var totalG: CGFloat = 0
        var totalB: CGFloat = 0
        
        for color in colors {
            var r: CGFloat = 0
            var g: CGFloat = 0
            var b: CGFloat = 0
            var a: CGFloat = 0
            let uiColor = UIColor(color)
            
            if uiColor.getRed(&r, green: &g, blue: &b, alpha: &a) {
                totalR += r
                totalG += g
                totalB += b
            } else if let converted = uiColor.cgColor.converted(
                to: CGColorSpaceCreateDeviceRGB(),
                intent: .defaultIntent,
                options: nil
            ), let components = converted.components, components.count >= 3 {
                totalR += components[0]
                totalG += components[1]
                totalB += components[2]
            }
        }
        
        let count = CGFloat(colors.count)
        return Color(red: totalR / count, green: totalG / count, blue: totalB / count)
    }
}
