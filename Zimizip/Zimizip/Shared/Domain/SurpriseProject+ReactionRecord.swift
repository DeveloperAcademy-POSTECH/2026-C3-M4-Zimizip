import UIKit

extension SurpriseProject {
    func reactionRecordPayload() -> SurpriseCardPayload {
        let source = content.media.source

        return SurpriseCardPayload(
            title: name,
            framingResult: PhotoFramingResult(
                source: source,
                backgroundColor: .white,
                transformState: defaultTransformState(for: source),
                sourcePreviewFrame: nil,
                isLandscapeCapture: false
            ),
            image: UIImage(data: source),
            coverImageName: content.box.isEmpty ? "HomeSurpriseCardCenter" : content.box
        )
    }

    private func defaultTransformState(for source: Data) -> PhotoFramingTransformState {
        let frameSize = CGSize(width: 297, height: 446)
        let sourceSize = UIImage(data: source)?.size ?? frameSize
        let sourceAspectRatio = sourceSize.width > 0 && sourceSize.height > 0
            ? sourceSize.width / sourceSize.height
            : frameSize.width / frameSize.height
        let frameAspectRatio = frameSize.width / frameSize.height
        let basePhotoSize: CGSize

        if sourceAspectRatio > frameAspectRatio {
            basePhotoSize = CGSize(
                width: frameSize.height * sourceAspectRatio,
                height: frameSize.height
            )
        } else {
            basePhotoSize = CGSize(
                width: frameSize.width,
                height: frameSize.width / sourceAspectRatio
            )
        }

        var transformState = PhotoFramingTransformState()
        transformState.frameSize = frameSize
        transformState.basePhotoSize = basePhotoSize
        transformState.minimumScale = 1
        transformState.scale = 1
        transformState.offset = .zero
        transformState.sourceAspectRatio = sourceAspectRatio

        return transformState
    }
}
