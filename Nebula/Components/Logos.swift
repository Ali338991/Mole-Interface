//
//  Logos.swift
//  Mole — Brand mark
//
//  "Burrow" — the design's recommended logo (concept B): a tunnel mouth into
//  the earth. Reproduced from the design's 24×24 SVG as a scalable Canvas mark.
//

import SwiftUI

/// The Burrow glyph: a thick arch (tunnel mouth) with a dot on the path below.
struct BurrowMark: View {
    var color: Color = .white
    var body: some View {
        Canvas { ctx, size in
            let s = min(size.width, size.height)
            func p(_ x: CGFloat, _ y: CGFloat) -> CGPoint { CGPoint(x: x / 24 * s, y: y / 24 * s) }
            let lineW = 4.2 / 24 * s
            let radius = 5.0 / 24 * s

            var arch = Path()
            arch.move(to: p(7.0, 21))
            arch.addLine(to: p(7.0, 12))
            arch.addArc(center: p(12, 12), radius: radius,
                        startAngle: .degrees(180), endAngle: .degrees(360), clockwise: false)
            arch.addLine(to: p(17.0, 21))
            ctx.stroke(arch, with: .color(color),
                       style: StrokeStyle(lineWidth: lineW, lineCap: .round, lineJoin: .round))

            let dotR = 1.7 / 24 * s
            let c = p(12, 21)
            ctx.fill(Path(ellipseIn: CGRect(x: c.x - dotR, y: c.y - dotR, width: dotR * 2, height: dotR * 2)),
                     with: .color(color))
        }
    }
}

/// The rounded brand tile (gradient background + Burrow glyph) used in the
/// sidebar, onboarding, settings, and menu bar.
struct BrandTile: View {
    var size: CGFloat = 30
    var corner: CGFloat = 9
    var body: some View {
        RoundedRectangle(cornerRadius: corner)
            .fill(LinearGradient.nebulaGradient)
            .frame(width: size, height: size)
            .overlay(BurrowMark(color: .white).padding(size * 0.2))
            .overlay(RoundedRectangle(cornerRadius: corner).strokeBorder(.white.opacity(0.25), lineWidth: 0.5))
            .shadow(color: .nebulaAccent.opacity(0.4), radius: size * 0.2, x: 0, y: 2)
    }
}

#Preview("Brand") {
    HStack(spacing: 24) {
        BrandTile(size: 30)
        BrandTile(size: 64, corner: 16)
        BurrowMark(color: .nebulaAccent).frame(width: 48, height: 48)
    }
    .padding(40)
}
