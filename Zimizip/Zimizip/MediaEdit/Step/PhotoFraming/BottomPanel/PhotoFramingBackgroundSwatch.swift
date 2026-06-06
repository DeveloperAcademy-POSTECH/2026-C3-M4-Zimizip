import SwiftUI

struct PhotoFramingBackgroundSwatch: View {
    let backgroundColor: PhotoFramingBackgroundColor
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .stroke(
                        Color(red: 1.0, green: 0.37, blue: 0.0),
                        lineWidth: isSelected ? 3 : 0
                    )
                    .frame(width: 48, height: 48)

                Circle()
                    .fill(backgroundColor.color)
                    .frame(width: 36, height: 36)
            }
            .frame(width: 48, height: 48)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(backgroundColor.accessibilityLabel)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
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
