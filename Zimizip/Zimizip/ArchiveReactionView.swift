import SwiftUI

struct ArchiveReactionView: View {
    @State private var selectedArchiveMode: ArchiveMode = .reaction

    private let items = [
        ArchiveItem(imageNames: ["ArchiveReaction1", "ArchiveReaction2", "ArchiveReaction3"], cardFrameName: "ReactionCardFrame1", title: "아카데미 C6 시작 ...", count: "동영상 3개", overlayText: nil, opensDetail: true),
        ArchiveItem(imageNames: ["ArchiveReaction4", "ArchiveReaction5", "ArchiveReaction6"], cardFrameName: "ReactionCardFrame2", title: "우주대폭발 광경 ...", count: "동영상 6개", overlayText: "+3"),
        ArchiveItem(imageNames: ["ArchiveReaction7"], cardFrameName: "ReactionCardFrame3", title: "메이슨 결혼식 축가 ...", count: "동영상 1개", overlayText: nil),
        ArchiveItem(imageNames: ["ArchiveReaction8", "ArchiveReaction9"], cardFrameName: "ReactionCardFrame4", title: "도라네이션최고 ...", count: "동영상 2개", overlayText: nil)
    ]

    var body: some View {
        ZStack {
            if selectedArchiveMode == .reaction {
                archiveContent
                    .transition(.opacity)
            } else if selectedArchiveMode == .surpriseCard {
                ArchivedSurpriseCardView {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedArchiveMode = .reaction
                    }
                }
                .transition(.opacity)
            } else {
                ArchiveReactionDetailView(onBack: showArchiveReactionView)
                .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: selectedArchiveMode)
    }

    private func showArchiveReactionView() {
        withAnimation(.easeInOut(duration: 0.2)) {
            selectedArchiveMode = .reaction
        }
    }

    private var archiveContent: some View {
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
                            ArchiveFilterChip(icon: "play.square.fill", title: "리액션", isSelected: true)

                            Button {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    selectedArchiveMode = .surpriseCard
                                }
                            } label: {
                                ArchiveFilterChip(icon: "square.stack.3d.up.fill", title: "서프라이즈 카드", isSelected: false)
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.top, 20)

                        LazyVGrid(columns: columns, alignment: .center, spacing: 36) {
                            ForEach(items) { item in
                                if item.opensDetail {
                                    Button {
                                        withAnimation(.easeInOut(duration: 0.2)) {
                                            selectedArchiveMode = .reactionDetail
                                        }
                                    } label: {
                                        ArchiveCard(item: item, width: cardWidth)
                                    }
                                    .buttonStyle(.plain)
                                } else {
                                    ArchiveCard(item: item, width: cardWidth)
                                }
                            }
                        }
                        .padding(.top, 40)
                    }
                    .frame(width: contentWidth, alignment: .leading)
                    .frame(maxWidth: .infinity)
                    .padding(.bottom, 120)
                }
                .ignoresSafeArea(edges: .top)

                ArchiveTabBar()
                    .padding(.leading, contentLeading)
                    .padding(.bottom, 38)
            }
        }
    }
}

enum ArchiveMode {
    case reaction
    case surpriseCard
    case reactionDetail
}

private struct ArchiveItem: Identifiable {
    let id = UUID()
    let imageNames: [String]
    let cardFrameName: String
    let title: String
    let count: String
    let overlayText: String?
    let opensDetail: Bool

    init(
        imageNames: [String],
        cardFrameName: String,
        title: String,
        count: String,
        overlayText: String?,
        opensDetail: Bool = false
    ) {
        self.imageNames = imageNames
        self.cardFrameName = cardFrameName
        self.title = title
        self.count = count
        self.overlayText = overlayText
        self.opensDetail = opensDetail
    }
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
    let width: CGFloat

    var body: some View {
        let thumbnailSize = width

        VStack(alignment: .leading, spacing: 20) {
            ArchiveThumbnailView(item: item, size: thumbnailSize)

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

private struct ArchiveThumbnailView: View {
    let item: ArchiveItem
    let size: CGFloat

    var body: some View {
        let imageScale = size / 171

        ZStack {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.archiveGray50)

            if item.imageNames.count == 1 {
                reactionImage(item.imageNames[0], width: 72 * imageScale, height: 108 * imageScale)
            } else if item.imageNames.count == 2 {
                reactionImage(item.imageNames[0], width: 60 * imageScale, height: 90 * imageScale)
                    .rotationEffect(.degrees(-13.43))
                    .offset(x: -26 * imageScale, y: -2 * imageScale)

                reactionImage(item.imageNames[1], width: 60 * imageScale, height: 90 * imageScale)
                    .rotationEffect(.degrees(13))
                    .offset(x: 25 * imageScale, y: -2 * imageScale)
            } else {
                reactionImage(item.imageNames[0], width: 60 * imageScale, height: 90 * imageScale)
                    .rotationEffect(.degrees(-13.43))
                    .offset(x: -34 * imageScale, y: 4 * imageScale)

                reactionImage(item.imageNames[1], width: 60 * imageScale, height: 90 * imageScale)
                    .offset(x: 0, y: -4 * imageScale)

                ZStack {
                    reactionImage(item.imageNames[2], width: 60 * imageScale, height: 90 * imageScale)

                    if let overlayText = item.overlayText {
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(Color.archiveGray450.opacity(0.5))

                        Text(overlayText)
                            .font(Font.custom("Pretendard-SemiBold", size: 16))
                            .foregroundStyle(Color.archiveBackground)
                    }
                }
                .frame(width: 60 * imageScale, height: 90 * imageScale)
                .rotationEffect(.degrees(8.13))
                .offset(x: 32 * imageScale, y: 8 * imageScale)
            }
        }
        .frame(width: size, height: size)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private func reactionImage(_ name: String, width: CGFloat, height: CGFloat) -> some View {
        ZStack(alignment: .bottomTrailing) {
            Image(name)
                .resizable()
                .scaledToFill()
                .frame(width: width, height: height)
                .clipShape(RoundedRectangle(cornerRadius: width == 72 ? 9.6 : 8, style: .continuous))

            Image(item.cardFrameName)
                .resizable()
                .scaledToFit()
                .frame(width: width * 0.34)
                .padding(width * 0.06)
        }
        .frame(width: width, height: height)
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
    static let archiveBackground = Color.backgroundPrimary
    static let archiveText = Color.textPrimary
    static let archiveChipText = Color.gray450
    static let archiveGray50 = Color.gray50
    static let archiveGray150 = Color.gray150
    static let archiveGray200 = Color.gray200
    static let archiveGray300 = Color.gray300
    static let archiveGray400 = Color.gray400
    static let archiveGray450 = Color.gray450
    static let archiveOrange = Color.primary
    static let archiveOrangeSoft = Color.primary.opacity(0.18)
    static let archiveTabInactive = Color.gray300
    static let archiveTabSelection = Color.gray100
}

#Preview {
    ArchiveReactionView()
}
