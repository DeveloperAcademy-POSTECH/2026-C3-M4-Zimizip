import SwiftUI

struct MediaEditView: View {
    @Environment(\.dismiss) private var dismiss

    let media: Data

    var body: some View {
        PhotoFramingView(
            media: media,
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
