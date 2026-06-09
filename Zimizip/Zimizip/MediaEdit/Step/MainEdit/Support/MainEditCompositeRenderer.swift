import CoreGraphics
import UIKit

struct MainEditCompositeRenderer {
    static let shared = MainEditCompositeRenderer()

    func image(
        framingResult: PhotoFramingResult,
        image: UIImage,
        stickers: [MainEditStickerItem]
    ) -> UIImage {
        let outputSize = resolvedOutputSize(for: framingResult)
        let outputBounds = CGRect(origin: .zero, size: outputSize)
        let format = UIGraphicsImageRendererFormat()
        format.scale = image.scale
        format.opaque = true

        return UIGraphicsImageRenderer(size: outputSize, format: format).image { context in
            framingResult.backgroundColor.uiColor.setFill()
            context.fill(outputBounds)

            drawPhoto(image, framingResult: framingResult, outputSize: outputSize)
            drawStickers(stickers, outputSize: outputSize)
        }
    }
}

private extension MainEditCompositeRenderer {
    func resolvedOutputSize(for framingResult: PhotoFramingResult) -> CGSize {
        guard framingResult.frameSize.width > 0,
              framingResult.frameSize.height > 0 else {
            let width = MainEditLayout.maximumCanvasWidth

            return CGSize(width: width, height: width / MainEditLayout.canvasAspectRatio)
        }

        return framingResult.frameSize
    }

    func drawPhoto(
        _ image: UIImage,
        framingResult: PhotoFramingResult,
        outputSize: CGSize
    ) {
        let photoSize = CGSize(
            width: outputSize.width * framingResult.normalizedBasePhotoSize.width * framingResult.scale,
            height: outputSize.height * framingResult.normalizedBasePhotoSize.height * framingResult.scale
        )
        let offset = CGSize(
            width: outputSize.width * framingResult.normalizedOffset.width,
            height: outputSize.height * framingResult.normalizedOffset.height
        )
        let photoRect = CGRect(
            x: (outputSize.width - photoSize.width) / 2 + offset.width,
            y: (outputSize.height - photoSize.height) / 2 + offset.height,
            width: photoSize.width,
            height: photoSize.height
        )

        drawAspectFill(image, in: photoRect)
    }

    func drawStickers(_ stickers: [MainEditStickerItem], outputSize: CGSize) {
        orderedStickers(stickers).forEach { sticker in
            guard let stickerImage = UIImage(named: sticker.source.imageName) else {
                return
            }

            let stickerSize = restoredStickerSize(for: sticker, outputSize: outputSize)
            let center = CGPoint(
                x: outputSize.width * sticker.normalizedCenter.x,
                y: outputSize.height * sticker.normalizedCenter.y
            )
            let stickerRect = CGRect(
                x: center.x - stickerSize.width / 2,
                y: center.y - stickerSize.height / 2,
                width: stickerSize.width,
                height: stickerSize.height
            )

            drawAspectFit(stickerImage, in: stickerRect)
        }
    }

    func orderedStickers(_ stickers: [MainEditStickerItem]) -> [MainEditStickerItem] {
        stickers.sorted { lhs, rhs in
            if lhs.zIndex == rhs.zIndex {
                return lhs.id.uuidString < rhs.id.uuidString
            }

            return lhs.zIndex < rhs.zIndex
        }
    }

    func restoredStickerSize(for sticker: MainEditStickerItem, outputSize: CGSize) -> CGSize {
        let baseScale = outputSize.width / MainEditLayout.designWidth

        return CGSize(
            width: MainEditLayout.stickerThumbnailSize.width * baseScale * sticker.scale,
            height: MainEditLayout.stickerThumbnailSize.height * baseScale * sticker.scale
        )
    }

    func drawAspectFill(_ image: UIImage, in rect: CGRect) {
        guard image.size.width > 0,
              image.size.height > 0,
              rect.width > 0,
              rect.height > 0 else {
            return
        }

        let scale = max(rect.width / image.size.width, rect.height / image.size.height)
        let drawSize = CGSize(width: image.size.width * scale, height: image.size.height * scale)
        let drawRect = CGRect(
            x: rect.midX - drawSize.width / 2,
            y: rect.midY - drawSize.height / 2,
            width: drawSize.width,
            height: drawSize.height
        )

        guard let context = UIGraphicsGetCurrentContext() else {
            image.draw(in: drawRect)
            return
        }

        context.saveGState()
        context.clip(to: rect)
        image.draw(in: drawRect)
        context.restoreGState()
    }

    func drawAspectFit(_ image: UIImage, in rect: CGRect) {
        guard image.size.width > 0,
              image.size.height > 0,
              rect.width > 0,
              rect.height > 0 else {
            return
        }

        let scale = min(rect.width / image.size.width, rect.height / image.size.height)
        let drawSize = CGSize(width: image.size.width * scale, height: image.size.height * scale)
        let drawRect = CGRect(
            x: rect.midX - drawSize.width / 2,
            y: rect.midY - drawSize.height / 2,
            width: drawSize.width,
            height: drawSize.height
        )

        image.draw(in: drawRect)
    }
}

private extension PhotoFramingBackgroundColor {
    var uiColor: UIColor {
        switch self {
        case .white:
            return .white
        case .red:
            return UIColor(red: 1.0, green: 0.08, blue: 0.08, alpha: 1)
        case .orange:
            return UIColor(red: 1.0, green: 0.49, blue: 0.04, alpha: 1)
        case .yellow:
            return UIColor(red: 1.0, green: 0.90, blue: 0.0, alpha: 1)
        case .green:
            return UIColor(red: 0.13, green: 1.0, blue: 0.34, alpha: 1)
        }
    }
}
