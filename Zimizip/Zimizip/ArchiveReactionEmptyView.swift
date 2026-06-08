import SwiftUI

struct ArchiveReactionEmptyView: View {
    @State private var selectedArchiveMode: ArchiveMode = .reaction

    var body: some View {
        ZStack {
            if selectedArchiveMode == .reaction {
                emptyContent
                    .transition(.opacity)
            } else {
                ArchivedSurpriseCardView {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedArchiveMode = .reaction
                    }
                }
                .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: selectedArchiveMode)
    }

    private var emptyContent: some View {
        GeometryReader { geometry in
            let contentWidth = min(362, geometry.size.width - 40)
            let contentLeading = max(20, (geometry.size.width - contentWidth) / 2)

            ZStack(alignment: .bottomLeading) {
                Color.archiveBackground
                    .ignoresSafeArea()

                VStack(alignment: .leading, spacing: 0) {
                    Text("보관함")
                        .font(Font.custom("Pretendard-Bold", size: 32))
                        .tracking(-1.28)
                        .foregroundStyle(Color.archiveText)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 82)

                    HStack(spacing: 8) {
                        ArchiveEmptyModeChip(icon: "play.square.fill", title: "리액션", isSelected: true)

                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                selectedArchiveMode = .surpriseCard
                            }
                        } label: {
                            ArchiveEmptyModeChip(icon: "square.stack.3d.up.fill", title: "서프라이즈 카드", isSelected: false)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.top, 20)

                    Spacer(minLength: 0)
                }
                .frame(width: contentWidth, alignment: .leading)
                .frame(maxWidth: .infinity)
                .ignoresSafeArea(edges: .top)

                VStack(spacing: 20) {
                    Image("ArchiveEmptyCharacter")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 153, height: 178)

                    VStack(spacing: 8) {
                        Text("보관함이 비어있어요")
                            .font(Font.custom("Pretendard-Medium", size: 20))
                            .foregroundStyle(Color.archiveText)

                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                selectedArchiveMode = .surpriseCard
                            }
                        } label: {
                            HStack(spacing: 4) {
                                Text("서프라이즈 준비하기")
                                    .font(Font.custom("Pretendard-Bold", size: 20))

                                Image(systemName: "chevron.right")
                                    .font(.system(size: 16, weight: .bold))
                            }
                            .foregroundStyle(Color.archiveOrange)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .frame(width: 204, height: 273)
                .position(x: geometry.size.width / 2, y: geometry.size.height / 2 - 0.5)

                ArchiveEmptyTabBar()
                    .padding(.leading, contentLeading)
                    .padding(.bottom, 38)
            }
        }
    }
}

private struct ArchiveEmptyModeChip: View {
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

private struct ArchiveEmptyTabBar: View {
    var body: some View {
        HStack(spacing: -8) {
            ArchiveEmptyTabBarItem(icon: "house.fill", title: "홈", isSelected: false)
            ArchiveEmptyTabBarItem(icon: "archivebox.fill", title: "보관함", isSelected: true)
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

private struct ArchiveEmptyTabBarItem: View {
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
    static let archiveGray200 = Color.gray200
    static let archiveOrange = Color.brandPrimary
    static let archiveOrangeSoft = Color.brandPrimary.opacity(0.18)
    static let archiveTabInactive = Color.gray300
    static let archiveTabSelection = Color.gray100
}

#Preview {
    ArchiveReactionEmptyView()
}
