import SwiftUI
import UIKit

struct MainEditCanvas: View {
    let framingResult: PhotoFramingResult
    let image: UIImage?

    var body: some View {
        GeometryReader { proxy in
            let frameSize = PhotoFramingLayout.frameSize(in: proxy.size)

            ZStack {
                Color.black

                framedContent(frameSize: frameSize)
            }
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
        }
        .frame(width: frameSize.width, height: frameSize.height)
        .clipShape(RoundedRectangle(cornerRadius: PhotoFramingLayout.frameCornerRadius, style: .continuous))
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
}
