//
//  Treemap.swift
//  Nebula — squarified-ish treemap layout + view.
//

import SwiftUI

/// One laid-out treemap tile. Identifiable via its node.
struct TreemapTile: Identifiable {
    let node: DiskNode
    let frame: CGRect
    var id: UUID { node.id }
}

/// Computes child frames within a rect using a slice-and-dice layout that
/// alternates split direction to keep tiles reasonably square.
enum TreemapLayout {
    static func frames(for nodes: [DiskNode], in rect: CGRect) -> [TreemapTile] {
        let sorted = nodes.sorted { $0.bytes > $1.bytes }
        let total = sorted.reduce(0.0) { $0 + Double($1.bytes) }
        guard total > 0 else { return [] }
        return layout(sorted, total: total, rect: rect, horizontal: rect.width >= rect.height)
    }

    private static func layout(_ nodes: [DiskNode], total: Double, rect: CGRect,
                               horizontal: Bool) -> [TreemapTile] {
        var result: [TreemapTile] = []
        var offset = horizontal ? rect.minX : rect.minY
        for node in nodes {
            let fraction = Double(node.bytes) / total
            if horizontal {
                let w = rect.width * fraction
                result.append(TreemapTile(node: node, frame: CGRect(x: offset, y: rect.minY, width: w, height: rect.height)))
                offset += w
            } else {
                let h = rect.height * fraction
                result.append(TreemapTile(node: node, frame: CGRect(x: rect.minX, y: offset, width: rect.width, height: h)))
                offset += h
            }
        }
        return result
    }
}

struct TreemapView: View {
    let root: DiskNode
    @Binding var path: [DiskNode]
    @State private var hovered: DiskNode?

    private var current: DiskNode { path.last ?? root }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            breadcrumb
            GeometryReader { geo in
                let rect = CGRect(origin: .zero, size: geo.size)
                let tiles = TreemapLayout.frames(for: current.children, in: rect)
                ZStack(alignment: .topLeading) {
                    ForEach(tiles) { tile in
                        tileView(tile.node, frame: tile.frame)
                    }
                }
            }
            .background(Color.nebulaHairline, in: .rect(cornerRadius: Radius.card))
            if let hovered {
                Text("\(hovered.name) · \(ByteFormat.string(hovered.bytes))")
                    .font(.nebulaMono).foregroundStyle(.secondary)
            }
        }
    }

    private func tileView(_ node: DiskNode, frame: CGRect) -> some View {
        Button {
            if !node.isLeaf { withAnimation(Motion.snappy) { path.append(node) } }
        } label: {
            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 6)
                    .fill(node.kind.color.opacity(hovered?.id == node.id ? 0.55 : 0.38))
                    .overlay(RoundedRectangle(cornerRadius: 6).strokeBorder(.white.opacity(0.15)))
                if frame.width > 70 && frame.height > 34 {
                    VStack(alignment: .leading, spacing: 1) {
                        Text(node.name).font(.system(size: 11, weight: .semibold)).lineLimit(1)
                        Text(ByteFormat.string(node.bytes)).font(.system(size: 10)).nebulaNumeric()
                            .foregroundStyle(.secondary)
                    }
                    .padding(6)
                }
            }
        }
        .buttonStyle(.plain)
        .frame(width: max(2, frame.width - 2), height: max(2, frame.height - 2))
        .offset(x: frame.minX, y: frame.minY)
        .onHover { hovered = $0 ? node : (hovered?.id == node.id ? nil : hovered) }
        .help("\(node.name) — \(ByteFormat.string(node.bytes))")
    }

    private var breadcrumb: some View {
        HStack(spacing: Spacing.xs) {
            crumbButton(title: root.name, isLast: path.isEmpty) {
                withAnimation(Motion.snappy) { path = [] }
            }
            ForEach(Array(path.enumerated()), id: \.element.id) { idx, node in
                crumbSegment(idx: idx, node: node)
            }
            Spacer()
        }
        .font(.nebulaCallout)
    }

    @ViewBuilder
    private func crumbSegment(idx: Int, node: DiskNode) -> some View {
        Image(systemName: "chevron.right")
            .font(.system(size: 9))
            .foregroundStyle(.tertiary)
        crumbButton(title: node.name, isLast: idx == path.count - 1) {
            withAnimation(Motion.snappy) { path = Array(path.prefix(idx + 1)) }
        }
    }

    private func crumbButton(title: String, isLast: Bool,
                             action: @escaping () -> Void) -> some View {
        Button(title, action: action)
            .buttonStyle(.plain)
            .foregroundStyle(isLast ? Color.primary : Color.nebulaAccent)
    }
}
