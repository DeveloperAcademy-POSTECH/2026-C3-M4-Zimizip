import CoreGraphics
import Foundation

struct PhotoFramingResult {
    let source: Data
    let backgroundColor: PhotoFramingBackgroundColor
    let frameSize: CGSize
    let basePhotoSize: CGSize
    let scale: CGFloat
    let offset: CGSize
    let normalizedBasePhotoSize: CGSize
    let normalizedOffset: CGSize
    let sourceAspectRatio: CGFloat
    let sourcePreviewFrame: CGRect?
    let isLandscapeCapture: Bool

    init(
        source: Data,
        backgroundColor: PhotoFramingBackgroundColor,
        transformState: PhotoFramingTransformState,
        sourcePreviewFrame: CGRect?,
        isLandscapeCapture: Bool
    ) {
        self.source = source
        self.backgroundColor = backgroundColor
        self.frameSize = transformState.frameSize
        self.basePhotoSize = transformState.basePhotoSize
        self.scale = transformState.scale
        self.offset = transformState.offset
        self.normalizedBasePhotoSize = Self.normalized(
            transformState.basePhotoSize,
            by: transformState.frameSize
        )
        self.normalizedOffset = Self.normalized(
            transformState.offset,
            by: transformState.frameSize
        )
        self.sourceAspectRatio = transformState.sourceAspectRatio
        self.sourcePreviewFrame = sourcePreviewFrame
        self.isLandscapeCapture = isLandscapeCapture
    }

    private static func normalized(_ size: CGSize, by frameSize: CGSize) -> CGSize {
        guard frameSize.width > 0,
              frameSize.height > 0 else {
            return .zero
        }

        return CGSize(
            width: size.width / frameSize.width,
            height: size.height / frameSize.height
        )
    }
}
