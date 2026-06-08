import SwiftUI
import UIKit

struct MainEditFilterPanel: View {
    @Binding var previewFilterPreset: MainEditFilterPreset

    let thumbnailImages: [MainEditFilterPreset: UIImage]
    let cancelAction: () -> Void
    let confirmAction: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            MainEditFilterThumbnailPanel(
                previewFilterPreset: $previewFilterPreset,
                thumbnailImages: thumbnailImages
            )

            MainEditBottomPanelActionBar(
                title: MainEditLayout.filterPanelTitle,
                cancelAction: cancelAction,
                confirmAction: confirmAction
            )
        }
        .background(MainEditLayout.bottomPanelBackgroundColor)
    }
}

#Preview {
    @Previewable @State var previewFilterPreset: MainEditFilterPreset = .original

    MainEditFilterPanel(
        previewFilterPreset: $previewFilterPreset,
        thumbnailImages: [:],
        cancelAction: {},
        confirmAction: {}
    )
    .background(Color.black)
}
