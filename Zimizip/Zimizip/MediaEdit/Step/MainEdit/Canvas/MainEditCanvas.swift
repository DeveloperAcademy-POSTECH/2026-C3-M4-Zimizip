import SwiftUI
import UIKit

struct MainEditCanvas: View {
    let framingResult: PhotoFramingResult
    let image: UIImage?
    let frameSize: CGSize
    var stickers: [MainEditStickerItem] = []
    var selectedStickerID: MainEditStickerItem.ID?
    var selectStickerAction: (MainEditStickerItem.ID) -> Void = { _ in }
    var dragStickerAction: (MainEditStickerItem.ID, CGSize, CGSize) -> Void = { _, _, _ in }
    var endStickerDragAction: () -> Void = {}

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

            stickerLayer(frameSize: frameSize)
        }
        .frame(width: frameSize.width, height: frameSize.height)
        .clipShape(RoundedRectangle(cornerRadius: PhotoFramingLayout.frameCornerRadius, style: .continuous))
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
    }

    var orderedStickers: [MainEditStickerItem] {
        stickers.sorted { lhs, rhs in
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

    func restoredStickerSize(for sticker: MainEditStickerItem, in frameSize: CGSize) -> CGSize {
        let baseScale = frameSize.width / MainEditLayout.designWidth

        return CGSize(
            width: MainEditLayout.stickerThumbnailSize.width * baseScale * sticker.scale,
            height: MainEditLayout.stickerThumbnailSize.height * baseScale * sticker.scale
        )
    }
}
