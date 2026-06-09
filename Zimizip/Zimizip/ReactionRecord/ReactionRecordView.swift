import SwiftUI

struct ReactionRecordView: View {
    @StateObject private var viewModel: ReactionRecordViewModel
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
                    onPrimaryButtonTap: {},
                    onHomeButtonTap: {}
                )
            } else if viewModel.isGeneratingReactionVideo {
                ReactionVideoGeneratingView()
            } else {
                ZStack {
                    ReactionRecordingContentView(
                        recordingTimeText: viewModel.recordingTimeText,
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
    }
}

#Preview {
    NavigationStack {
        ReactionRecordView(surpriseCardPayload: .previewValue)
    }
}
