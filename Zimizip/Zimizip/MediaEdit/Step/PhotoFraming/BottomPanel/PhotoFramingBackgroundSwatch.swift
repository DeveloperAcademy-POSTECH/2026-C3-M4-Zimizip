import SwiftUI

struct PhotoFramingBackgroundSwatch: View {
    let backgroundColor: PhotoFramingBackgroundColor
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                if isSelected {
                    RoundedRectangle(cornerRadius: Self.selectedRingCornerRadius)
                        .fill(.clear)
                        .frame(width: Self.selectedRingSize, height: Self.selectedRingSize)
                        .overlay {
                            RoundedRectangle(cornerRadius: Self.selectedRingCornerRadius)
                                .inset(by: -2)
                                .stroke(Self.selectionColor, lineWidth: 4)
                        }

                    RoundedRectangle(cornerRadius: Self.selectedFillCornerRadius)
                        .fill(backgroundColor.color)
                        .frame(width: Self.selectedFillSize, height: Self.selectedFillSize)
                } else {
                    Circle()
                        .fill(backgroundColor.color)
                        .frame(width: Self.swatchSize, height: Self.swatchSize)
                }
            }
            .frame(width: Self.swatchSize, height: Self.swatchSize)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(backgroundColor.accessibilityLabel)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

private extension PhotoFramingBackgroundSwatch {
    static let swatchSize: CGFloat = 48
    static let selectedRingSize: CGFloat = 40
    static let selectedRingCornerRadius: CGFloat = 40
    static let selectedFillSize: CGFloat = 33.33334
    static let selectedFillCornerRadius: CGFloat = 33.33334
    static let selectionColor = Color(red: 1.0, green: 0.42, blue: 0.13)
}

#Preview {
    HStack {
        PhotoFramingBackgroundSwatch(
            backgroundColor: .white,
            isSelected: true,
            action: {}
        )

        PhotoFramingBackgroundSwatch(
            backgroundColor: .red,
            isSelected: false,
            action: {}
        )
    }
    .padding()
    .background(Color.black)
}
