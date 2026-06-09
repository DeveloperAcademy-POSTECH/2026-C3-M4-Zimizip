import SwiftUI
import UIKit

struct MainEditCompletedImageView: View {
    let framingResult: PhotoFramingResult
    let image: UIImage?
    let frameSize: CGSize
    var clipsToPhotoFrame = false

    @ViewBuilder
    var body: some View {
        if clipsToPhotoFrame {
            content
                .clipShape(
                    RoundedRectangle(
                        cornerRadius: PhotoFramingLayout.frameCornerRadius,
                        style: .continuous
                    )
                )
        } else {
            content
        }
    }
}

private extension MainEditCompletedImageView {
    @ViewBuilder
    var content: some View {
        if let image {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(width: frameSize.width, height: frameSize.height)
        } else {
            MainEditCanvas(
                framingResult: framingResult,
                image: nil,
                frameSize: frameSize
            )
        }
    }
}
