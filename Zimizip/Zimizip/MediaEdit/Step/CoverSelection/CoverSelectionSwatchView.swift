import SwiftUI

struct CoverSelectionSwatchView: View {
    let option: CoverSelectionOption
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                if isSelected {
                    RoundedRectangle(cornerRadius: Self.selectionRingCornerRadius, style: .continuous)
                        .fill(.clear)
                        .frame(width: Self.selectionRingSize.width, height: Self.selectionRingSize.height)
                        .overlay {
                            RoundedRectangle(cornerRadius: Self.selectionRingCornerRadius, style: .continuous)
                                .stroke(Self.selectionColor, lineWidth: Self.selectionLineWidth)
                        }
                }

                Image(option.imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: Self.imageSize.width, height: Self.imageSize.height)
                    .clipShape(RoundedRectangle(cornerRadius: Self.imageCornerRadius, style: .continuous))
            }
            .frame(width: Self.swatchSize.width, height: Self.swatchSize.height)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(option.imageName)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

private extension CoverSelectionSwatchView {
    static let swatchSize = CGSize(width: 76, height: 96)
    static let selectionRingSize = CGSize(width: 72, height: 92)
    static let imageSize = CGSize(width: 60, height: 80)
    static let selectionRingCornerRadius: CGFloat = 12
    static let imageCornerRadius: CGFloat = 4
    static let selectionLineWidth: CGFloat = 4
    static let selectionColor = Color(red: 1.0, green: 0.42, blue: 0.13)
}

#Preview {
    HStack {
        CoverSelectionSwatchView(
            option: .defaultOptions[0],
            isSelected: true,
            action: {}
        )

        CoverSelectionSwatchView(
            option: .defaultOptions[1],
            isSelected: false,
            action: {}
        )
    }
    .padding()
    .background(Color.black)
}
