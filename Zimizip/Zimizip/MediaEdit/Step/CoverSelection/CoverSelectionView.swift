import SwiftUI
import UIKit

struct CoverSelectionView: View {
    @State private var isShowingSurpriseCardInput = false
    @State private var selectedCoverOptionID = CoverSelectionOption.defaultOptions[0].id

    let framingResult: PhotoFramingResult
    let image: UIImage?
    let backButtonAction: () -> Void
    private let coverOptions = CoverSelectionOption.defaultOptions

    var body: some View {
        GeometryReader { proxy in
            let canvasSize = MainEditLayout.canvasSize(
                in: proxy.size,
                safeAreaInsets: proxy.safeAreaInsets
            )

            ZStack {
                Color.black
                    .ignoresSafeArea()

                VStack {
                    TopBar(
                        title: "커버 선택",
                        nextButtonTitle: "다음",
                        backButtonAction: backButtonAction,
                        nextButtonAction: {
                            isShowingSurpriseCardInput = true
                        }
                    )
                    
                    Spacer()

                    MainEditCanvas(
                        framingResult: framingResult,
                        image: image,
                        frameSize: canvasSize
                    )
                    .frame(width: canvasSize.width, height: canvasSize.height)

                    Spacer()

                    CoverSelectionPanelView(
                        options: coverOptions,
                        selectedOptionID: $selectedCoverOptionID
                    )
                    .padding(.bottom, proxy.safeAreaInsets.bottom)
                    .background(MainEditLayout.panelBackgroundColor)
                }
                .ignoresSafeArea(edges: .bottom)
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
    CoverSelectionView(
        framingResult: .coverSelectionViewPreviewValue,
        image: nil,
        backButtonAction: {}
    )
}

private extension PhotoFramingResult {
    static var coverSelectionViewPreviewValue: PhotoFramingResult {
        var transformState = PhotoFramingTransformState()
        transformState.frameSize = CGSize(width: 297, height: 446)
        transformState.basePhotoSize = CGSize(width: 534, height: 300)
        transformState.minimumScale = 0.45
        transformState.scale = 1
        transformState.offset = .zero
        transformState.sourceAspectRatio = 402 / 226

        return PhotoFramingResult(
            source: Data(),
            backgroundColor: .white,
            transformState: transformState,
            sourcePreviewFrame: nil,
            isLandscapeCapture: true
        )
    }
}
