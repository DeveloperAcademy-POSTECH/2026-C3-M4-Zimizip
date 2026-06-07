import SwiftUI
import UIKit

struct PhotoFramingEditingArea: View {
    @State private var transformState = PhotoFramingTransformState()

    let media: Data
    let backgroundColor: Color
    let sourcePreviewFrame: CGRect?
    let isLandscapeCapture: Bool

    var body: some View {
        GeometryReader { proxy in
            let frameSize = PhotoFramingLayout.frameSize(in: proxy.size)
            let image = UIImage(data: media)
            let transformLayout = image.map {
                PhotoFramingTransformLayout(
                    frameSize: frameSize,
                    basePhotoSize: PhotoFramingLayout.photoSize(
                        imageSize: $0.size,
                        frameSize: frameSize,
                        sourcePreviewFrame: sourcePreviewFrame,
                        isLandscapeCapture: isLandscapeCapture
                    ),
                    sourceAspectRatio: PhotoFramingLayout.sourceAspectRatio(
                        imageSize: $0.size,
                        sourcePreviewFrame: sourcePreviewFrame,
                        isLandscapeCapture: isLandscapeCapture
                    )
                )
            }
            let currentTransformState = transformLayout.map {
                transformState.resolved(for: $0)
            }

            ZStack {
                Color.black

                if isLandscapeCapture, let image, let currentTransformState {
                    PhotoFramingPhotoLayer(
                        image: image,
                        contentMode: .fill
                    )
                    .frame(
                        width: currentTransformState.photoSize.width,
                        height: currentTransformState.photoSize.height
                    )
                    .offset(currentTransformState.offset)
                    .opacity(0.34)
                    .position(x: proxy.size.width / 2, y: proxy.size.height / 2)
                }

                PhotoFramingFrame(
                    image: image,
                    backgroundColor: backgroundColor,
                    frameSize: frameSize,
                    transformState: currentTransformState
                )
                .position(x: proxy.size.width / 2, y: proxy.size.height / 2)
            }
            .onAppear {
                transformState.reset(to: transformLayout)
            }
            .onChange(of: transformLayout) { _, newValue in
                transformState.reset(to: newValue)
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
