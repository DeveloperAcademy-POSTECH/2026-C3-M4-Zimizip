import SwiftUI

struct PhotoFramingBackgroundPanel: View {
    @Binding var selectedBackgroundColor: PhotoFramingBackgroundColor

    var body: some View {
        VStack(alignment: .leading, spacing: 26) {
            HStack {
                Text("배경색")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Color(red: 1.0, green: 0.37, blue: 0.0))

                Spacer()
            }

            HStack(spacing: 30) {
                ForEach(PhotoFramingBackgroundColor.allCases) { backgroundColor in
                    PhotoFramingBackgroundSwatch(
                        backgroundColor: backgroundColor,
                        isSelected: selectedBackgroundColor == backgroundColor
                    ) {
                        selectedBackgroundColor = backgroundColor
                    }
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
        .padding(.bottom, 24)
        //.frame(maxWidth: .infinity, alignment: .leading)
        .border(.red)
        .background(Color(red: 0.12, green: 0.10, blue: 0.09))
    }
}

#Preview {
    @Previewable @State var selectedBackgroundColor: PhotoFramingBackgroundColor = .white

    PhotoFramingBackgroundPanel(
        selectedBackgroundColor: $selectedBackgroundColor
    )
}
