import SwiftUI

enum PhotoFramingLayout {
    static let frameCornerRadius: CGFloat = 16

    private static let frameAspectRatio: CGFloat = 2 / 3
    private static let horizontalInset: CGFloat = 40
    private static let verticalInset: CGFloat = 24
    private static let maximumFrameWidth: CGFloat = 420
    private static let widePhotoInitialWidthMultiplier: CGFloat = 1.8
    private static let tallPhotoInitialHeightMultiplier: CGFloat = 1.15
    private static let minimumUserScale: CGFloat = 0.45
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
        containerSize: CGSize,
        sourcePreviewFrame: CGRect?,
        isLandscapeCapture: Bool
    ) -> CGSize {
        guard imageSize.width > 0,
              imageSize.height > 0,
              frameSize.width > 0,
              frameSize.height > 0,
              containerSize.width > 0,
              containerSize.height > 0 else {
            return .zero
        }

        let sourceAspectRatio = sourceAspectRatio(
            imageSize: imageSize,
            sourcePreviewFrame: sourcePreviewFrame,
            isLandscapeCapture: isLandscapeCapture
        )
        let frameAspectRatio = frameSize.width / frameSize.height

        if sourceAspectRatio > frameAspectRatio {
            let photoWidth = min(
                frameSize.width * widePhotoInitialWidthMultiplier,
                containerSize.width
            )

            return CGSize(
                width: photoWidth,
                height: photoWidth / sourceAspectRatio
            )
        }

        let photoHeight = min(
            frameSize.height * tallPhotoInitialHeightMultiplier,
            containerSize.height
        )

        return CGSize(
            width: photoHeight * sourceAspectRatio,
            height: photoHeight
        )
    }

    static func minimumScale(
        photoSize: CGSize,
        frameSize: CGSize
    ) -> CGFloat {
        guard photoSize.width > 0,
              photoSize.height > 0,
              frameSize.width > 0,
              frameSize.height > 0 else {
            return 1
        }

        let scaleToFitFrame = min(
            frameSize.width / photoSize.width,
            frameSize.height / photoSize.height,
            1
        )

        return min(scaleToFitFrame, minimumUserScale)
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
