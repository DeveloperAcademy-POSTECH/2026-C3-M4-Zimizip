import SwiftUI

enum PhotoFramingLayout {
    static let frameCornerRadius: CGFloat = 16

    private static let frameAspectRatio: CGFloat = 2 / 3
    private static let horizontalInset: CGFloat = 40
    private static let verticalInset: CGFloat = 24
    private static let maximumFrameWidth: CGFloat = 420
    private static let landscapeCaptureAspectRatio: CGFloat = 402 / 226

    static func frameSize(in containerSize: CGSize) -> CGSize {
        guard containerSize.width > 0, containerSize.height > 0 else {
            return .zero
        }

        let availableWidth = max(containerSize.width - horizontalInset * 2, 0)
        let availableHeight = max(containerSize.height - verticalInset * 2, 0)
        let widthThatFitsHeight = availableHeight * frameAspectRatio
        let frameWidth = min(
            availableWidth,
            widthThatFitsHeight,
            maximumFrameWidth
        )

        guard frameWidth > 0 else {
            return .zero
        }

        return CGSize(
            width: frameWidth,
            height: frameWidth / frameAspectRatio
        )
    }

    static func photoSize(
        imageSize: CGSize,
        frameSize: CGSize,
        sourcePreviewFrame: CGRect?,
        isLandscapeCapture: Bool
    ) -> CGSize {
        guard imageSize.width > 0,
              imageSize.height > 0,
              frameSize.width > 0,
              frameSize.height > 0 else {
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

    static func sourceAspectRatio(
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
