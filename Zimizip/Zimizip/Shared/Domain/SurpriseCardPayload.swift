import UIKit

struct SurpriseCardPayload {
    let title: String
    let framingResult: PhotoFramingResult
    let image: UIImage?
    let coverImageName: String

    var persistedImageData: Data {
        image?.jpegData(compressionQuality: 0.9) ?? framingResult.source
    }
}

extension SurpriseCardPayload {
    static var previewValue: SurpriseCardPayload {
        var transformState = PhotoFramingTransformState()
        transformState.frameSize = CGSize(width: 297, height: 446)
        transformState.basePhotoSize = CGSize(width: 534, height: 300)
        transformState.minimumScale = 0.45
        transformState.scale = 1
        transformState.offset = .zero
        transformState.sourceAspectRatio = 402 / 226

        return SurpriseCardPayload(
            title: "서프라이즈 프로젝트",
            framingResult: PhotoFramingResult(
                source: Data(),
                backgroundColor: .white,
                transformState: transformState,
                sourcePreviewFrame: nil,
                isLandscapeCapture: true
            ),
            image: nil,
            coverImageName: "HomeSurpriseCardCenter"
        )
    }
}
