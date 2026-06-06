import SwiftUI

struct ReactionRecordView: View {
    @State private var isGeneratingReactionVideo = false

    var body: some View {
        ZStack {
            Color.backgroundPrimary
                .ignoresSafeArea()

            if isGeneratingReactionVideo {
                ReactionVideoGeneratingView()
            } else {
                ReactionRecordingContentView {
                    isGeneratingReactionVideo = true
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
