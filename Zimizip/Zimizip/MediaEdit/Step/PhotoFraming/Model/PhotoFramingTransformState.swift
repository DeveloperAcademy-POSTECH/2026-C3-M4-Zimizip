import CoreGraphics

struct PhotoFramingTransformLayout: Equatable {
    let frameSize: CGSize
    let basePhotoSize: CGSize
    let sourceAspectRatio: CGFloat

    var isValid: Bool {
        frameSize.width > 0 &&
        frameSize.height > 0 &&
        basePhotoSize.width > 0 &&
        basePhotoSize.height > 0 &&
        sourceAspectRatio > 0
    }
}

struct PhotoFramingTransformState {
    static let minimumScale: CGFloat = 1
    static let maximumScale: CGFloat = 4

    var frameSize: CGSize = .zero
    var basePhotoSize: CGSize = .zero
    var scale: CGFloat = 1
    var offset: CGSize = .zero
    var sourceAspectRatio: CGFloat = 1

    var isValid: Bool {
        frameSize.width > 0 &&
        frameSize.height > 0 &&
        basePhotoSize.width > 0 &&
        basePhotoSize.height > 0 &&
        scale > 0 &&
        sourceAspectRatio > 0
    }

    init() {}

    init(layout: PhotoFramingTransformLayout) {
        guard layout.isValid else {
            return
        }

        frameSize = layout.frameSize
        basePhotoSize = layout.basePhotoSize
        sourceAspectRatio = layout.sourceAspectRatio
    }

    var photoSize: CGSize {
        CGSize(
            width: basePhotoSize.width * scale,
            height: basePhotoSize.height * scale
        )
    }

    mutating func updateScale(_ newScale: CGFloat) {
        scale = min(
            max(newScale, Self.minimumScale),
            Self.maximumScale
        )
        offset = clampedOffset(offset)
    }

    mutating func updateOffset(_ newOffset: CGSize) {
        offset = clampedOffset(newOffset)
    }

    func resolved(for layout: PhotoFramingTransformLayout) -> PhotoFramingTransformState {
        isConfigured(for: layout) ? self : PhotoFramingTransformState(layout: layout)
    }

    mutating func reset(to layout: PhotoFramingTransformLayout?) {
        guard let layout else {
            self = PhotoFramingTransformState()
            return
        }

        self = PhotoFramingTransformState(layout: layout)
    }

    private func isConfigured(for layout: PhotoFramingTransformLayout) -> Bool {
        frameSize == layout.frameSize &&
        basePhotoSize == layout.basePhotoSize &&
        sourceAspectRatio == layout.sourceAspectRatio
    }

    private func clampedOffset(_ offset: CGSize) -> CGSize {
        let maximumOffsetX = abs(photoSize.width - frameSize.width) / 2
        let maximumOffsetY = abs(photoSize.height - frameSize.height) / 2

        return CGSize(
            width: min(max(offset.width, -maximumOffsetX), maximumOffsetX),
            height: min(max(offset.height, -maximumOffsetY), maximumOffsetY)
        )
    }
}
