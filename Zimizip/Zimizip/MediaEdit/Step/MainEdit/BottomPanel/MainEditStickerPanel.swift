import SwiftUI

struct MainEditStickerPanel: View {
    let stickerSources: [MainEditStickerSource]
    let selectAction: (MainEditStickerSource) -> Void
    let cancelAction: () -> Void
    let confirmAction: () -> Void

    init(
        stickerSources: [MainEditStickerSource] = Array(MainEditStickerSource.allCases),
        selectAction: @escaping (MainEditStickerSource) -> Void = { _ in },
        cancelAction: @escaping () -> Void,
        confirmAction: @escaping () -> Void
    ) {
        self.stickerSources = stickerSources
        self.selectAction = selectAction
        self.cancelAction = cancelAction
        self.confirmAction = confirmAction
    }

    var body: some View {
        VStack(spacing: 0) {
            MainEditStickerThumbnailPanel(
                stickerSources: stickerSources,
                selectAction: selectAction
            )

            MainEditBottomPanelActionBar(
                title: MainEditLayout.stickerPanelTitle,
                cancelAction: cancelAction,
                confirmAction: confirmAction
            )
        }
        .background(MainEditLayout.bottomPanelBackgroundColor)
    }
}

#Preview {
    MainEditStickerPanel(
        cancelAction: {},
        confirmAction: {}
    )
    .frame(width: MainEditLayout.designWidth)
    .background(Color.black)
}
