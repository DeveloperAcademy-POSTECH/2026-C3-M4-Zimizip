import SwiftUI

struct MainEditAdjustmentPanel: View {
    @Binding var selectedOption: MainEditAdjustmentOption?
    @Binding var adjustmentValues: [MainEditAdjustmentOption: Int]

    let cancelAction: () -> Void
    let confirmAction: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            if let selectedOption {
                MainEditAdjustmentSliderView(
                    value: adjustmentValueBinding(for: selectedOption)
                )
            }

            MainEditAdjustmentOptionPanel(selectedOption: $selectedOption)

            MainEditBottomPanelActionBar(
                title: MainEditLayout.adjustmentPanelTitle,
                cancelAction: cancelAction,
                confirmAction: confirmAction
            )
        }
        .background(MainEditLayout.bottomPanelBackgroundColor)
    }
}

private extension MainEditAdjustmentPanel {
    func adjustmentValueBinding(for option: MainEditAdjustmentOption) -> Binding<Int> {
        Binding(
            get: {
                adjustmentValues[option, default: 0]
            },
            set: { newValue in
                adjustmentValues[option] = newValue
            }
        )
    }
}

#Preview {
    @Previewable @State var selectedOption: MainEditAdjustmentOption? = .exposure
    @Previewable @State var adjustmentValues: [MainEditAdjustmentOption: Int] = [
        .exposure: 68
    ]

    MainEditAdjustmentPanel(
        selectedOption: $selectedOption,
        adjustmentValues: $adjustmentValues,
        cancelAction: {},
        confirmAction: {}
    )
    .frame(width: MainEditLayout.designWidth)
    .background(Color.black)
}
