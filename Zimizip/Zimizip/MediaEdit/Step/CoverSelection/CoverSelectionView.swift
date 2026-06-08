import SwiftUI

struct CoverSelectionView: View {
    @State private var isShowingSurpriseCardInput = false

    let backButtonAction: () -> Void

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                Color.black
                    .ignoresSafeArea()

                TopBar(
                    title: "커버 선택",
                    nextButtonTitle: "다음",
                    backButtonAction: backButtonAction,
                    nextButtonAction: {
                        isShowingSurpriseCardInput = true
                    }
                )
            }
        }
        .background(Color.black)
        .navigationBarBackButtonHidden(true)
        .navigationDestination(isPresented: $isShowingSurpriseCardInput) {
            SurpriseCardInputView()
            .navigationBarBackButtonHidden(true)
        }
    }
}

#Preview {
    CoverSelectionView(backButtonAction: {})
}
