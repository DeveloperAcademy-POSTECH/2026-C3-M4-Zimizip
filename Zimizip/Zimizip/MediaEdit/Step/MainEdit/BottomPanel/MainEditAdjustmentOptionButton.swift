import SwiftUI

struct MainEditAdjustmentOptionButton: View {
    let option: MainEditAdjustmentOption
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: MainEditLayout.adjustmentOptionIconTextSpacing) {
                optionIcon

                Text(option.title)
                    .font(.custom("Pretendard", size: MainEditLayout.adjustmentOptionLabelFontSize).weight(.bold))
                    .multilineTextAlignment(.center)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
                    .foregroundStyle(contentColor)
            }
            .frame(width: MainEditLayout.adjustmentOptionButtonWidth, alignment: .top)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

private extension MainEditAdjustmentOptionButton {
    @ViewBuilder
    var optionIcon: some View {
        if let iconAssetName = option.iconAssetName {
            Image(iconAssetName)
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .frame(
                    width: MainEditLayout.adjustmentOptionIconSize,
                    height: MainEditLayout.adjustmentOptionIconSize
                )
                .foregroundStyle(contentColor)
        } else {
            Color.clear
                .frame(
                    width: MainEditLayout.adjustmentOptionIconSize,
                    height: MainEditLayout.adjustmentOptionIconSize
                )
        }
    }

    var contentColor: Color {
        isSelected ? .brandPrimary : .white
    }
}

#Preview {
    HStack(spacing: 24) {
        MainEditAdjustmentOptionButton(
            option: .exposure,
            isSelected: true,
            action: {}
        )

        MainEditAdjustmentOptionButton(
            option: .contrast,
            isSelected: false,
            action: {}
        )
    }
    .padding()
    .background(Color.black)
}
