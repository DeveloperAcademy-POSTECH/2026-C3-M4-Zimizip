import SwiftUI

struct SurpriseCardInputView: View {
    @State private var isShowingRevealTiming = false

    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()

            ZimizipPrimaryButton(title: "다음") {
                isShowingRevealTiming = true
            }
            .padding(.horizontal, 20)
        }
        .navigationBarBackButtonHidden(true)
        .navigationDestination(isPresented: $isShowingRevealTiming) {
            RevealTimingView()
                .navigationBarBackButtonHidden(true)
        }
    }
}

#Preview {
    SurpriseCardInputView()
}
