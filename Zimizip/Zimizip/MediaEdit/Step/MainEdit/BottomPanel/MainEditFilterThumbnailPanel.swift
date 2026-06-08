import SwiftUI
import UIKit

struct MainEditFilterThumbnailPanel: View {
    @Binding var previewFilterPreset: MainEditFilterPreset

    let thumbnailImages: [MainEditFilterPreset: UIImage]

    var body: some View {
        HStack(alignment: .top) {
            let presets = MainEditFilterPreset.allCases
            ForEach(Array(presets.enumerated()), id: \.element.id) { index, preset in
                MainEditFilterThumbnail(
                    preset: preset,
                    thumbnailImage: thumbnailImages[preset],
                    isSelected: previewFilterPreset == preset
                ) {
                    previewFilterPreset = preset
                }

                if index < presets.count - 1 {
                    Spacer(minLength: 0)
                }
            }
        }
        .padding(MainEditLayout.filterThumbnailPanelPadding)
        .frame(maxWidth: .infinity)
        .frame(height: MainEditLayout.filterThumbnailPanelHeight, alignment: .top)
        .background(MainEditLayout.bottomPanelBackgroundColor)
    }
}

#Preview {
    @Previewable @State var previewFilterPreset: MainEditFilterPreset = .original

    MainEditFilterThumbnailPanel(
        previewFilterPreset: $previewFilterPreset,
        thumbnailImages: [:]
    )
    .background(Color.black)
}
