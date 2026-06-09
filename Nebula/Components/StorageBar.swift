//
//  StorageBar.swift
//  Nebula — Components / segmented disk usage bar
//

import SwiftUI

struct StorageSegment: Identifiable {
    let id = UUID()
    let label: String
    let bytes: Int64
    let color: Color
}

struct StorageBar: View {
    var segments: [StorageSegment]
    var freeBytes: Int64
    var height: CGFloat = 18

    private var total: Int64 { segments.reduce(0) { $0 + $1.bytes } + freeBytes }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            GeometryReader { geo in
                HStack(spacing: 1.5) {
                    ForEach(segments) { seg in
                        seg.color
                            .frame(width: width(for: seg.bytes, in: geo.size.width))
                    }
                    Color.nebulaHairlineStrong
                        .frame(width: width(for: freeBytes, in: geo.size.width))
                }
                .clipShape(.rect(cornerRadius: height / 2))
            }
            .frame(height: height)

            // Legend
            LazyVGrid(columns: [.init(.adaptive(minimum: 130), alignment: .leading)],
                      alignment: .leading, spacing: Spacing.sm) {
                ForEach(segments) { seg in
                    HStack(spacing: Spacing.xs) {
                        Circle().fill(seg.color).frame(width: 8, height: 8)
                        Text(seg.label).font(.nebulaCaption)
                        Spacer(minLength: 2)
                        Text(ByteFormat.string(seg.bytes)).nebulaCaptionStyle().nebulaNumeric()
                    }
                }
                HStack(spacing: Spacing.xs) {
                    Circle().fill(Color.nebulaHairlineStrong).frame(width: 8, height: 8)
                    Text("Free").font(.nebulaCaption)
                    Spacer(minLength: 2)
                    Text(ByteFormat.string(freeBytes)).nebulaCaptionStyle().nebulaNumeric()
                }
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Disk usage")
        .accessibilityValue("\(ByteFormat.string(freeBytes)) free of \(ByteFormat.string(total))")
    }

    private func width(for bytes: Int64, in total: CGFloat) -> CGFloat {
        guard self.total > 0 else { return 0 }
        return max(2, total * CGFloat(bytes) / CGFloat(self.total))
    }
}

#Preview("StorageBar") {
    StorageBar(segments: [
        .init(label: "Apps", bytes: 88_000_000_000, color: .nebulaAccent),
        .init(label: "Media", bytes: 142_000_000_000, color: .nebulaAccentSecondary),
        .init(label: "Developer", bytes: 64_000_000_000, color: .nebulaSuccess),
        .init(label: "System", bytes: 96_000_000_000, color: .gray),
    ], freeBytes: 104_000_000_000)
    .padding(40).frame(width: 520)
}
