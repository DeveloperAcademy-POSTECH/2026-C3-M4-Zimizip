import SwiftUI

struct MainEditStickerThumbnail: View {
    let source: MainEditStickerSource
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(source.imageName)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(
                    width: MainEditLayout.stickerThumbnailSize.width,
                    height: MainEditLayout.stickerThumbnailSize.height
                )
                .clipped()
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    MainEditStickerThumbnail(
        source: .greenFirecracker,
        action: {}
    )
    .padding()
    .background(Color.black)
}
