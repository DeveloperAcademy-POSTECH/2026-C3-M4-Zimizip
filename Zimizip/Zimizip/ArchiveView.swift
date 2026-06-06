import SwiftUI

struct ArchiveView: View {
    private let items = [
        ArchiveItem(
            title: "지나 쇼미 1차 합격",
            count: "동영상 3개",
            thumbnail: .stack([
                ArchiveThumbnail(imageName: "ArchiveReaction1", offset: CGSize(width: -42, height: 3), rotation: -6.67),
                ArchiveThumbnail(imageName: "ArchiveReaction2", offset: CGSize(width: 42, height: 0), rotation: 11.58),
                ArchiveThumbnail(imageName: "ArchiveReaction3", offset: .zero, rotation: 0)
            ])
        ),
        ArchiveItem(
            title: "연 솔로지옥 등장 리...",
            count: "동영상 6개",
            thumbnail: .stack([
                ArchiveThumbnail(imageName: "ArchiveReaction4", offset: CGSize(width: -30, height: 4), rotation: -13.43),
                ArchiveThumbnail(imageName: "ArchiveReaction5", offset: CGSize(width: 0, height: -10), rotation: 0),
                ArchiveThumbnail(imageName: "ArchiveReaction6", offset: CGSize(width: 31, height: 8), rotation: 8.13, overlayText: "+1")
            ])
        ),
        ArchiveItem(
            title: "쓔 흑백요리사 우승",
            count: "동영상 1개",
            thumbnail: .single("ArchiveReaction9")
        ),
        ArchiveItem(
            title: "토바에 로또 당첨",
            count: "동영상 6개",
            thumbnail: .dashed([
                ArchiveThumbnail(imageName: "ArchiveReaction7", offset: CGSize(width: -32, height: -30), rotation: 0),
                ArchiveThumbnail(imageName: "ArchiveReaction8", offset: CGSize(width: 32, height: -30), rotation: 0)
            ])
        )
    ]

    private let columns = [
        GridItem(.fixed(171), spacing: 20),
        GridItem(.fixed(171), spacing: 20)
    ]

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.archiveBackground
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                Text("보관함")
                    .font(Font.custom("Pretendard-Bold", size: 32))
                    .foregroundStyle(Color.archiveText)
                    .padding(.top, 30)
                    .padding(.horizontal, 20)

                HStack(spacing: 8) {
                    ArchiveFilterChip(icon: "play.square.fill", title: "리액션", isSelected: true)
                    ArchiveFilterChip(icon: "square.stack.3d.up.fill", title: "서프라이즈 카드", isSelected: false)
                }
                .padding(.top, 16)
                .padding(.horizontal, 20)

                LazyVGrid(columns: columns, alignment: .center, spacing: 36) {
                    ForEach(items) { item in
                        ArchiveCard(item: item)
                    }
                }
                .padding(.top, 52)
                .padding(.horizontal, 20)

                Spacer()
            }

            ArchiveTabBar()
                .padding(.bottom, 38)
        }
    }
}

private struct ArchiveItem: Identifiable {
    let id = UUID()
    let title: String
    let count: String
    let thumbnail: ArchiveThumbnailStyle
}

private struct ArchiveThumbnail {
    let imageName: String
    let offset: CGSize
    let rotation: Double
    var overlayText: String?
}

private enum ArchiveThumbnailStyle {
    case stack([ArchiveThumbnail])
    case dashed([ArchiveThumbnail])
    case single(String)
}

private struct ArchiveFilterChip: View {
    let icon: String
    let title: String
    let isSelected: Bool

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .bold))

            Text(title)
                .font(Font.custom("Pretendard-Bold", size: 16))
        }
        .foregroundStyle(isSelected ? Color.orangePrimary : Color.archiveText)
        .frame(height: 36)
        .padding(.horizontal, 12)
        .background(isSelected ? Color.orangePrimary.opacity(0.18) : Color.archiveGray50)
        .clipShape(Capsule())
    }
}

private struct ArchiveCard: View {
    let item: ArchiveItem

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            ArchiveThumbnailView(style: item.thumbnail)

            HStack(alignment: .top, spacing: 6) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.title)
                        .font(Font.custom("Pretendard-SemiBold", size: 16))
                        .foregroundStyle(Color.archiveText)
                        .lineLimit(1)

                    Text(item.count)
                        .font(Font.custom("Pretendard-Regular", size: 14))
                        .foregroundStyle(Color.archiveGray400)
                }

                Spacer(minLength: 0)

                Image(systemName: "ellipsis")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(Color.archiveText)
                    .frame(width: 24, height: 24)
                    .padding(.top, 4)
            }
        }
        .frame(width: 171, alignment: .leading)
    }
}

private struct ArchiveThumbnailView: View {
    let style: ArchiveThumbnailStyle

    var body: some View {
        ZStack {
            Color.archiveGray50

            switch style {
            case .single(let imageName):
                Image(imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 171, height: 171)
                    .clipShape(RoundedRectangle(cornerRadius: 14))

            case .stack(let thumbnails):
                ForEach(Array(thumbnails.enumerated()), id: \.offset) { _, thumbnail in
                    stackedImage(thumbnail)
                }

            case .dashed(let thumbnails):
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color(red: 0.93, green: 0.89, blue: 0.80), style: StrokeStyle(lineWidth: 2, dash: [8, 6]))
                    .frame(width: 156, height: 156)

                ForEach(Array(thumbnails.enumerated()), id: \.offset) { _, thumbnail in
                    stackedImage(thumbnail)
                }
            }
        }
        .frame(width: 171, height: 171)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private func stackedImage(_ thumbnail: ArchiveThumbnail) -> some View {
        ZStack {
            Image(thumbnail.imageName)
                .resizable()
                .scaledToFill()
                .frame(width: 60, height: 60)
                .clipShape(RoundedRectangle(cornerRadius: 8))

            if let overlayText = thumbnail.overlayText {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.black.opacity(0.5))
                    .frame(width: 60, height: 60)

                Text(overlayText)
                    .font(Font.custom("Pretendard-SemiBold", size: 16))
                    .foregroundStyle(Color.archiveBackground)
            }
        }
        .rotationEffect(.degrees(thumbnail.rotation))
        .offset(thumbnail.offset)
    }
}

private struct ArchiveTabBar: View {
    var body: some View {
        HStack(spacing: 0) {
            ArchiveTabBarItem(icon: "house.fill", title: "홈", isSelected: true)
            ArchiveTabBarItem(icon: "archivebox.fill", title: "보관함", isSelected: false)
        }
        .padding(4)
        .background(.white.opacity(0.72))
        .clipShape(Capsule())
        .shadow(color: .black.opacity(0.12), radius: 20, x: 0, y: 8)
    }
}

private struct ArchiveTabBarItem: View {
    let icon: String
    let title: String
    let isSelected: Bool

    var body: some View {
        VStack(spacing: 1) {
            Image(systemName: icon)
                .font(.system(size: 22, weight: .semibold))

            Text(title)
                .font(.system(size: 10, weight: .semibold))
        }
        .foregroundStyle(isSelected ? Color.orangePrimary : Color.archiveGray400)
        .frame(width: 102, height: 52)
        .background(isSelected ? Color(red: 0.93, green: 0.93, blue: 0.93) : .clear)
        .clipShape(Capsule())
    }
}

private extension Color {
    static let archiveBackground = Color(red: 1.0, green: 0.99, blue: 0.98)
    static let archiveText = Color(red: 0.18, green: 0.16, blue: 0.15)
    static let archiveGray50 = Color(red: 0.98, green: 0.96, blue: 0.95)
    static let archiveGray400 = Color(red: 0.39, green: 0.35, blue: 0.32)
    static let OrangePrimary = Color(red: 1.0, green: 0.42, blue: 0.13)
}

#Preview {
    ArchiveView()
}
