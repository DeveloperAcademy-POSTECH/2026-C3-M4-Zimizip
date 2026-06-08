import CoreGraphics
import SwiftUI

enum MainEditLayout {
    static let designWidth: CGFloat = 402
    static let topBarHorizontalPadding: CGFloat = 24
    static let topBarTopPadding: CGFloat = 50
    static let topBarBottomPadding: CGFloat = 28
    static let backButtonIconSize: CGFloat = 24
    static let topBarButtonHeight: CGFloat = 34
    static let completeButtonWidth: CGFloat = 56
    static let completeButtonCornerRadius: CGFloat = 17
    static let bottomToolBarHeight: CGFloat = 108
    static let bottomToolBarPadding: CGFloat = 20
    static let toolIconSize: CGFloat = 24
    static let canvasHorizontalInset: CGFloat = 40
    static let canvasVerticalInset: CGFloat = 24
    static let maximumCanvasWidth: CGFloat = 420
    static let canvasAspectRatio: CGFloat = 2 / 3

    static var topBarHeight: CGFloat {
        topBarTopPadding + topBarButtonHeight + topBarBottomPadding
    }

    static func canvasSize(
        in containerSize: CGSize,
        safeAreaInsets: EdgeInsets
    ) -> CGSize {
        guard containerSize.width > 0,
              containerSize.height > 0 else {
            return .zero
        }

        let availableWidth = max(containerSize.width - canvasHorizontalInset * 2, 0)
        let availableHeight = max(
            containerSize.height -
            topBarHeight -
            bottomToolBarHeight -
            safeAreaInsets.bottom -
            canvasVerticalInset * 2,
            0
        )
        let widthThatFitsHeight = availableHeight * canvasAspectRatio
        let frameWidth = min(availableWidth, widthThatFitsHeight, maximumCanvasWidth)

        guard frameWidth > 0 else {
            return .zero
        }

        return CGSize(
            width: frameWidth,
            height: frameWidth / canvasAspectRatio
        )
    }
}
