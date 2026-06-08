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
        VStack(spacing: 0) {
            TopBar(
                title: "사진 꾸미기",
                nextButtonTitle: "완료",
                backButtonAction: backButtonAction,
                nextButtonAction: completeButtonAction,
                titleFont: .custom("Pretendard", size: 16).weight(.semibold),
                titleColor: .white,
                backButtonFont: .system(size: 32, weight: .medium),
                backButtonColor: .white,
                nextButtonFont: .custom("Pretendard", size: 16).weight(.bold),
                nextButtonBackgroundColor: Color(.primary),
                nextButtonForegroundColor: .white,
                nextButtonSize: CGSize(width: 56, height: 50),
                nextButtonCornerRadius: 24,
                horizontalPadding: 24,
                topPadding: 50,
                bottomPadding: 28,
                backgroundColor: .black
            )

            MainEditCanvas(
                framingResult: framingResult,
                image: image
            )

            bottomToolArea
        }
        .background(Color.black)
    }
}

private extension MainEditView {
    var bottomToolArea: some View {
        Rectangle()
            .fill(Color(red: 0.23, green: 0.21, blue: 0.2).opacity(0.5))
            .frame(maxWidth: .infinity)
            .frame(height: 108)
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
