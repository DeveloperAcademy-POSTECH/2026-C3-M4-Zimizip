import SwiftUI

struct ArchiveReactionDetailView: View {
    @State private var selectedPlayerItem: ArchiveReactionDetailPlayerItem?
    @State private var isShowingReactionRecordGuide = false

    let surpriseProject: SurpriseProject
    let onBack: () -> Void

    var body: some View {
        ZStack {
            if let selectedPlayerItem {
                ReactionVideoPlaybackView(
                    title: surpriseProject.name,
                    subtitle: selectedPlayerItem.title,
                    videoURL: selectedPlayerItem.reactionContent.videoURL
                ) {
                    showReactionDetailList()
                }
                .transition(.opacity)
            } else {
                detailContent()
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: selectedPlayerItem?.id)
        .navigationDestination(isPresented: $isShowingReactionRecordGuide) {
            ReactionRecordGuideView(
                surpriseCardPayload: surpriseProject.reactionRecordPayload(),
                surpriseProject: surpriseProject
            )
                .navigationBarBackButtonHidden(true)
        }
    }

    private func detailContent() -> some View {
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
                Color.backgroundPrimary
                    .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack {
                        ArchiveReactionDetailHeader(
                            title: surpriseProject.name,
                            reactionCount: surpriseProject.reactionContents.count,
                            onBack: handleBack
                        )
                        .padding(.top, 82)

                        LazyVGrid(columns: columns, alignment: .center, spacing: 38) {
                            ForEach(Array(surpriseProject.reactionContents.enumerated()), id: \.element.videoURL) { index, reactionContent in
                                let title = "리액션 \(index + 1)"
                                let dateText = formattedDate(reactionContent.createdAt)

                                Button {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        selectedPlayerItem = ArchiveReactionDetailPlayerItem(
                                            title: title,
                                            reactionContent: reactionContent
                                        )
                                    }
                                } label: {
                                    ArchiveReactionDetailCell(
                                        title: title,
                                        dateText: dateText,
                                        thumbnailData: reactionContent.thumbnailData,
                                        width: cardWidth
                                    )
                                }
                                .buttonStyle(.plain)
                            }

                            Button {
                                isShowingReactionRecordGuide = true
                            } label: {
                                ArchiveReactionDetailAddCell(width: cardWidth)
                            }
                            .buttonStyle(.plain)
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
        onBack()
    }

    private func formattedDate(_ date: Date) -> String {
        archiveReactionDateFormatter.string(from: date)
    }

    private func showReactionDetailList() {
        withAnimation(.easeInOut(duration: 0.2)) {
            selectedPlayerItem = nil
        }
    }
}

private let archiveReactionDateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "ko_KR")
    formatter.dateFormat = "M월 d일 a h:mm"
    return formatter
}()

private struct ArchiveReactionDetailPlayerItem: Identifiable {
    let id = UUID()
    let title: String
    let reactionContent: ReactionContent
}

#Preview {
    ArchiveReactionDetailView(
        surpriseProject: ArchivePreviewData.surpriseProject(),
        onBack: {}
    )
}
