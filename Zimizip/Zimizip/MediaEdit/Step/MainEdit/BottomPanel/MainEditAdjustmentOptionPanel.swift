import SwiftUI

struct MainEditAdjustmentOptionPanel: View {
    @Binding var selectedOption: MainEditAdjustmentOption?

    private let options = MainEditAdjustmentOption.allCases

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .top, spacing: MainEditLayout.adjustmentOptionButtonSpacing) {
                ForEach(options) { option in
                    MainEditAdjustmentOptionButton(
                        option: option,
                        isSelected: selectedOption == option
                    ) {
                        selectedOption = option
                    }
                }
            }
            .padding(MainEditLayout.adjustmentOptionPanelPadding)
        }
        .frame(maxWidth: .infinity)
        .frame(height: MainEditLayout.adjustmentOptionPanelHeight, alignment: .top)
        .background(MainEditLayout.bottomPanelBackgroundColor)
    }
}

#Preview {
    @Previewable @State var selectedOption: MainEditAdjustmentOption? = .exposure

    MainEditAdjustmentOptionPanel(selectedOption: $selectedOption)
        .background(Color.black)
}
