//
//  Theme.swift
//  Mole — Design System / Color
//
//  Indigo-violet brand with Apple-semantic
//  roles, full light + dark). All colors are appearance-aware: they resolve
//  through NSColor dynamic providers so light/dark tracking is automatic.
//
//

import SwiftUI

extension Color {
    /// Opaque appearance-aware color from light/dark hex values.
    static func dynamic(light: UInt32, dark: UInt32) -> Color {
        Color(nsColor: NSColor(name: nil) { appearance in
            let isDark = appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
            return NSColor(hex: isDark ? dark : light)
        })
    }

    /// Appearance-aware color with explicit alpha (for hairlines/overlays).
    static func dynamicA(light: (UInt32, Double), dark: (UInt32, Double)) -> Color {
        Color(nsColor: NSColor(name: nil) { appearance in
            let isDark = appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
            let (hex, a) = isDark ? dark : light
            return NSColor(hex: hex).withAlphaComponent(a)
        })
    }
}

// Defined on `ShapeStyle where Self == Color` (like SwiftUI's `.red`) so these
// work with leading-dot syntax in BOTH `Color` and `ShapeStyle` contexts.
extension ShapeStyle where Self == Color {

    // MARK: Brand (indigo / violet)
    static var nebulaAccent: Color          { .dynamic(light: 0x6C5CE7, dark: 0x8B7CF6) }   // --brand
    static var nebulaAccentStrong: Color    { .dynamic(light: 0x5A48D6, dark: 0x7C6BF0) }   // --brand-strong
    static var nebulaAccentSoft: Color      { .dynamic(light: 0x8B7CF6, dark: 0xA99CF9) }   // --brand-soft
    static var nebulaAccentSecondary: Color { .dynamic(light: 0x5A48D6, dark: 0x7C6BF0) }   // gradient pair

    // MARK: Semantic
    static var nebulaSuccess: Color { .dynamic(light: 0x2FAE6A, dark: 0x45C285) }
    static var nebulaWarning: Color { .dynamic(light: 0xF0A020, dark: 0xFFB23E) }
    static var nebulaDanger: Color  { .dynamic(light: 0xE5544B, dark: 0xFF6259) }
    static var nebulaInfo: Color    { .dynamic(light: 0x3E82F0, dark: 0x5B9CFF) }

    // MARK: Surfaces
    static var nebulaWindowBg: Color { .dynamic(light: 0xF4F3F8, dark: 0x1B1922) }
    static var nebulaSurface: Color  { .dynamic(light: 0xFFFFFF, dark: 0x26232F) }
    static var nebulaSurface2: Color { .dynamic(light: 0xF7F6FB, dark: 0x211E29) }
    static var nebulaSurface3: Color { .dynamic(light: 0xEFEDF6, dark: 0x2E2A38) }

    // MARK: Text
    static var nebulaText: Color  { .dynamic(light: 0x1A1726, dark: 0xF2F1F7) }
    static var nebulaText2: Color { .dynamic(light: 0x6A6680, dark: 0xA4A0B5) }
    static var nebulaText3: Color { .dynamic(light: 0x9B97AD, dark: 0x726E82) }

    // MARK: Hairlines
    static var nebulaHairline: Color       { .dynamicA(light: (0x000000, 0.07), dark: (0xFFFFFF, 0.09)) }
    static var nebulaHairlineStrong: Color { .dynamicA(light: (0x000000, 0.12), dark: (0xFFFFFF, 0.16)) }

    // MARK: Disk / category palette
    static var catApps: Color   { .dynamic(light: 0x6C5CE7, dark: 0x8B7CF6) }
    static var catDocs: Color   { .dynamic(light: 0x3E82F0, dark: 0x5B9CFF) }
    static var catMedia: Color  { .dynamic(light: 0xE5705B, dark: 0xF0876F) }
    static var catDev: Color    { .dynamic(light: 0x2FAE6A, dark: 0x45C285) }
    static var catSystem: Color { .dynamic(light: 0x8A8699, dark: 0x9B96AD) }
    static var catCaches: Color { .dynamic(light: 0xF0A020, dark: 0xFFB23E) }
    static var catOther: Color  { .dynamic(light: 0xC2BED4, dark: 0x4A4658) }
}

extension ShapeStyle where Self == LinearGradient {
    /// Signature Mole brand gradient (145°, three-stop), per --brand-grad.
    static var nebulaGradient: LinearGradient {
        LinearGradient(
            colors: [.nebulaAccentSoft, .nebulaAccent, .nebulaAccentStrong],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

/// Health score → tint mapping used across Dashboard, Optimize, menu bar.
enum HealthTint {
    static func color(for score: Int) -> Color {
        switch score {
        case 85...:   return .nebulaSuccess
        case 60..<85: return .nebulaWarning
        default:      return .nebulaDanger
        }
    }
    static func label(for score: Int) -> String {
        switch score {
        case 85...:   return "Healthy"
        case 60..<85: return "Needs attention"
        default:      return "At risk"
        }
    }
}

// MARK: - NSColor hex helper

extension NSColor {
    convenience init(hex: UInt32) {
        let r = CGFloat((hex >> 16) & 0xFF) / 255
        let g = CGFloat((hex >> 8) & 0xFF) / 255
        let b = CGFloat(hex & 0xFF) / 255
        self.init(srgbRed: r, green: g, blue: b, alpha: 1)
    }
}
