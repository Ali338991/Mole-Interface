//
//  CategoryCard.swift
//  Nebula — Components / selectable clean category
//

import SwiftUI

struct CategoryCard: View {
    let category: CleanCategory
    @Binding var isSelected: Bool
    @State private var expanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            HStack(alignment: .top, spacing: Spacing.md) {
                Image(systemName: category.symbol)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(category.safety.tint)
                    .frame(width: 38, height: 38)
                    .background(category.safety.tint.opacity(0.12), in: .rect(cornerRadius: 10))

                VStack(alignment: .leading, spacing: Spacing.xxs) {
                    Text(category.name).font(.nebulaCardTitle)
                    Text("\(category.itemCount) items").nebulaCaptionStyle().nebulaNumeric()
                }
                Spacer()
                Toggle("", isOn: $isSelected)
                    .toggleStyle(.checkbox)
                    .labelsHidden()
            }

            HStack {
                Text(ByteFormat.string(category.bytes))
                    .font(.nebulaSection).nebulaNumeric()
                    .foregroundStyle(isSelected ? .primary : .secondary)
                Spacer()
                Pill(text: category.safety.rawValue, symbol: category.safety.symbol,
                     tint: category.safety.tint)
            }

            HStack(spacing: Spacing.xs) {
                Image(systemName: category.routesToTrash ? "trash" : "xmark.bin")
                    .font(.system(size: 10))
                Text(category.routesToTrash ? "Moves to Trash (recoverable)" : "Permanent removal")
                    .font(.nebulaCaption)
            }
            .foregroundStyle(category.routesToTrash ? Color.secondary : Color.nebulaWarning)

            Button {
                withAnimation(Motion.snappy) { expanded.toggle() }
            } label: {
                HStack(spacing: Spacing.xs) {
                    Image(systemName: expanded ? "chevron.down" : "chevron.right")
                        .font(.system(size: 9, weight: .bold))
                    Text(expanded ? "Hide paths" : "Preview paths")
                }
                .font(.nebulaCaption)
            }
            .buttonStyle(.plain)
            .foregroundStyle(.tint)

            if expanded {
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    ForEach(category.samplePaths, id: \.self) { path in
                        Text(path).font(.nebulaMono).foregroundStyle(.secondary)
                            .lineLimit(1).truncationMode(.middle)
                    }
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .glassCard(elevation: isSelected ? .raised : .flat)
        .overlay(
            RoundedRectangle(cornerRadius: Radius.card)
                .strokeBorder(isSelected ? category.safety.tint.opacity(0.6) : .clear, lineWidth: 1.5)
        )
    }
}

#Preview("CategoryCard") {
    StatefulPreview(true) { sel in
        CategoryCard(category: MockData.cleanCategories[4], isSelected: sel)
            .frame(width: 320).padding()
    }
}

/// Small helper to preview views that need a binding.
struct StatefulPreview<Value, Content: View>: View {
    @State private var value: Value
    let content: (Binding<Value>) -> Content
    init(_ initial: Value, @ViewBuilder content: @escaping (Binding<Value>) -> Content) {
        _value = State(initialValue: initial)
        self.content = content
    }
    var body: some View { content($value) }
}
