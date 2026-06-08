import SwiftUI
import UIKit

struct MainEditView: View {
    @State private var selectedTool: MainEditTool?
    @State private var isShowingCoverSelection = false

    let framingResult: PhotoFramingResult
    let backButtonAction: () -> Void
    let completeButtonAction: () -> Void
    private let image: UIImage?

    init(
        framingResult: PhotoFramingResult,
        backButtonAction: @escaping () -> Void,
        completeButtonAction: @escaping () -> Void
    ) {
        self.framingResult = framingResult
        self.backButtonAction = backButtonAction
        self.completeButtonAction = completeButtonAction
        self.image = UIImage(data: framingResult.source)
    }

    var body: some View {
        GeometryReader { proxy in
            let canvasSize = MainEditLayout.canvasSize(
                in: proxy.size,
                safeAreaInsets: proxy.safeAreaInsets
            )
            let canvasCenterY = MainEditLayout.canvasCenterY(
                in: proxy.size,
                canvasSize: canvasSize,
                safeAreaInsets: proxy.safeAreaInsets
            )
            let topBarHeight = MainEditLayout.topBarContentHeight
            let bottomToolBarHeight = MainEditLayout.bottomToolBarTotalHeight(
                safeAreaInsets: proxy.safeAreaInsets
            )

            ZStack {
                Color.black
                    .ignoresSafeArea()

                VStack {
                    TopBar(
                        backButtonAction: backButtonAction,
                        nextButtonAction: {
                            isShowingCoverSelection = true
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

                    EditToolBar(selectedTool: $selectedTool)
                        .frame(height: bottomToolBarHeight, alignment: .top)
                        .background(MainEditLayout.panelBackgroundColor)
                }
                .ignoresSafeArea(edges: .bottom)
            }
        }
        .background(Color.black)
        .navigationDestination(isPresented: $isShowingCoverSelection) {
            CoverSelectionView(
                backButtonAction: {
                    isShowingCoverSelection = false
                }
            )
            .navigationBarBackButtonHidden(true)
        }
    }
}

#Preview {
    MainEditView(
        framingResult: .mainEditViewPreviewValue,
        backButtonAction: {},
        completeButtonAction: {}
    )
}

private extension PhotoFramingResult {
    static var mainEditViewPreviewValue: PhotoFramingResult {
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
