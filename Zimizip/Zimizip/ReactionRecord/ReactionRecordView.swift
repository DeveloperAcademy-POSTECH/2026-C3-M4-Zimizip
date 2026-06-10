import SwiftUI

struct ReactionRecordView: View {
    @StateObject private var viewModel: ReactionRecordViewModel
    @State private var isShowingReactionVideoPlayback = false
    @State private var isShowingHome = false
    let surpriseCardPayload: SurpriseCardPayload

    init(
        surpriseCardPayload: SurpriseCardPayload,
        screenRecorder: VideoRecording? = nil,
        frontCameraRecorder: VideoRecording? = nil
    ) {
        self.surpriseCardPayload = surpriseCardPayload
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
                    surpriseProjectTitle: "서프라이즈 프로젝트",
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
    }
}

#Preview {
    NavigationStack {
        ReactionRecordView(surpriseCardPayload: .previewValue)
    }
}
