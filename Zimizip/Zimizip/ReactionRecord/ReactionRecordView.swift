import SwiftUI

struct ReactionRecordView: View {
    @State private var isGeneratingReactionVideo = false
    @State private var isBeforeReveal = true

    var body: some View {
        ZStack {
            Color.backgroundPrimary
                .ignoresSafeArea()

            if isGeneratingReactionVideo {
                ReactionVideoGeneratingView()
            } else {
                ZStack {
                    ReactionRecordingContentView {
                        isGeneratingReactionVideo = true
                    }
                    .simultaneousGesture(
                        DragGesture(minimumDistance: 0).onChanged { _ in
                            isBeforeReveal = false
                        }
                    )

                    if isBeforeReveal {
                        RevealGuideView()
                            .allowsHitTesting(false)
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
