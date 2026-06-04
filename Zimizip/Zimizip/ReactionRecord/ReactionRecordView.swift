import SwiftUI

struct ReactionRecordView: View {
    @StateObject private var viewModel: ReactionRecordViewModel
    @State private var isShowingReactionVideoPreview = false

    init(
        screenRecorder: VideoRecording? = nil,
        frontCameraRecorder: VideoRecording? = nil,
        reactionVideoComposer: ReactionVideoComposing? = nil
    ) {
        _viewModel = StateObject(
            wrappedValue: ReactionRecordViewModel(
                screenRecorder: screenRecorder,
                frontCameraRecorder: frontCameraRecorder,
                reactionVideoComposer: reactionVideoComposer
            )
        )
    }

    var body: some View {
        ZStack {
            Color.backgroundPrimary
                .ignoresSafeArea()

            if isShowingReactionVideoPreview, let composedReactionVideoURL = viewModel.composedReactionVideoURL {
                ReactionVideoPreviewView(videoURL: composedReactionVideoURL)
            } else if viewModel.isRecordingCompleted {
                ReactionRecordCompleteView(
                    surpriseProjectTitle: "서프라이즈 프로젝트",
                    onPrimaryButtonTap: {
                        isShowingReactionVideoPreview = true
                    },
                    onHomeButtonTap: {}
                )
            } else if viewModel.isGeneratingReactionVideo {
                ReactionVideoGeneratingView()
                    .task {
                        await viewModel.composeReactionVideoIfNeeded()
                    }
            } else {
                ZStack {
                    ReactionRecordingContentView(recordingTimeText: viewModel.recordingTimeText) {
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
    }
}

#Preview {
    NavigationStack {
        ReactionRecordView()
    }
}
