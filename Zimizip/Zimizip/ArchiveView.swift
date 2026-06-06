import SwiftUI

struct ArchiveView: View {
    private let items = [
        ArchiveItem(imageNames: ["ArchiveReaction1", "ArchiveReaction2", "ArchiveReaction3"], title: "연 솔로지옥 등장 리...", count: "동영상 6개", overlayText: nil),
        ArchiveItem(imageNames: ["ArchiveReaction4", "ArchiveReaction5", "ArchiveReaction6"], title: "연 솔로지옥 등장 리...", count: "동영상 6개", overlayText: "+3"),
        ArchiveItem(imageNames: ["ArchiveReaction7"], title: "연 솔로지옥 등장 리...", count: "동영상 6개", overlayText: nil),
        ArchiveItem(imageNames: ["ArchiveReaction8", "ArchiveReaction9"], title: "연 솔로지옥 등장 리...", count: "동영상 6개", overlayText: nil)
    ]

    private let columns = [
        GridItem(.fixed(171), spacing: 20),
        GridItem(.fixed(171), spacing: 20)
    ]

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.archiveBackground
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    Text("보관함")
                        .font(Font.custom("Pretendard-Bold", size: 32))
                        .tracking(-1.28)
                        .foregroundStyle(Color.archiveText)
                        .padding(.top, 82)
                        .padding(.horizontal, 20)

                    HStack(spacing: 8) {
                        ArchiveFilterChip(icon: "play.square.fill", title: "리액션", isSelected: true)
                        ArchiveFilterChip(icon: "square.stack.3d.up.fill", title: "서프라이즈 카드", isSelected: false)
                    }
                    .padding(.top, 20)
                    .padding(.horizontal, 20)

                    LazyVGrid(columns: columns, spacing: 36) {
                        ForEach(items) { item in
                            ArchiveCard(item: item)
                        }
                    }
                    .padding(.top, 40)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 120)
                }
            }
            .ignoresSafeArea(edges: .top)

            ArchiveTabBar()
                .padding(.bottom, 38)
        }
    }
}

private struct ArchiveItem: Identifiable {
    let id = UUID()
    let imageNames: [String]
    let title: String
    let count: String
    let overlayText: String?
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
                .fixedSize(horizontal: true, vertical: false)
        }
        .foregroundStyle(isSelected ? Color.archiveOrange : Color.archiveChipText)
        .frame(height: 36)
        .padding(.horizontal, 12)
        .background(isSelected ? Color.archiveOrangeSoft : Color.archiveGray50)
        .overlay {
            if !isSelected {
                Capsule()
                    .stroke(Color.archiveGray200, lineWidth: 1)
            }
        }
        .clipShape(Capsule())
    }
}

private struct ArchiveCard: View {
    let item: ArchiveItem

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            ArchiveThumbnailView(item: item)

            HStack(alignment: .top, spacing: 6) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.title)
                        .font(Font.custom("Pretendard-SemiBold", size: 16))
                        .foregroundStyle(Color.archiveText)
                        .lineLimit(1)

                    Text(item.count)
                        .font(Font.custom("Pretendard-Regular", size: 14))
                        .foregroundStyle(Color.archiveGray400)
                        .lineLimit(1)
                }

                Spacer(minLength: 0)

                Image(systemName: "ellipsis")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(Color.archiveText)
                    .frame(width: 24, height: 24)
                    .padding(.top, 6)
            }
        }
        .frame(width: 171, alignment: .leading)
    }
}

private struct ArchiveThumbnailView: View {
    let item: ArchiveItem

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.archiveGray50)

            if item.imageNames.count == 1 {
                reactionImage(item.imageNames[0], width: 72, height: 108)
            } else if item.imageNames.count == 2 {
                reactionImage(item.imageNames[0], width: 60, height: 90)
                    .rotationEffect(.degrees(-13.43))
                    .offset(x: -26, y: -2)

                reactionImage(item.imageNames[1], width: 60, height: 90)
                    .rotationEffect(.degrees(13))
                    .offset(x: 25, y: -2)
            } else {
                reactionImage(item.imageNames[0], width: 60, height: 90)
                    .rotationEffect(.degrees(-13.43))
                    .offset(x: -34, y: 4)

                reactionImage(item.imageNames[1], width: 60, height: 90)
                    .offset(x: 0, y: -4)

                ZStack {
                    reactionImage(item.imageNames[2], width: 60, height: 90)

                    if let overlayText = item.overlayText {
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(Color(red: 74 / 255, green: 64 / 255, blue: 58 / 255).opacity(0.5))

                        Text(overlayText)
                            .font(Font.custom("Pretendard-SemiBold", size: 16))
                            .foregroundStyle(Color.archiveBackground)
                    }
                }
                .frame(width: 60, height: 90)
                .rotationEffect(.degrees(8.13))
                .offset(x: 32, y: 8)
            }
        }
        .frame(width: 171, height: 171)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private func reactionImage(_ name: String, width: CGFloat, height: CGFloat) -> some View {
        Image(name)
            .resizable()
            .scaledToFill()
            .frame(width: width, height: height)
            .clipShape(RoundedRectangle(cornerRadius: width == 72 ? 9.6 : 8, style: .continuous))
    }
}

private struct ArchiveTabBar: View {
    var body: some View {
        HStack(spacing: -8) {
            ArchiveTabBarItem(icon: "house.fill", title: "홈", isSelected: false)
            ArchiveTabBarItem(icon: "archivebox.fill", title: "보관함", isSelected: true)
        }
        .padding(.horizontal, 2)
        .padding(.vertical, 4)
        .background(
            Capsule()
                .fill(.white.opacity(0.65))
                .shadow(color: .black.opacity(0.12), radius: 20, x: 0, y: 8)
        )
        .overlay(
            Capsule()
                .stroke(.white.opacity(0.4), lineWidth: 1)
        )
        .frame(width: 208, height: 58)
    }
}

private struct ArchiveTabBarItem: View {
    let icon: String
    let title: String
    let isSelected: Bool

    var body: some View {
        VStack(spacing: 1) {
            Image(systemName: icon)
                .font(.system(size: 24, weight: .semibold))
                .frame(height: 28)

            Text(title)
                .font(.system(size: 10, weight: .semibold))
                .lineLimit(1)
        }
        .foregroundStyle(isSelected ? Color.archiveText : Color.archiveTabInactive)
        .frame(width: 102, height: 50)
        .background {
            if isSelected {
                Capsule()
                    .fill(Color.archiveTabSelection)
            }
        }
    }
}

private extension Color {
    static let archiveBackground = Color(red: 1.0, green: 252 / 255, blue: 250 / 255)
    static let archiveText = Color(red: 17 / 255, green: 17 / 255, blue: 17 / 255)
    static let archiveChipText = Color(red: 67 / 255, green: 52 / 255, blue: 46 / 255)
    static let archiveGray50 = Color(red: 250 / 255, green: 246 / 255, blue: 243 / 255)
    static let archiveGray200 = Color(red: 209 / 255, green: 199 / 255, blue: 192 / 255)
    static let archiveGray400 = Color(red: 100 / 255, green: 89 / 255, blue: 82 / 255)
    static let archiveOrange = Color(red: 1.0, green: 106 / 255, blue: 33 / 255)
    static let archiveOrangeSoft = Color(red: 1.0, green: 226 / 255, blue: 207 / 255)
    static let archiveTabInactive = Color(red: 153 / 255, green: 153 / 255, blue: 153 / 255)
    static let archiveTabSelection = Color(red: 237 / 255, green: 237 / 255, blue: 237 / 255)
}

#Preview {
    ArchiveView()
}
