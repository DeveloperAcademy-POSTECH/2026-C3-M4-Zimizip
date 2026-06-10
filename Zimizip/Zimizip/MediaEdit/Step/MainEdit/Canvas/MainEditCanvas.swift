import SwiftUI
import UIKit

struct MainEditCanvas: View {
    let framingResult: PhotoFramingResult
    let image: UIImage?
    let frameSize: CGSize
    var texts: [MainEditTextItem] = []
    var selectedTextID: MainEditTextItem.ID?
    var textTapAction: (MainEditTextItem.ID) -> Void = { _ in }
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
        let photoSize = restoredPhotoSize(in: frameSize)

        return ZStack {
            framingResult.backgroundColor.color

            if let image {
                PhotoFramingPhotoLayer(
                    image: image,
                    contentMode: .fill
                )
                .frame(
                    width: photoSize.width,
                    height: photoSize.height
                )
                .offset(restoredOffset(in: frameSize))
            }

            textLayer(frameSize: frameSize)

            stickerLayer(frameSize: frameSize)
        }
        .frame(width: frameSize.width, height: frameSize.height)
        .clipShape(RoundedRectangle(cornerRadius: PhotoFramingLayout.frameCornerRadius, style: .continuous))
    }

    func textLayer(frameSize: CGSize) -> some View {
        ForEach(orderedTexts) { text in
            textPreviewLayer(text, frameSize: frameSize)
        }
    }

    func textPreviewLayer(_ textItem: MainEditTextItem, frameSize: CGSize) -> some View {
        let previewSize = textPreviewSize(for: textItem, in: frameSize)
        let style = textItem.styleRuns.first

        return ZStack {
            RoundedRectangle(cornerRadius: 0)
                .stroke(Color.baseWhite, lineWidth: MainEditLayout.textPreviewBoxBorderWidth)

            Text(textItem.text)
                .font(.custom(style?.font.fontName ?? MainEditTextFont.default.fontName, size: textPreviewFontSize(for: textItem, in: frameSize)))
                .foregroundStyle(style?.color.color ?? MainEditTextColor.white.color)
                .multilineTextAlignment(.center)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .padding(.horizontal, MainEditLayout.textPreviewControlSize)

            if selectedTextID == textItem.id {
                textPreviewControlButton(systemName: MainEditLayout.textPreviewCloseIconName)
                    .position(x: 0, y: 0)

                textPreviewControlButton(systemName: MainEditLayout.textPreviewDuplicateIconName)
                    .position(x: 0, y: previewSize.height)

                textPreviewControlButton(systemName: MainEditLayout.textPreviewResizeIconName)
                    .position(x: previewSize.width, y: previewSize.height)
            }
        }
        .frame(width: previewSize.width, height: previewSize.height)
        .position(restoredTextCenter(for: textItem, in: frameSize))
        .contentShape(Rectangle())
        .onTapGesture {
            textTapAction(textItem.id)
        }
    }

    func textPreviewControlButton(systemName: String) -> some View {
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
}
