import CoreGraphics
import SwiftUI

enum MainEditLayout {
    static let designWidth: CGFloat = 402
    static let topBarHorizontalPadding: CGFloat = 24
    static let topBarTopPadding: CGFloat = 8
    static let topBarBottomPadding: CGFloat = 20
    static let backButtonIconSize: CGFloat = 24
    static let topBarButtonHeight: CGFloat = 32
    static let completeButtonWidth: CGFloat = 52
    static let completeButtonCornerRadius: CGFloat = 16
    static let bottomToolBarHeight: CGFloat = 108
    static let bottomToolBarPadding: CGFloat = 20
    static let toolIconSize: CGFloat = 24
    static let canvasHorizontalInset: CGFloat = 52
    static let canvasVerticalInset: CGFloat = 20
    static let canvasTopSpacing: CGFloat = 20
    static let maximumCanvasWidth: CGFloat = 420
    static let canvasAspectRatio: CGFloat = 2 / 3
    static let bottomPanelBackgroundColor = Color(red: 0.23, green: 0.21, blue: 0.2).opacity(0.5)
    static let bottomPanelActionIconSize: CGFloat = 24
    static let bottomPanelActionHorizontalPadding: CGFloat = 20
    static let bottomPanelActionBottomPadding: CGFloat = 32
    static let bottomPanelActionContentHeight: CGFloat = 24
    static let bottomPanelActionTitleFontSize: CGFloat = 16
    static let bottomPanelCancelIconName = "close"
    static let bottomPanelConfirmIconName = "check"
    static let panelBackgroundColor = bottomPanelBackgroundColor
    static let filterPanelTitle = "필터"
    static let filterThumbnailPanelHeight: CGFloat = 132
    static let filterThumbnailPanelPadding: CGFloat = 20
    static let filterThumbnailSize = CGSize(width: 55, height: 65)
    static let filterThumbnailLabelFontSize: CGFloat = 14

    static var topBarContentHeight: CGFloat {
        topBarTopPadding + topBarButtonHeight + topBarBottomPadding
    }

    static func topBarTotalHeight(safeAreaInsets: EdgeInsets) -> CGFloat {
        safeAreaInsets.top + topBarContentHeight
    }

    static func bottomToolBarTotalHeight(safeAreaInsets: EdgeInsets) -> CGFloat {
        bottomToolBarHeight + safeAreaInsets.bottom
    }

    static func filterPanelTotalHeight(safeAreaInsets: EdgeInsets) -> CGFloat {
        filterThumbnailPanelHeight +
            bottomPanelActionContentHeight +
            bottomPanelActionBottomPadding +
            safeAreaInsets.bottom
    }

    static func canvasSize(
        in containerSize: CGSize,
        safeAreaInsets: EdgeInsets,
        topPanelHeight: CGFloat? = nil,
        bottomPanelHeight: CGFloat? = nil
    ) -> CGSize {
        guard containerSize.width > 0,
              containerSize.height > 0 else {
            return .zero
        }

        let availableWidth = max(containerSize.width - canvasHorizontalInset * 2, 0)
        let resolvedTopPanelHeight = topPanelHeight ??
            topBarTotalHeight(safeAreaInsets: safeAreaInsets)
        let resolvedBottomPanelHeight = bottomPanelHeight ??
            bottomToolBarTotalHeight(safeAreaInsets: safeAreaInsets)
        let availableHeight = max(
            containerSize.height -
            resolvedTopPanelHeight -
            resolvedBottomPanelHeight -
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

    static func canvasCenterY(
        in containerSize: CGSize,
        canvasSize: CGSize,
        safeAreaInsets: EdgeInsets
    ) -> CGFloat {
        let topBarHeight = topBarTotalHeight(safeAreaInsets: safeAreaInsets)
        let bottomToolBarHeight = bottomToolBarTotalHeight(safeAreaInsets: safeAreaInsets)
        let preferredTop = topBarHeight + canvasTopSpacing
        let maximumTop = containerSize.height -
            bottomToolBarHeight -
            canvasVerticalInset -
            canvasSize.height
        let canvasTop = min(preferredTop, max(topBarHeight, maximumTop))

        return canvasTop + canvasSize.height / 2
    }
}
