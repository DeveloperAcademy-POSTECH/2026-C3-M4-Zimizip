import SwiftUI
import UIKit

struct PhotoFramingEditingArea: View {
    let media: Data
    let backgroundColor: Color
    let sourcePreviewFrame: CGRect?
    let isLandscapeCapture: Bool

    var body: some View {
        GeometryReader { proxy in
            let frameSize = PhotoFramingLayout.frameSize(in: proxy.size)
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

                if isLandscapeCapture, let image, let photoSize {
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
    }
}

#Preview {
    PhotoFramingEditingArea(
        media: Data(),
        backgroundColor: .white,
        sourcePreviewFrame: nil,
        isLandscapeCapture: true
    )
    .frame(width: 402, height: 620)
}
