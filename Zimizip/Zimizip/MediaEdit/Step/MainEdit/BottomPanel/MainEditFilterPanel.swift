import SwiftUI
import UIKit

struct MainEditFilterPanel: View {
    @Binding var previewFilterPreset: MainEditFilterPreset

    let thumbnailImage: UIImage?
    let cancelAction: () -> Void
    let confirmAction: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            MainEditFilterThumbnailPanel(
                previewFilterPreset: $previewFilterPreset,
                thumbnailImage: thumbnailImage
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
        thumbnailImage: nil,
        cancelAction: {},
        confirmAction: {}
    )
    .background(Color.black)
}
