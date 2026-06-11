import SwiftUI
import UIKit

struct MainEditCanvas: View {
    @State private var activeTextDragID: MainEditTextItem.ID?
    @State private var activeTextScaleID: MainEditTextItem.ID?
    @State private var activeStickerDragID: MainEditStickerItem.ID?

    let framingResult: PhotoFramingResult
    let image: UIImage?
    let frameSize: CGSize
    var texts: [MainEditTextItem] = []
    var selectedTextID: MainEditTextItem.ID?
    var selectTextAction: (MainEditTextItem.ID) -> Void = { _ in }
    var textTapAction: (MainEditTextItem.ID) -> Void = { _ in }
    var textDoubleTapAction: (MainEditTextItem.ID) -> Void = { _ in }
    var deleteTextAction: (MainEditTextItem.ID) -> Void = { _ in }
    var duplicateTextAction: (MainEditTextItem.ID) -> Void = { _ in }
    var dragTextAction: (MainEditTextItem.ID, CGSize, CGSize) -> Void = { _, _, _ in }
    var endTextDragAction: () -> Void = {}
    var scaleTextAction: (MainEditTextItem.ID, CGFloat, CGSize) -> Void = { _, _, _ in }
    var endTextScaleAction: () -> Void = {}
    var stickers: [MainEditStickerItem] = []
    var selectedStickerID: MainEditStickerItem.ID?
    var isStickerEditingEnabled = false
    var selectStickerAction: (MainEditStickerItem.ID) -> Void = { _ in }
    var dragStickerAction: (MainEditStickerItem.ID, CGSize, CGSize) -> Void = { _, _, _ in }
    var endStickerDragAction: () -> Void = {}
    var scaleStickerAction: (MainEditStickerItem.ID, CGFloat, CGSize) -> Void = { _, _, _ in }
    var endStickerScaleAction: () -> Void = {}

    var body: some View {
        ZStack {
            Color.black

            framedContent(frameSize: frameSize)
        }
    }
}

private extension MainEditCanvas {
    func framedContent(frameSize: CGSize) -> some View {
        ZStack {
            framingResult.backgroundColor.color

            photoLayer(frameSize: frameSize)
                .zIndex(0)

            textLayer(frameSize: frameSize)
                .frame(width: frameSize.width, height: frameSize.height)
                .zIndex(1)

            stickerLayer(frameSize: frameSize)
                .frame(width: frameSize.width, height: frameSize.height)
                .zIndex(2)
        }
        .frame(width: frameSize.width, height: frameSize.height)
        .clipShape(RoundedRectangle(cornerRadius: PhotoFramingLayout.frameCornerRadius, style: .continuous))
    }

    @ViewBuilder
    func photoLayer(frameSize: CGSize) -> some View {
        if let image {
            let photoSize = restoredPhotoSize(in: frameSize)

            PhotoFramingPhotoLayer(
                image: image,
                contentMode: .fill
            )
            .frame(
                width: photoSize.width,
                height: photoSize.height
            )
            .offset(restoredOffset(in: frameSize))
            .frame(width: frameSize.width, height: frameSize.height)
        }
    }

    func textLayer(frameSize: CGSize) -> some View {
        ForEach(orderedTexts) { text in
            textPreviewLayer(text, frameSize: frameSize)
        }
    }

    func textPreviewLayer(_ textItem: MainEditTextItem, frameSize: CGSize) -> some View {
        let previewSize = textPreviewSize(for: textItem, in: frameSize)

        return ZStack {
            Text(
                attributedText(
                    for: textItem,
                    fontSize: textPreviewFontSize(for: textItem, in: frameSize)
                )
            )
                .multilineTextAlignment(.center)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .padding(.horizontal, MainEditLayout.textPreviewControlSize)

            if selectedTextID == textItem.id {
                RoundedRectangle(cornerRadius: 0)
                    .stroke(Color.baseWhite, lineWidth: MainEditLayout.textPreviewBoxBorderWidth)

                textPreviewControlButton(
                    systemName: MainEditLayout.textPreviewCloseIconName,
                    action: {
                        deleteTextAction(textItem.id)
                    }
                )
                    .position(x: previewSize.width, y: 0)

                textPreviewControlButton(
                    systemName: MainEditLayout.textPreviewDuplicateIconName,
                    action: {
                        duplicateTextAction(textItem.id)
                    }
                )
                    .position(x: 0, y: previewSize.height)
            }
        }
        .frame(width: previewSize.width, height: previewSize.height)
        .position(restoredTextCenter(for: textItem, in: frameSize))
        .zIndex(textItem.id == selectedTextID ? 0 : 1)
        .onTapGesture(count: 2) {
            textDoubleTapAction(textItem.id)
        }
        .onTapGesture {
            textTapAction(textItem.id)
        }
        .gesture(
            DragGesture(minimumDistance: 1)
                .onChanged { value in
                    guard activeTextScaleID == nil else {
                        return
                    }

                    let textID = activeTextDragID ?? textItem.id

                    if activeTextDragID == nil {
                        activeTextDragID = textID
                        selectTextAction(textID)
                    }
                    dragTextAction(textID, value.translation, frameSize)
                }
                .onEnded { _ in
                    activeTextDragID = nil
                    endTextDragAction()
                }
        )
        .simultaneousGesture(
            MagnificationGesture()
                .onChanged { value in
                    let textID = activeTextScaleID ?? textItem.id

                    if activeTextScaleID == nil {
                        activeTextScaleID = textID
                        activeTextDragID = nil
                        endTextDragAction()
                        selectTextAction(textID)
                    }
                    scaleTextAction(textID, value, frameSize)
                }
                .onEnded { _ in
                    activeTextScaleID = nil
                    endTextScaleAction()
                }
        )
    }

    func textPreviewControlButton(
        systemName: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Circle()
                .fill(Color.baseWhite)
                .frame(
                    width: MainEditLayout.textPreviewControlSize,
                    height: MainEditLayout.textPreviewControlSize
                )
                .overlay {
                    Image(systemName: systemName)
                        .font(.system(size: MainEditLayout.textPreviewControlIconSize, weight: .bold))
                        .foregroundStyle(Color.gray400)
                }
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    func stickerLayer(frameSize: CGSize) -> some View {
        if isStickerEditingEnabled {
            stickerViews(frameSize: frameSize)
                .frame(width: frameSize.width, height: frameSize.height)
                .contentShape(Rectangle())
                .gesture(stickerDragGesture(frameSize: frameSize))
                .simultaneousGesture(stickerScaleGesture(frameSize: frameSize))
        } else {
            stickerViews(frameSize: frameSize)
                .frame(width: frameSize.width, height: frameSize.height)
                .allowsHitTesting(false)
        }
    }

    func stickerViews(frameSize: CGSize) -> some View {
        ZStack {
            ForEach(orderedStickers) { sticker in
                stickerView(sticker, frameSize: frameSize)
            }
        }
    }

    func stickerView(_ sticker: MainEditStickerItem, frameSize: CGSize) -> some View {
        let stickerSize = restoredStickerSize(for: sticker, in: frameSize)

        return ZStack {
            Image(sticker.source.imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)

            if sticker.id == selectedStickerID {
                RoundedRectangle(cornerRadius: 4, style: .continuous)
                    .stroke(Color.brandPrimary, lineWidth: 2)
            }
        }
        .frame(width: stickerSize.width, height: stickerSize.height)
        .position(restoredStickerCenter(for: sticker, in: frameSize))
        .zIndex(Double(sticker.zIndex))
        .allowsHitTesting(false)
    }

    func stickerDragGesture(frameSize: CGSize) -> some Gesture {
        DragGesture(minimumDistance: 0, coordinateSpace: .local)
            .onChanged { value in
                let stickerID = activeStickerDragID ?? stickerHitTestID(
                    at: value.startLocation,
                    frameSize: frameSize
                )

                guard let stickerID else {
                    return
                }

                if activeStickerDragID == nil {
                    activeStickerDragID = stickerID
                    selectStickerAction(stickerID)
                }
                dragStickerAction(stickerID, value.translation, frameSize)
            }
            .onEnded { _ in
                activeStickerDragID = nil
                endStickerDragAction()
            }
    }

    func stickerScaleGesture(frameSize: CGSize) -> some Gesture {
        MagnificationGesture()
            .onChanged { value in
                guard let selectedStickerID else {
                    return
                }

                scaleStickerAction(selectedStickerID, value, frameSize)
            }
            .onEnded { _ in
                endStickerScaleAction()
            }
    }

    func stickerHitTestID(
        at location: CGPoint,
        frameSize: CGSize
    ) -> MainEditStickerItem.ID? {
        orderedStickers.reversed().first { sticker in
            stickerHitTestRect(for: sticker, in: frameSize).contains(location)
        }?.id
    }

    func stickerHitTestRect(
        for sticker: MainEditStickerItem,
        in frameSize: CGSize
    ) -> CGRect {
        let stickerSize = restoredStickerSize(for: sticker, in: frameSize)
        let center = restoredStickerCenter(for: sticker, in: frameSize)

        return CGRect(
            x: center.x - stickerSize.width / 2,
            y: center.y - stickerSize.height / 2,
            width: stickerSize.width,
            height: stickerSize.height
        )
    }

    var orderedStickers: [MainEditStickerItem] {
        stickers.sorted { lhs, rhs in
            if lhs.zIndex == rhs.zIndex {
                return lhs.id.uuidString < rhs.id.uuidString
            }

            return lhs.zIndex < rhs.zIndex
        }
    }

    var orderedTexts: [MainEditTextItem] {
        texts.sorted { lhs, rhs in
            if lhs.zIndex == rhs.zIndex {
                return lhs.id.uuidString < rhs.id.uuidString
            }

            return lhs.zIndex < rhs.zIndex
        }
    }

    func restoredPhotoSize(in frameSize: CGSize) -> CGSize {
        CGSize(
            width: frameSize.width * framingResult.normalizedBasePhotoSize.width * framingResult.scale,
            height: frameSize.height * framingResult.normalizedBasePhotoSize.height * framingResult.scale
        )
    }

    func restoredOffset(in frameSize: CGSize) -> CGSize {
        CGSize(
            width: frameSize.width * framingResult.normalizedOffset.width,
            height: frameSize.height * framingResult.normalizedOffset.height
        )
    }

    func restoredStickerCenter(for sticker: MainEditStickerItem, in frameSize: CGSize) -> CGPoint {
        CGPoint(
            x: frameSize.width * sticker.normalizedCenter.x,
            y: frameSize.height * sticker.normalizedCenter.y
        )
    }

    func restoredTextCenter(for text: MainEditTextItem, in frameSize: CGSize) -> CGPoint {
        CGPoint(
            x: frameSize.width * text.normalizedCenter.x,
            y: frameSize.height * text.normalizedCenter.y
        )
    }

    func restoredStickerSize(for sticker: MainEditStickerItem, in frameSize: CGSize) -> CGSize {
        let baseScale = frameSize.width / MainEditLayout.designWidth

        return CGSize(
            width: MainEditLayout.stickerThumbnailSize.width * baseScale * sticker.scale,
            height: MainEditLayout.stickerThumbnailSize.height * baseScale * sticker.scale
        )
    }

    func textPreviewSize(for text: MainEditTextItem, in frameSize: CGSize) -> CGSize {
        let baseScale = frameSize.width / MainEditLayout.designWidth
        let maximumWidth = frameSize.width * MainEditLayout.textPreviewBoxWidthRatio * text.scale
        let minimumWidth = MainEditLayout.textPreviewBoxMinimumWidth * baseScale * text.scale
        let measuredWidth = measuredTextWidth(
            for: text,
            fontSize: textPreviewFontSize(for: text, in: frameSize)
        )
        let responsiveWidth = measuredWidth +
            MainEditLayout.textPreviewBoxHorizontalPadding * baseScale * text.scale

        return CGSize(
            width: min(max(responsiveWidth, minimumWidth), maximumWidth),
            height: MainEditLayout.textPreviewBoxHeight * baseScale * text.scale
        )
    }

    func textPreviewFontSize(for text: MainEditTextItem, in frameSize: CGSize) -> CGFloat {
        let baseScale = frameSize.width / MainEditLayout.designWidth

        return MainEditLayout.textPreviewTextFontSize * baseScale * text.scale
    }

    func measuredTextWidth(
        for text: MainEditTextItem,
        fontSize: CGFloat
    ) -> CGFloat {
        let fallbackStyle = text.styleRuns.first
        let font = UIFont(
            name: fallbackStyle?.font.fontName ?? MainEditTextFont.default.fontName,
            size: fontSize
        ) ?? UIFont.systemFont(ofSize: fontSize)

        return ceil((text.text as NSString).size(withAttributes: [.font: font]).width)
    }

    func attributedText(
        for text: MainEditTextItem,
        fontSize: CGFloat
    ) -> AttributedString {
        let fallbackStyle = text.styleRuns.first
        var attributedText = AttributedString(text.text)
        attributedText.font = .custom(
            fallbackStyle?.font.fontName ?? MainEditTextFont.default.fontName,
            size: fontSize
        )
        attributedText.foregroundColor = fallbackStyle?.color.color ?? MainEditTextColor.white.color

        text.styleRuns.forEach { styleRun in
            guard let stringRange = Range(
                NSRange(location: styleRun.start, length: styleRun.length),
                in: text.text
            ),
                  let lowerBound = AttributedString.Index(
                    stringRange.lowerBound,
                    within: attributedText
                  ),
                  let upperBound = AttributedString.Index(
                    stringRange.upperBound,
                    within: attributedText
                  ) else {
                return
            }

            attributedText[lowerBound..<upperBound].font = .custom(
                styleRun.font.fontName,
                size: fontSize
            )
            attributedText[lowerBound..<upperBound].foregroundColor = styleRun.color.color
        }

        return attributedText
    }
}
