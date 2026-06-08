import SwiftUI

struct ArchivedSurpriseCardView: View {
    var onSelectReaction: () -> Void = {}

    private let items = [
        ArchivedSurpriseCardItem(title: "지나 쇼미 1차 합격", count: "동영상 3개", imageName: "ArchivedSurpriseCard1"),
        ArchivedSurpriseCardItem(title: "연 솔로지옥 등장 리...", count: "동영상 4개", imageName: "ArchivedSurpriseCard2"),
        ArchivedSurpriseCardItem(title: "쓔 흑백요리사 우승", count: "동영상 1개", imageName: "ArchivedSurpriseCard3"),
        ArchivedSurpriseCardItem(title: "토바에 로또 당첨", count: "동영상 2개", imageName: "ArchivedSurpriseCard4")
    ]

    var body: some View {
        GeometryReader { geometry in
            let horizontalPadding: CGFloat = 20
            let columnSpacing: CGFloat = 20
            let availableWidth = geometry.size.width - (horizontalPadding * 2) - columnSpacing
            let cardWidth = min(171, max(120, availableWidth / 2))
            let contentWidth = (cardWidth * 2) + columnSpacing
            let contentLeading = max(horizontalPadding, (geometry.size.width - contentWidth) / 2)
            let columns = [
                GridItem(.fixed(cardWidth), spacing: columnSpacing),
                GridItem(.fixed(cardWidth), spacing: 0)
            ]

            ZStack(alignment: .bottomLeading) {
                Color.archiveBackground
                    .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {
                        Text("보관함")
                            .font(Font.custom("Pretendard-Bold", size: 32))
                            .tracking(-1.28)
                            .foregroundStyle(Color.archiveText)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top, 82)

                        HStack(spacing: 8) {
                            Button {
                                onSelectReaction()
                            } label: {
                                ArchiveModeChip(icon: "play.square.fill", title: "리액션", isSelected: false)
                            }
                            .buttonStyle(.plain)

                            ArchiveModeChip(icon: "square.stack.3d.up.fill", title: "서프라이즈 카드", isSelected: true)
                        }
                        .padding(.top, 20)

                        LazyVGrid(columns: columns, alignment: .center, spacing: 38) {
                            ForEach(items) { item in
                                ArchivedSurpriseCardCell(item: item, width: cardWidth)
                            }
                        }
                        .padding(.top, 40)
                    }
                    .frame(width: contentWidth, alignment: .leading)
                    .frame(maxWidth: .infinity)
                    .padding(.bottom, 120)
                }
                .ignoresSafeArea(edges: .top)

                ArchiveBottomTabBar()
                    .padding(.leading, contentLeading)
                    .padding(.bottom, 38)
            }
        }
    }
}

private struct ArchivedSurpriseCardItem: Identifiable {
    let id = UUID()
    let title: String
    let count: String
    let imageName: String
}

private struct ArchivedSurpriseCardCell: View {
    let item: ArchivedSurpriseCardItem
    let width: CGFloat

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            ArchivedCardThumbnail(imageName: item.imageName)
                .frame(width: width, height: 180)

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
        .frame(width: width, alignment: .leading)
    }
}

private struct ArchivedCardThumbnail: View {
    let imageName: String

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(Color.archiveCoverLine)
                .frame(width: 120, height: 180)

            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(Color.archiveBaseWhite)
                .frame(width: 116, height: 174)

            Image(imageName)
                .resizable()
                .scaledToFill()
            .frame(width: 116, height: 174)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        }
        .frame(maxWidth: .infinity)
    }
}

private struct ArchiveModeChip: View {
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
        .foregroundStyle(isSelected ? Color.archiveOrange : Color.archiveText)
        .frame(height: 36)
        .padding(.horizontal, 12)
        .background(isSelected ? Color.archiveOrangeSoft : Color.archiveGray100)
        .overlay {
            if !isSelected {
                Capsule()
                    .stroke(Color.archiveGray200, lineWidth: 1)
            }
        }
        .clipShape(Capsule())
    }
}

private struct ArchiveBottomTabBar: View {
    var body: some View {
        HStack(spacing: -8) {
            ArchiveBottomTabBarItem(icon: "house.fill", title: "홈", isSelected: false)
            ArchiveBottomTabBarItem(icon: "archivebox.fill", title: "보관함", isSelected: true)
        }
        .padding(.horizontal, 2)
        .padding(.vertical, 4)
        .background(
            Capsule()
                .fill(Color.archiveBackground.opacity(0.65))
                .shadow(color: .black.opacity(0.12), radius: 20, x: 0, y: 8)
        )
        .overlay(
            Capsule()
                .stroke(Color.archiveGray50.opacity(0.4), lineWidth: 1)
        )
        .frame(width: 208, height: 58)
    }
}

private struct ArchiveBottomTabBarItem: View {
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
    static let archiveBackground = Color.backgroundPrimary
    static let archiveText = Color.textPrimary
    static let archiveGray50 = Color.gray50
    static let archiveGray100 = Color.gray100
    static let archiveGray200 = Color.gray200
    static let archiveGray400 = Color.gray400
    static let archiveOrange = Color.brandPrimary
    static let archiveOrangeSoft = Color.brandPrimary.opacity(0.18)
    static let archiveCoverLine = Color.coverLine
    static let archiveBaseWhite = Color.baseWhite
    static let archiveTabInactive = Color.gray300
    static let archiveTabSelection = Color.gray100
}

#Preview {
    ArchivedSurpriseCardView()
}
