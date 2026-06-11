import SwiftUI
import UIKit

struct PhotoFramingEditingArea: View {
    @State private var transformState = PhotoFramingTransformState()
    @State private var dragStartOffset: CGSize?
    @State private var pinchStartScale: CGFloat?

    let backgroundColor: Color
    let sourcePreviewFrame: CGRect?
    let isLandscapeCapture: Bool
    let transformChangeAction: (PhotoFramingTransformState?) -> Void
    private let image: UIImage?

    init(
        media: Data,
        backgroundColor: Color,
        sourcePreviewFrame: CGRect?,
        isLandscapeCapture: Bool,
        transformChangeAction: @escaping (PhotoFramingTransformState?) -> Void
    ) {
        self.backgroundColor = backgroundColor
        self.sourcePreviewFrame = sourcePreviewFrame
        self.isLandscapeCapture = isLandscapeCapture
        self.transformChangeAction = transformChangeAction
        self.image = UIImage(data: media)
    }

    var body: some View {
        GeometryReader { proxy in
            let frameSize = PhotoFramingLayout.frameSize(in: proxy.size)
            let transformLayout = transformLayout(
                frameSize: frameSize,
                containerSize: proxy.size
            )
            let currentTransformState = currentTransformState(
                for: transformLayout
            )

            ZStack {
                Color.black

                if let image,
                   let currentTransformState,
                   currentTransformState.hasOverflow {
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
            .clipped()
            .onAppear {
                transformState.reset(to: transformLayout)
                transformChangeAction(currentTransformState)
            }
            .onChange(of: transformLayout) { _, newValue in
                transformState.reset(to: newValue)
                transformChangeAction(newValue.map { PhotoFramingTransformState(layout: $0) })
            }
            .simultaneousGesture(dragGesture(for: transformLayout))
            .simultaneousGesture(pinchGesture(for: transformLayout))
        }
    }
}

private extension PhotoFramingEditingArea {
    func transformLayout(
        frameSize: CGSize,
        containerSize: CGSize
    ) -> PhotoFramingTransformLayout? {
        guard let image else {
            return nil
        }

        let basePhotoSize = PhotoFramingLayout.photoSize(
            imageSize: image.size,
            frameSize: frameSize,
            containerSize: containerSize,
            sourcePreviewFrame: sourcePreviewFrame,
            isLandscapeCapture: isLandscapeCapture
        )

        return PhotoFramingTransformLayout(
            frameSize: frameSize,
            basePhotoSize: basePhotoSize,
            minimumScale: PhotoFramingLayout.minimumScale(
                photoSize: basePhotoSize,
                frameSize: frameSize
            ),
            sourceAspectRatio: PhotoFramingLayout.sourceAspectRatio(
                imageSize: image.size,
                sourcePreviewFrame: sourcePreviewFrame,
                isLandscapeCapture: isLandscapeCapture
            )
        )
    }

    func currentTransformState(
        for layout: PhotoFramingTransformLayout?
    ) -> PhotoFramingTransformState? {
        guard let layout else {
            return nil
        }

        return transformState.resolved(for: layout)
    }

    func dragGesture(for layout: PhotoFramingTransformLayout?) -> some Gesture {
        DragGesture()
            .onChanged { value in
                guard let layout else {
                    return
                }

                var nextState = transformState.resolved(for: layout)
                let startOffset = dragStartOffset ?? nextState.offset
                dragStartOffset = startOffset
                nextState.updateOffset(
                    CGSize(
                        width: startOffset.width + value.translation.width,
                        height: startOffset.height + value.translation.height
                    )
                )
                transformState = nextState
                transformChangeAction(nextState)
            }
            .onEnded { _ in
                dragStartOffset = nil
            }
    }

    func pinchGesture(for layout: PhotoFramingTransformLayout?) -> some Gesture {
        MagnificationGesture()
            .onChanged { value in
                guard let layout else {
                    return
                }

                var nextState = transformState.resolved(for: layout)
                let startScale = pinchStartScale ?? nextState.scale
                pinchStartScale = startScale
                nextState.updateScale(startScale * value)
                transformState = nextState
                transformChangeAction(nextState)
            }
            .onEnded { _ in
                pinchStartScale = nil
            }
    }
}

#Preview {
    PhotoFramingEditingArea(
        media: Data(),
        backgroundColor: .white,
        sourcePreviewFrame: nil,
        isLandscapeCapture: true,
        transformChangeAction: { _ in }
    )
    .frame(width: 402, height: 620)
}
