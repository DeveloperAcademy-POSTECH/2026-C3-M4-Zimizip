import SwiftUI
import UIKit

struct MainEditCanvas: View {
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
                    selectTextAction(textItem.id)
                    dragTextAction(textItem.id, value.translation, frameSize)
                }
                .onEnded { _ in
                    endTextDragAction()
                }
        )
        .simultaneousGesture(
            MagnificationGesture()
                .onChanged { value in
                    selectTextAction(textItem.id)
                    scaleTextAction(textItem.id, value, frameSize)
                }
                .onEnded { _ in
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

    func stickerLayer(frameSize: CGSize) -> some View {
        ForEach(orderedStickers) { sticker in
            stickerView(sticker, frameSize: frameSize)
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
        .contentShape(Rectangle())
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { value in
                    selectStickerAction(sticker.id)
                    dragStickerAction(sticker.id, value.translation, frameSize)
                }
                .onEnded { _ in
                    endStickerDragAction()
                }
        )
        .simultaneousGesture(
            MagnificationGesture()
                .onChanged { value in
                    selectStickerAction(sticker.id)
                    scaleStickerAction(sticker.id, value, frameSize)
                }
                .onEnded { _ in
                    endStickerScaleAction()
                }
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

        return CGSize(
            width: frameSize.width * MainEditLayout.textPreviewBoxWidthRatio * text.scale,
            height: MainEditLayout.textPreviewBoxHeight * baseScale * text.scale
        )
    }

    func textPreviewFontSize(for text: MainEditTextItem, in frameSize: CGSize) -> CGFloat {
        let baseScale = frameSize.width / MainEditLayout.designWidth

        return MainEditLayout.textPreviewTextFontSize * baseScale * text.scale
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
