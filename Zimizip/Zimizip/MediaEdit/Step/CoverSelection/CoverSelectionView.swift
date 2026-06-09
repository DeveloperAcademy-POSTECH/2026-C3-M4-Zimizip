import SwiftUI
import UIKit

struct CoverSelectionView: View {
    @State private var isShowingSurpriseCardInput = false
    @State private var selectedCoverOptionID = CoverSelectionOption.defaultOptions[0].id

    let mainEditResult: MainEditResult
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

                    ZStack {
                        MainEditCanvas(
                            framingResult: mainEditResult.framingResult,
                            image: mainEditResult.image,
                            frameSize: canvasSize
                        )

                        if let selectedCoverOption {
                            Image(selectedCoverOption.imageName)
                                .resizable()
                                .scaledToFill()
                                .frame(width: canvasSize.width, height: canvasSize.height)
                                .clipShape(
                                    RoundedRectangle(
                                        cornerRadius: PhotoFramingLayout.frameCornerRadius,
                                        style: .continuous
                                    )
                                )
                        }
                    }
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
            SurpriseCardInputView(
                framingResult: mainEditResult.framingResult,
                image: mainEditResult.image,
                coverImageName: selectedCoverOption?.imageName ?? coverOptions[0].imageName
            )
            .navigationBarBackButtonHidden(true)
        }
    }
}

private extension CoverSelectionView {
    var selectedCoverOption: CoverSelectionOption? {
        coverOptions.first { $0.id == selectedCoverOptionID }
    }
}

#Preview {
    CoverSelectionView(
        mainEditResult: .coverSelectionViewPreviewValue,
        backButtonAction: {}
    )
}

private extension MainEditResult {
    static var coverSelectionViewPreviewValue: MainEditResult {
        var transformState = PhotoFramingTransformState()
        transformState.frameSize = CGSize(width: 297, height: 446)
        transformState.basePhotoSize = CGSize(width: 534, height: 300)
        transformState.minimumScale = 0.45
        transformState.scale = 1
        transformState.offset = .zero
        transformState.sourceAspectRatio = 402 / 226

        let framingResult = PhotoFramingResult(
            source: Data(),
            backgroundColor: .white,
            transformState: transformState,
            sourcePreviewFrame: nil,
            isLandscapeCapture: true
        )

        return MainEditResult(
            framingResult: framingResult,
            appliedFilterPreset: .original,
            stickers: [],
            image: nil
        )
    }
}
