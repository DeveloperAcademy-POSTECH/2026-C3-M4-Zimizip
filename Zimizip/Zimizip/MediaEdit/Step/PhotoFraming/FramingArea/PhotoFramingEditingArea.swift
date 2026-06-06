import SwiftUI
import UIKit

struct PhotoFramingEditingArea: View {
    let media: Data
    let backgroundColor: Color
    let sourcePreviewFrame: CGRect?
    let isLandscapeCapture: Bool

    var body: some View {
        GeometryReader { proxy in
            let availableWidth = max(proxy.size.width - 76, 0)
            let availableHeightWidth = max(proxy.size.height * 2 / 3 - 40, 0)
            let frameWidth = min(availableWidth, availableHeightWidth)
            let frameSize = CGSize(width: frameWidth, height: frameWidth * 3 / 2)
            let image = UIImage(data: media)
            let photoSize = image.map {
                PhotoFramingLayout.photoSize(
                    imageSize: $0.size,
                    frameSize: frameSize,
                    sourcePreviewFrame: sourcePreviewFrame,
                    isLandscapeCapture: isLandscapeCapture
                )
            }

            ZStack {
                Color.black

                if let image, let photoSize {
                    PhotoFramingPhotoLayer(
                        image: image,
                        contentMode: .fill
                    )
                    .frame(width: photoSize.width, height: photoSize.height)
                    .opacity(0.34)
                    .position(x: proxy.size.width / 2, y: proxy.size.height / 2)
                }

                PhotoFramingFrame(
                    image: image,
                    backgroundColor: backgroundColor,
                    frameSize: frameSize,
                    photoSize: photoSize
                )
                .position(x: proxy.size.width / 2, y: proxy.size.height / 2)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    PhotoFramingEditingArea(
        media: Data(),
        backgroundColor: .white,
        sourcePreviewFrame: nil,
        isLandscapeCapture: false
    )
    .frame(width: 402, height: 620)
}
