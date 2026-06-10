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
    static let adjustmentPanelTitle = "조정"
    static let stickerPanelTitle = "스티커"
    static let textPanelTitle = "텍스트"
    static let filterThumbnailPanelHeight: CGFloat = 132
    static let filterThumbnailPanelPadding: CGFloat = 20
    static let filterThumbnailSize = CGSize(width: 55, height: 65)
    static let filterThumbnailLabelFontSize: CGFloat = 14
    static let stickerThumbnailPanelHeight: CGFloat = 108
    static let stickerThumbnailPanelPadding: CGFloat = 20
    static let stickerThumbnailSpacing: CGFloat = 21.75
    static let stickerThumbnailSize = CGSize(width: 55, height: 50)
    static let textMenuBarHeight: CGFloat = 48
    static let textMenuHorizontalPadding: CGFloat = 20
    static let textMenuVerticalPadding: CGFloat = 8
    static let textMenuItemSpacing: CGFloat = 20
    static let textMenuFontSize: CGFloat = 16
    static let textContentPanelHeight: CGFloat = 108
    static let textContentPanelPadding: CGFloat = 20
    static let textFontOptionSize = CGSize(width: 100, height: 66)
    static let textFontOptionCornerRadius: CGFloat = 4
    static let textFontOptionSelectedBorderWidth: CGFloat = 4
    static let textFontOptionLabelFontSize: CGFloat = 16
    static let textColorSwatchSize: CGFloat = 48
    static let textColorSelectedRingSize: CGFloat = 40
    static let textColorSelectedRingCornerRadius: CGFloat = 40
    static let textColorSelectedRingWidth: CGFloat = 4
    static let textColorSelectedFillSize: CGFloat = 33.33334
    static let textColorSelectedFillCornerRadius: CGFloat = 33.33334
    static let textPreviewBoxWidthRatio: CGFloat = 0.78
    static let textPreviewBoxHeight: CGFloat = 56
    static let textPreviewBoxBorderWidth: CGFloat = 2
    static let textPreviewControlSize: CGFloat = 20
    static let textPreviewControlIconSize: CGFloat = 10
    static let textPreviewTextFontSize: CGFloat = 20
    static let textPreviewPlaceholder = "텍스트를 입력하세요"
    static let adjustmentOptionPanelHeight: CGFloat = 132
    static let adjustmentOptionPanelPadding: CGFloat = 20
    static let adjustmentOptionButtonWidth: CGFloat = 76
    static let adjustmentOptionButtonSpacing: CGFloat = 22
    static let adjustmentOptionIconSize: CGFloat = 24
    static let adjustmentOptionIconTextSpacing: CGFloat = 18
    static let adjustmentOptionLabelFontSize: CGFloat = 16
    static let adjustmentSliderHeight: CGFloat = 48
    static let adjustmentSliderHorizontalPadding: CGFloat = 20
    static let adjustmentSliderVerticalPadding: CGFloat = 8
    static let adjustmentSliderContentSpacing: CGFloat = 20
    static let adjustmentSliderValueWidth: CGFloat = 39
    static let adjustmentSliderValueFontSize: CGFloat = 16
    static let adjustmentSliderTrackHeight: CGFloat = 2
    static let adjustmentSliderThumbSize: CGFloat = 20
    static let stickerMinimumScale: CGFloat = 0.5
    static let stickerMaximumScale: CGFloat = 3
    static let historyControlIconSize: CGFloat = 24
    static let historyControlSpacing: CGFloat = 23
    static let historyControlLeadingPadding: CGFloat = 20
    static let historyControlBottomSpacing: CGFloat = 23
    static let historyControlEditingPanelBottomSpacing: CGFloat = 6
    static let historyUndoIconName = "ri_arrow-go-back-line"
    static let historyRedoIconName = "ri_arrow-go-front-line"

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

    static func adjustmentPanelTotalHeight(
        safeAreaInsets: EdgeInsets,
        isSliderPresented: Bool
    ) -> CGFloat {
        (isSliderPresented ? adjustmentSliderHeight : 0) +
            adjustmentOptionPanelHeight +
            bottomPanelActionContentHeight +
            bottomPanelActionBottomPadding +
            safeAreaInsets.bottom
    }

    static func stickerPanelTotalHeight(safeAreaInsets: EdgeInsets) -> CGFloat {
        stickerThumbnailPanelHeight +
            bottomPanelActionContentHeight +
            bottomPanelActionBottomPadding +
            safeAreaInsets.bottom
    }

    static func textPanelTotalHeight(safeAreaInsets: EdgeInsets) -> CGFloat {
        textMenuBarHeight +
            textContentPanelHeight +
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
