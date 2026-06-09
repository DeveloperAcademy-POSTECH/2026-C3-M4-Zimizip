import SwiftUI

struct MainEditStickerThumbnailPanel: View {
    let stickerSources: [MainEditStickerSource]
    let selectAction: (MainEditStickerSource) -> Void

    init(
        stickerSources: [MainEditStickerSource] = Array(MainEditStickerSource.allCases),
        selectAction: @escaping (MainEditStickerSource) -> Void = { _ in }
    ) {
        self.stickerSources = stickerSources
        self.selectAction = selectAction
    }

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .center, spacing: MainEditLayout.stickerThumbnailSpacing) {
                ForEach(stickerSources) { source in
                    MainEditStickerThumbnail(source: source) {
                        selectAction(source)
                    }
                }
            }
            .padding(MainEditLayout.stickerThumbnailPanelPadding)
        }
        .frame(maxWidth: .infinity)
        .frame(height: MainEditLayout.stickerThumbnailPanelHeight, alignment: .center)
        .background(MainEditLayout.bottomPanelBackgroundColor)
    }
}

#Preview {
    MainEditStickerThumbnailPanel()
        .frame(width: MainEditLayout.designWidth)
        .background(Color.black)
}
