import SwiftUI

struct SurpriseCardInputView: View {
    let primaryButtonAction: () -> Void

    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()

            ZimizipPrimaryButton(title: "다음") {
                primaryButtonAction()
            }
            .padding(.horizontal, 20)
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    SurpriseCardInputView {}
}
