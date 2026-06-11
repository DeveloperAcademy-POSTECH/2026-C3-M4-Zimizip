import SwiftData
import SwiftUI

struct ArchiveReactionView: View {
    @Query private var surpriseProjects: [SurpriseProject]

    @State private var selectedArchiveMode: ArchiveMode
    @State private var selectedSurpriseProject: SurpriseProject?
    @State private var isShowingMediaSourceOption = false

    let onHomeTabTap: () -> Void

    init(
        initialArchiveMode: ArchiveMode = .reaction,
        onHomeTabTap: @escaping () -> Void
    ) {
        _selectedArchiveMode = State(initialValue: initialArchiveMode)
        self.onHomeTabTap = onHomeTabTap
    }

    var body: some View {
        ZStack {
            if let selectedSurpriseProject {
                ArchiveReactionDetailView(surpriseProject: selectedSurpriseProject) {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        self.selectedSurpriseProject = nil
                    }
                }
                .transition(.opacity)
            } else {
                archiveContent()
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: selectedArchiveMode)
        .animation(.easeInOut(duration: 0.2), value: selectedSurpriseProject?.persistentModelID)
        .navigationDestination(isPresented: $isShowingMediaSourceOption) {
            MediaSourceOptionView()
                .navigationBarBackButtonHidden(true)
        }
    }

    private func archiveContent() -> some View {
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
            let items = displayItems(for: selectedArchiveMode)

            ZStack(alignment: .bottomLeading) {
                Color.backgroundPrimary
                    .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {
                        ArchiveHeaderView(
                            selectedArchiveMode: selectedArchiveMode,
                            onSelectArchiveMode: selectArchiveMode
                        )

                        if items.isEmpty {
                            Spacer(minLength: 0)
                                .frame(height: max(116, geometry.size.height * 0.22))

                            ArchiveEmptyStateView {
                                isShowingMediaSourceOption = true
                            }
                            .frame(maxWidth: .infinity)
                        } else {
                            LazyVGrid(columns: columns, alignment: .center, spacing: selectedArchiveMode.gridSpacingValue()) {
                                ForEach(items) { item in
                                    ArchiveGridCell(item: item, width: cardWidth) {
                                        showReactionDetailIfNeeded(for: item.surpriseProject)
                                    }
                                }
                            }
                            .padding(.top, 40)
                        }
                    }
                    .frame(width: contentWidth, alignment: .leading)
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: geometry.size.height, alignment: .top)
                    .padding(.bottom, 120)
                }
                .ignoresSafeArea(edges: .top)

                ArchiveTabBar(onHomeTap: onHomeTabTap)
                    .padding(.leading, contentLeading)
                    .padding(.bottom, 1)
            }
        }
    }

    private func selectArchiveMode(_ mode: ArchiveMode) {
        withAnimation(.easeInOut(duration: 0.2)) {
            selectedArchiveMode = mode
        }
    }

    private func showReactionDetailIfNeeded(for surpriseProject: SurpriseProject) {
        guard !surpriseProject.reactionContents.isEmpty else {
            return
        }

        withAnimation(.easeInOut(duration: 0.2)) {
            selectedSurpriseProject = surpriseProject
        }
    }

    private func displayItems(for mode: ArchiveMode) -> [ArchiveDisplayItem] {
        switch mode {
        case .reaction:
            return surpriseProjects
                .filter { !$0.reactionContents.isEmpty }
                .map { project in
                    let thumbnailData = project.reactionContents
                        .compactMap(\.thumbnailData)
                    let hiddenCount = max(project.reactionContents.count - min(thumbnailData.count, 3), 0)

                    return ArchiveDisplayItem(
                        surpriseProject: project,
                        title: project.name,
                        count: "동영상 \(project.reactionContents.count)개",
                        thumbnail: .reaction(
                            thumbnailData: Array(thumbnailData.prefix(3)),
                            overlayText: hiddenCount > 0 ? "+\(hiddenCount)" : nil
                        )
                    )
                }
        case .surpriseCard:
            return surpriseProjects.map { project in
                ArchiveDisplayItem(
                    surpriseProject: project,
                    title: project.name,
                    count: "동영상 \(project.reactionContents.count)개",
                    thumbnail: .surpriseCard(
                        coverImageName: project.content.box.isEmpty ? "HomeSurpriseCardCenter" : project.content.box
                    )
                )
            }
        }
    }
}

#Preview {
    ArchiveReactionView {}
        .modelContainer(ArchivePreviewData.modelContainer())
}
