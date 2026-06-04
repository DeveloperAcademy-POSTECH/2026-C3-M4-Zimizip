import AVKit
import SwiftUI

struct ReactionVideoPreviewView: View {
    let videoURL: URL

    @State private var player: AVPlayer

    init(videoURL: URL) {
        self.videoURL = videoURL
        _player = State(initialValue: AVPlayer(url: videoURL))
    }

    var body: some View {
        ZStack {
            Color.backgroundPrimary
                .ignoresSafeArea()

            VideoPlayer(player: player)
                .ignoresSafeArea()
        }
        .onAppear {
            player.play()
        }
        .onDisappear {
            player.pause()
        }
    }
}

#Preview {
    ReactionVideoPreviewView(videoURL: URL(fileURLWithPath: "/tmp/reaction-video.mp4"))
}
