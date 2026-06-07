import CoreGraphics
import Foundation

struct PhotoFramingResult {
    let source: Data
    let backgroundColor: PhotoFramingBackgroundColor
    let frameSize: CGSize
    let basePhotoSize: CGSize
    let scale: CGFloat
    let offset: CGSize
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
        self.sourceAspectRatio = transformState.sourceAspectRatio
        self.sourcePreviewFrame = sourcePreviewFrame
        self.isLandscapeCapture = isLandscapeCapture
    }
}
