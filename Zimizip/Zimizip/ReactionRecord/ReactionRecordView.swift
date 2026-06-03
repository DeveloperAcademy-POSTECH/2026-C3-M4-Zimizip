import SwiftUI

struct ReactionRecordView: View {
    @StateObject private var viewModel = ReactionRecordViewModel()

    var body: some View {
        ZStack {
            Color.backgroundPrimary
                .ignoresSafeArea()

            ZStack {
                ReactionRecordingContentView {
                    Task {
                        await viewModel.stopRecording()
                    }
                }
                .simultaneousGesture(
                    DragGesture(minimumDistance: 0).onChanged { _ in
                        viewModel.hideRevealGuide()
                    }
                )

                if viewModel.isBeforeReveal {
                    RevealGuideView()
                        .allowsHitTesting(false)
                }
            }
        }
        .task {
            await viewModel.startRecordingIfNeeded()
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    NavigationStack {
        ReactionRecordView()
    }
}
