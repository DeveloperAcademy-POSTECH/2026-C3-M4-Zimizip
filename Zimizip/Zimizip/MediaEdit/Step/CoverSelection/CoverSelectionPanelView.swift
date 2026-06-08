import SwiftUI

struct CoverSelectionPanelView: View {
    let options: [CoverSelectionOption]
    @Binding var selectedOptionID: CoverSelectionOption.ID

    var body: some View {
        VStack(spacing: 0) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .center, spacing: 0) {
                    ForEach(options) { option in
                        CoverSelectionSwatchView(
                            option: option,
                            isSelected: selectedOptionID == option.id
                        ) {
                            selectedOptionID = option.id
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
            .padding(.top, 20)
            .padding(.bottom, 47)
            .background(.baseBlack)
        }
    }
}

#Preview {
    @Previewable @State var selectedOptionID = CoverSelectionOption.defaultOptions[0].id

    CoverSelectionPanelView(
        options: CoverSelectionOption.defaultOptions,
        selectedOptionID: $selectedOptionID
    )
    .background(Color.black)
}
