//
//  Pill.swift
//  Nebula — Components / status capsule
//

import SwiftUI

struct Pill: View {
    enum Style { case filled, tinted, outline }

    var text: String
    var symbol: String? = nil
    var tint: Color = .nebulaAccent
    var style: Style = .tinted

    var body: some View {
        HStack(spacing: Spacing.xs) {
            if let symbol {
                Image(systemName: symbol).font(.system(size: 9, weight: .bold))
            }
            Text(text).font(.system(size: 11, weight: .semibold))
        }
        .padding(.horizontal, Spacing.sm)
        .padding(.vertical, 3)
        .foregroundStyle(foreground)
        .background(background, in: .capsule)
        .overlay {
            if style == .outline {
                Capsule().strokeBorder(tint.opacity(0.5), lineWidth: 1)
            }
        }
    }

    private var foreground: Color {
        switch style {
        case .filled:  return .white
        case .tinted:  return tint
        case .outline: return tint
        }
    }
    private var background: some ShapeStyle {
        switch style {
        case .filled:  return AnyShapeStyle(tint)
        case .tinted:  return AnyShapeStyle(tint.opacity(0.14))
        case .outline: return AnyShapeStyle(Color.clear)
        }
    }
}

#Preview("Pill") {
    HStack {
        Pill(text: "Safe to clean", symbol: "checkmark.shield.fill", tint: .nebulaSuccess)
        Pill(text: "Update", tint: .nebulaInfo, style: .filled)
        Pill(text: "Advanced", tint: .nebulaDanger, style: .outline)
    }.padding()
}
