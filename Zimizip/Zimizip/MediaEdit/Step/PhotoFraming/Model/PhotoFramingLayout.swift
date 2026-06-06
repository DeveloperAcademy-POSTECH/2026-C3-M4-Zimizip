import SwiftUI

enum PhotoFramingLayout {
    static let frameSize = CGSize(width: 297, height: 446)
    static let frameCornerRadius: CGFloat = 16

    private static let landscapeCaptureAspectRatio: CGFloat = 402 / 226

    static func photoSize(
        imageSize: CGSize,
        frameSize: CGSize,
        sourcePreviewFrame: CGRect?,
        isLandscapeCapture: Bool
    ) -> CGSize {
        guard imageSize.width > 0, imageSize.height > 0 else {
            return .zero
        }

        let photoAspectRatio = sourceAspectRatio(
            imageSize: imageSize,
            sourcePreviewFrame: sourcePreviewFrame,
            isLandscapeCapture: isLandscapeCapture
        )
        let frameAspectRatio = frameSize.width / frameSize.height

        if photoAspectRatio > frameAspectRatio {
            return CGSize(
                width: frameSize.width,
                height: frameSize.width / photoAspectRatio
            )
        } else {
            return CGSize(
                width: frameSize.height * photoAspectRatio,
                height: frameSize.height
            )
        }
    }

    private static func sourceAspectRatio(
        imageSize: CGSize,
        sourcePreviewFrame: CGRect?,
        isLandscapeCapture: Bool
    ) -> CGFloat {
        if isLandscapeCapture {
            return landscapeCaptureAspectRatio
        }

        if let sourcePreviewFrame,
           sourcePreviewFrame.width > 0,
           sourcePreviewFrame.height > 0 {
            return sourcePreviewFrame.width / sourcePreviewFrame.height
        }

        return imageSize.width / imageSize.height
    }
}
