//
//  Sunburst.swift
//  Nebula — radial hierarchy view (one level of arcs around a center).
//

import SwiftUI

struct SunburstView: View {
    let node: DiskNode
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var sweep = 0.0

    private var total: Double { node.children.reduce(0.0) { $0 + Double($1.bytes) } }

    var body: some View {
        GeometryReader { geo in
            let size = min(geo.size.width, geo.size.height)
            let center = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)
            ZStack {
                ForEach(arcs(), id: \.node.id) { arc in
                    RingArc(start: arc.start, end: arc.start + (arc.end - arc.start) * sweep,
                            inner: size * 0.18, outer: size * 0.46, center: center)
                        .fill(arc.node.kind.color.opacity(0.7))
                        .overlay(
                            RingArc(start: arc.start, end: arc.start + (arc.end - arc.start) * sweep,
                                    inner: size * 0.18, outer: size * 0.46, center: center)
                                .stroke(.white.opacity(0.2), lineWidth: 1)
                        )
                }
                VStack {
                    Text(ByteFormat.string(node.bytes)).font(.nebulaCardTitle).nebulaNumeric()
                    Text("total").nebulaCaptionStyle()
                }
            }
        }
        .onAppear {
            if reduceMotion { sweep = 1 }
            else { withAnimation(Motion.smooth) { sweep = 1 } }
        }
        .accessibilityElement()
        .accessibilityLabel("Disk usage sunburst, total \(ByteFormat.string(node.bytes))")
    }

    private struct Arc { let node: DiskNode; let start: Angle; let end: Angle }

    private func arcs() -> [Arc] {
        guard total > 0 else { return [] }
        var acc = 0.0
        return node.children.sorted { $0.bytes > $1.bytes }.map { child in
            let frac = Double(child.bytes) / total
            let start = Angle.degrees(acc * 360 - 90)
            acc += frac
            let end = Angle.degrees(acc * 360 - 90)
            return Arc(node: child, start: start, end: end)
        }
    }
}

/// A filled ring segment (donut arc) between inner and outer radii.
struct RingArc: Shape {
    var start: Angle
    var end: Angle
    var inner: CGFloat
    var outer: CGFloat
    var center: CGPoint

    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.addArc(center: center, radius: outer, startAngle: start, endAngle: end, clockwise: false)
        p.addArc(center: center, radius: inner, startAngle: end, endAngle: start, clockwise: true)
        p.closeSubpath()
        return p
    }
}
