import SwiftUI

struct PhotoFramingBackgroundSwatch: View {
    let backgroundColor: PhotoFramingBackgroundColor
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(backgroundColor.color)
                    .frame(width: fillSize, height: fillSize)

                if isSelected {
                    Circle()
                        .stroke(Self.selectionColor, lineWidth: 3)
                        .frame(width: Self.swatchSize, height: Self.swatchSize)
                }
            }
            .frame(width: Self.swatchSize, height: Self.swatchSize)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(backgroundColor.accessibilityLabel)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private var fillSize: CGFloat {
        isSelected ? 36 : Self.swatchSize
    }
}

private extension PhotoFramingBackgroundSwatch {
    static let swatchSize: CGFloat = 48
    static let selectionColor = Color(red: 1.0, green: 0.37, blue: 0.0)
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
