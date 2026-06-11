import SwiftData
import SwiftUI

struct ReactionRecordView: View {
    @Environment(\.modelContext) private var modelContext

    @StateObject private var viewModel: ReactionRecordViewModel
    @State private var isShowingReactionVideoPlayback = false
    @State private var isShowingHome = false
    @State private var didSaveCompletedReaction = false
    let surpriseCardPayload: SurpriseCardPayload
    let surpriseProject: SurpriseProject?

    init(
        surpriseCardPayload: SurpriseCardPayload,
        surpriseProject: SurpriseProject? = nil,
        screenRecorder: VideoRecording? = nil,
        frontCameraRecorder: VideoRecording? = nil
    ) {
        self.surpriseCardPayload = surpriseCardPayload
        self.surpriseProject = surpriseProject
        _viewModel = StateObject(
            wrappedValue: ReactionRecordViewModel(
                screenRecorder: screenRecorder,
                frontCameraRecorder: frontCameraRecorder
            )
        )
    }

    var body: some View {
        ZStack {
            Color.backgroundPrimary
                .ignoresSafeArea()

            if viewModel.isRecordingCompleted {
                ReactionRecordCompleteView(
                    surpriseProjectTitle: surpriseCardPayload.title,
                    thumbnailImage: viewModel.reactionThumbnailImage,
                    onPrimaryButtonTap: {
                        guard viewModel.composedReactionVideoURL != nil else {
                            return
                        }

                        isShowingReactionVideoPlayback = true
                    },
                    onHomeButtonTap: {
                        isShowingHome = true
                    }
                )
            } else if viewModel.isGeneratingReactionVideo {
                ReactionVideoGeneratingView()
            } else {
                ZStack {
                    ReactionRecordingContentView(
                        surpriseCardPayload: surpriseCardPayload
                    ) {
                        Task {
                            await viewModel.stopRecording()
                        }
                    }
                    .onAppear {
                        viewModel.startRecordingTimerIfNeeded()
                    }
                    .onDisappear {
                        viewModel.stopRecordingTimer()
                    }

                    if viewModel.isBeforeReveal {
                        RevealGuideView().onTapGesture {
                            viewModel.hideRevealGuide()
                        }
                        .highPriorityGesture(
                            DragGesture(minimumDistance: 0).onChanged { value in
                                viewModel.hideRevealGuide()
                            }
                        )
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationDestination(isPresented: $isShowingReactionVideoPlayback) {
            if let composedReactionVideoURL = viewModel.composedReactionVideoURL {
                ReactionVideoPlaybackView(
                    title: surpriseCardPayload.title,
                    subtitle: "리액션 영상",
                    videoURL: composedReactionVideoURL
                ) {
                    isShowingReactionVideoPlayback = false
                }
            }
        }
        .fullScreenCover(isPresented: $isShowingHome) {
            HomeView()
        }
        .onChange(of: viewModel.isRecordingCompleted) { _, isRecordingCompleted in
            guard isRecordingCompleted else { return }
            saveCompletedReactionIfNeeded()
        }
    }

    private func saveCompletedReactionIfNeeded() {
        guard !didSaveCompletedReaction,
              let composedReactionVideoURL = viewModel.composedReactionVideoURL else {
            return
        }

        do {
            let archivedVideoURL = try copyReactionVideoToArchive(from: composedReactionVideoURL)
            let reactionContent = ReactionContent(
                videoURL: archivedVideoURL,
                thumbnailData: viewModel.reactionThumbnailImage?.jpegData(compressionQuality: 0.85)
            )

            if let surpriseProject {
                modelContext.insert(reactionContent)
                surpriseProject.reactionContents.append(reactionContent)
            } else {
                let surpriseProject = SurpriseProject(
                    name: surpriseCardPayload.title,
                    content: Content(
                        media: Media(source: surpriseCardPayload.framingResult.source),
                        box: surpriseCardPayload.coverImageName
                    ),
                    reactionContents: [reactionContent]
                )

                modelContext.insert(surpriseProject)
            }

            try modelContext.save()
            didSaveCompletedReaction = true
        } catch {
            print("[ReactionRecord] failed to save completed reaction: \(error.localizedDescription)")
        }
    }

    private func copyReactionVideoToArchive(from sourceURL: URL) throws -> URL {
        let fileManager = FileManager.default
        let archiveDirectory = try fileManager.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
        .appendingPathComponent("ReactionVideos", isDirectory: true)

        try fileManager.createDirectory(
            at: archiveDirectory,
            withIntermediateDirectories: true
        )

        let fileExtension = sourceURL.pathExtension.isEmpty ? "mp4" : sourceURL.pathExtension
        let destinationURL = archiveDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension(fileExtension)

        try fileManager.copyItem(at: sourceURL, to: destinationURL)
        return destinationURL
    }
}

#Preview {
    NavigationStack {
        ReactionRecordView(surpriseCardPayload: .previewValue)
    }
}
