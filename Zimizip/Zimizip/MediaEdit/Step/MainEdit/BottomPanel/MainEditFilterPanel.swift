import SwiftUI
import UIKit

struct MainEditFilterPanel: View {
    @Binding var selectedFilterPreset: MainEditFilterPreset

    let thumbnailImage: UIImage?
    let cancelAction: () -> Void
    let confirmAction: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            MainEditFilterThumbnailPanel(
                selectedFilterPreset: $selectedFilterPreset,
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
    @Previewable @State var selectedFilterPreset: MainEditFilterPreset = .original

    MainEditFilterPanel(
        selectedFilterPreset: $selectedFilterPreset,
        thumbnailImage: nil,
        cancelAction: {},
        confirmAction: {}
    )
    .background(Color.black)
}
