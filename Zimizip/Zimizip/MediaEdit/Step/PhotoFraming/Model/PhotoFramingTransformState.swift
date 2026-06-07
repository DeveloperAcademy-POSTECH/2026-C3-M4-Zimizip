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
    var frameSize: CGSize = .zero
    var basePhotoSize: CGSize = .zero
    var scale: CGFloat = 1
    var offset: CGSize = .zero
    var sourceAspectRatio: CGFloat = 1

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
}
