import SwiftUI

struct ArchiveReactionDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedPlayerItem: ArchiveReactionDetailItem?

    var onBack: (() -> Void)?

    private let items = [
        ArchiveReactionDetailItem(title: "리액션 3", dateText: "금요일 오후 8:57", imageName: "ArchiveReaction1", cardFrameName: "ReactionCardFrame1", opensPlayer: true),
        ArchiveReactionDetailItem(title: "리액션 2", dateText: "5월 19일 오후 1:43", imageName: "ArchiveReaction2", cardFrameName: "ReactionCardFrame1"),
        ArchiveReactionDetailItem(title: "리액션 1", dateText: "5월 12일 오전 7:00", imageName: "ArchiveReaction3", cardFrameName: "ReactionCardFrame1")
    ]

    var body: some View {
        ZStack {
            if let selectedPlayerItem {
                ArchiveReactionPlayerView(
                    title: "아카데미 C6 시작 잇슈",
                    subtitle: selectedPlayerItem.title,
                    imageName: selectedPlayerItem.imageName,
                    cardFrameName: selectedPlayerItem.cardFrameName
                ) {
                    showReactionDetailList()
                }
                .transition(.opacity)
            } else {
                detailContent
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: selectedPlayerItem?.id)
    }

    private var detailContent: some View {
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
                Color.archiveDetailBackground
                    .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        ArchiveReactionDetailHeader(onBack: handleBack)
                            .padding(.top, 82)

                        LazyVGrid(columns: columns, alignment: .center, spacing: 38) {
                            ForEach(items) { item in
                                if item.opensPlayer {
                                    Button {
                                        withAnimation(.easeInOut(duration: 0.2)) {
                                            selectedPlayerItem = item
                                        }
                                    } label: {
                                        ArchiveReactionDetailCell(item: item, width: cardWidth)
                                    }
                                    .buttonStyle(.plain)
                                } else {
                                    ArchiveReactionDetailCell(item: item, width: cardWidth)
                                }
                            }

                            ArchiveReactionDetailAddCell(width: cardWidth)
                        }
                        .padding(.top, 43)
                    }
                    .frame(width: contentWidth, alignment: .center)
                    .frame(maxWidth: .infinity)
                    .padding(.bottom, 120)
                }
                .ignoresSafeArea(edges: .top)

                ArchiveReactionDetailTabBar()
                    .padding(.leading, contentLeading)
                    .padding(.bottom, 38)
            }
        }
    }

    private func handleBack() {
        if let onBack {
            onBack()
        } else {
            dismiss()
        }
    }

    private func showReactionDetailList() {
        withAnimation(.easeInOut(duration: 0.2)) {
            selectedPlayerItem = nil
        }
    }
}

private struct ArchiveReactionDetailItem: Identifiable {
    let id = UUID()
    let title: String
    let dateText: String
    let imageName: String
    let cardFrameName: String
    let opensPlayer: Bool

    init(
        title: String,
        dateText: String,
        imageName: String,
        cardFrameName: String,
        opensPlayer: Bool = false
    ) {
        self.title = title
        self.dateText = dateText
        self.imageName = imageName
        self.cardFrameName = cardFrameName
        self.opensPlayer = opensPlayer
    }
}

private struct ArchiveReactionDetailHeader: View {
    let onBack: () -> Void

    var body: some View {
        HStack {
            Button(action: onBack) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 24, weight: .medium))
                    .foregroundStyle(Color.archiveDetailGray450)
                    .frame(width: 38, height: 38)
                    .background(Color.archiveDetailGray100)
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)

            Spacer(minLength: 0)

            VStack(spacing: 4) {
                Text("아카데미 C6 시작 잇슈")
                    .font(Font.custom("Pretendard-SemiBold", size: 16))
                    .foregroundStyle(Color.archiveDetailText)

                Text("동영상 3개")
                    .font(Font.custom("Pretendard-Bold", size: 14))
                    .foregroundStyle(Color.archiveDetailText)
            }

            Spacer(minLength: 0)

            Color.clear
                .frame(width: 38, height: 38)
        }
        .frame(maxWidth: .infinity)
    }
}

private struct ArchiveReactionDetailCell: View {
    let item: ArchiveReactionDetailItem
    let width: CGFloat

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            ZStack(alignment: .bottomTrailing) {
                Image(item.imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 120, height: 180)
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

                Image(item.cardFrameName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 43)
                    .padding(.trailing, 7)
                    .padding(.bottom, 7)
            }
            .frame(width: 120, height: 180)
            .frame(maxWidth: .infinity)

            HStack(alignment: .top, spacing: 6) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.title)
                        .font(Font.custom("Pretendard-SemiBold", size: 16))
                        .foregroundStyle(Color.archiveDetailText)
                        .lineLimit(1)

                    Text(item.dateText)
                        .font(Font.custom("Pretendard-Bold", size: 14))
                        .foregroundStyle(Color.archiveDetailGray400)
                        .lineLimit(1)
                }

                Spacer(minLength: 0)

                Image(systemName: "ellipsis")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(Color.archiveDetailText)
                    .frame(width: 24, height: 24)
                    .padding(.top, 6)
            }
        }
        .frame(width: width, alignment: .leading)
    }
}

private struct ArchiveReactionDetailAddCell: View {
    let width: CGFloat

    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.archiveDetailGray50)
                    .frame(width: 120, height: 166)

                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(Color.archiveDetailOrange, style: StrokeStyle(lineWidth: 2, dash: [8, 6]))
                    .frame(width: 112, height: 158)

                Image(systemName: "plus")
                    .font(.system(size: 26, weight: .regular))
                    .foregroundStyle(Color.archiveDetailBaseWhite)
                    .frame(width: 40, height: 40)
                    .background(Color.archiveDetailOrange)
                    .clipShape(Circle())
            }
            .frame(width: width, height: 180)

            Color.clear
                .frame(height: 42)
        }
        .frame(width: width, alignment: .center)
    }
}

private struct ArchiveReactionDetailTabBar: View {
    var body: some View {
        HStack(spacing: -8) {
            ArchiveReactionDetailTabBarItem(icon: "house.fill", title: "홈", isSelected: false)
            ArchiveReactionDetailTabBarItem(icon: "archivebox.fill", title: "보관함", isSelected: true)
        }
        .padding(.horizontal, 2)
        .padding(.vertical, 4)
        .background(
            Capsule()
                .fill(Color.archiveDetailBackground.opacity(0.65))
                .shadow(color: .black.opacity(0.12), radius: 20, x: 0, y: 8)
        )
        .overlay(
            Capsule()
                .stroke(Color.archiveDetailGray50.opacity(0.4), lineWidth: 1)
        )
        .frame(width: 208, height: 58)
    }
}

private struct ArchiveReactionDetailTabBarItem: View {
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
        .foregroundStyle(isSelected ? Color.archiveDetailText : Color.archiveDetailTabInactive)
        .frame(width: 102, height: 50)
        .background {
            if isSelected {
                Capsule()
                    .fill(Color.archiveDetailTabSelection)
            }
        }
    }
}

private extension Color {
    static let archiveDetailBackground = Color("BackgroundPrimary")
    static let archiveDetailText = Color("TextPrimary")
    static let archiveDetailGray50 = Color("Gray50")
    static let archiveDetailGray100 = Color("Gray100")
    static let archiveDetailGray400 = Color("Gray400")
    static let archiveDetailGray450 = Color("Gray450")
    static let archiveDetailOrange = Color("BrandPrimary")
    static let archiveDetailBaseWhite = Color("BaseWhite")
    static let archiveDetailTabInactive = Color("Gray300")
    static let archiveDetailTabSelection = Color("Gray100")
}

#Preview {
    ArchiveReactionDetailView()
}
