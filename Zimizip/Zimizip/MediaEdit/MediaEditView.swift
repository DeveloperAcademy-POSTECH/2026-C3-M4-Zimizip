import SwiftUI

struct MediaEditView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var photoFramingResult: PhotoFramingResult?

    let media: Data
    let sourcePreviewFrame: CGRect?
    let isLandscapeCapture: Bool

    init(
        media: Data,
        sourcePreviewFrame: CGRect? = nil,
        isLandscapeCapture: Bool = false
    ) {
        self.media = media
        self.sourcePreviewFrame = sourcePreviewFrame
        self.isLandscapeCapture = isLandscapeCapture
    }

    var body: some View {
        Group {
            if let photoFramingResult {
                MainEditView(
                    framingResult: photoFramingResult,
                    backButtonAction: returnToPhotoFraming,
                    completeButtonAction: completeEdit
                )
            } else {
                PhotoFramingView(
                    media: media,
                    sourcePreviewFrame: sourcePreviewFrame,
                    isLandscapeCapture: isLandscapeCapture,
                    cancelButtonAction: cancelEdit,
                    completeButtonAction: showMainEdit
                )
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

private extension MediaEditView {
    func cancelEdit() {
        dismiss()
    }

    func showMainEdit(with result: PhotoFramingResult) {
        photoFramingResult = result
    }

    func returnToPhotoFraming() {
        photoFramingResult = nil
    }

    func completeEdit() {
        dismiss()
    }
}

#Preview {
    MediaEditView(media: Data())
}
