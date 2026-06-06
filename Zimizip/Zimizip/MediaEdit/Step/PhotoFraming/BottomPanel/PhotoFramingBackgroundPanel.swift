import SwiftUI

struct PhotoFramingBackgroundPanel: View {
    @Binding var selectedBackgroundColor: PhotoFramingBackgroundColor

    var body: some View {
        VStack(spacing: 0) {
            labelRow
            swatchRow
        }
    }

    private var labelRow: some View {
        HStack(alignment: .center, spacing: 20) {
            Text("배경색")
                .font(.custom("Pretendard", size: 16).weight(.semibold))
                .foregroundStyle(Self.primaryColor)

            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 8)
        .frame(height: 48, alignment: .leading)
        .background(Self.panelBackgroundColor)
    }

    private var swatchRow: some View {
        HStack(alignment: .center, spacing: 0) {
            let backgroundColors = PhotoFramingBackgroundColor.allCases
            ForEach(Array(backgroundColors.enumerated()), id: \.element) { index, backgroundColor in
                PhotoFramingBackgroundSwatch(
                    backgroundColor: backgroundColor,
                    isSelected: selectedBackgroundColor == backgroundColor
                ) {
                    selectedBackgroundColor = backgroundColor
                }

                if index < backgroundColors.count - 1 {
                    Spacer(minLength: 0)
                }
            }
        }
        .padding(20)
        .frame(height: 108, alignment: .center)
        .background(Self.panelBackgroundColor)
    }
}

private extension PhotoFramingBackgroundPanel {
    static let primaryColor = Color(red: 1.0, green: 0.37, blue: 0.0)
    static let panelBackgroundColor = Color(red: 0.23, green: 0.21, blue: 0.20).opacity(0.5)
}

#Preview {
    @Previewable @State var selectedBackgroundColor: PhotoFramingBackgroundColor = .white

    PhotoFramingBackgroundPanel(
        selectedBackgroundColor: $selectedBackgroundColor
    )
    .frame(width: 402)
    .background(Color.black)
}
