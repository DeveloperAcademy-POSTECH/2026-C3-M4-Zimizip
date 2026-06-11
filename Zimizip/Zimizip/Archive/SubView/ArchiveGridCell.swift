import SwiftUI

struct ArchiveGridCell: View {
    let item: ArchiveDisplayItem
    let width: CGFloat
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 20) {
                ArchiveThumbnailView(thumbnail: item.thumbnail, width: width)

                HStack(alignment: .top, spacing: 6) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(item.title)
                            .font(Font.custom("Pretendard-SemiBold", size: 16))
                            .foregroundStyle(Color.textPrimary)
                            .lineLimit(1)

                        Text(item.count)
                            .font(Font.custom("Pretendard-Regular", size: 14))
                            .foregroundStyle(Color.gray400)
                            .lineLimit(1)
                    }

                    Spacer(minLength: 0)

                    Image(systemName: "ellipsis")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(Color.textPrimary)
                        .frame(width: 24, height: 24)
                        .padding(.top, 6)
                }
            }
            .frame(width: width, alignment: .leading)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ZStack {
        Color.backgroundPrimary
            .ignoresSafeArea()

        ArchiveGridCell(
            item: ArchivePreviewData.reactionDisplayItem(),
            width: 171,
            onTap: {}
        )
    }
}
