import SwiftUI

struct CoverSelectionView: View {
    @State private var isShowingSurpriseCardInput = false

    let backButtonAction: () -> Void
    let nextButtonAction: () -> Void

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .top) {
                Color.black
                    .ignoresSafeArea()

                TopBar(
                    title: "커버 선택",
                    nextButtonTitle: "다음",
                    backButtonAction: backButtonAction,
                    nextButtonAction: {
                        isShowingSurpriseCardInput = true
                    },
                    topPadding: proxy.safeAreaInsets.top + MainEditLayout.topBarTopPadding
                )
                .frame(maxWidth: .infinity)
            }
        }
        .background(Color.black)
        .navigationBarBackButtonHidden(true)
        .navigationDestination(isPresented: $isShowingSurpriseCardInput) {
            SurpriseCardInputView {
                nextButtonAction()
            }
            .navigationBarBackButtonHidden(true)
        }
    }
}

#Preview {
    CoverSelectionView(
        backButtonAction: {},
        nextButtonAction: {}
    )
}
