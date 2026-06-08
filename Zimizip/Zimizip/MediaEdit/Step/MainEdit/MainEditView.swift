import SwiftUI
import UIKit

struct MainEditView: View {
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

            VStack(spacing: 0) {
                TopBar(
                    backButtonAction: backButtonAction,
                    nextButtonAction: completeButtonAction
                )
                .frame(height: MainEditLayout.topBarHeight)

                MainEditCanvas(
                    framingResult: framingResult,
                    image: image,
                    frameSize: canvasSize
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                EditToolBar()
            }
            .background(Color.black)
        }
        .background(Color.black)
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
