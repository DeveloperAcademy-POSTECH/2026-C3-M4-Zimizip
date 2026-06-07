import SwiftUI

struct MediaEditView: View {
    @Environment(\.dismiss) private var dismiss

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
        PhotoFramingView(
            media: media,
            sourcePreviewFrame: sourcePreviewFrame,
            isLandscapeCapture: isLandscapeCapture,
            cancelButtonAction: {
                dismiss()
            },
            completeButtonAction: {}
        )
    }
}

#Preview {
    MediaEditView(media: Data())
}
