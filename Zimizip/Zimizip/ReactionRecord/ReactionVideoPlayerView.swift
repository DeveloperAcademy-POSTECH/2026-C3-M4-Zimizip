import AVFoundation
import SwiftUI

struct ReactionVideoPlayerView: UIViewRepresentable {
    let player: AVPlayer
    let videoGravity: AVLayerVideoGravity

    init(
        player: AVPlayer,
        videoGravity: AVLayerVideoGravity = .resizeAspectFill
    ) {
        self.player = player
        self.videoGravity = videoGravity
    }

    func makeUIView(context: Context) -> ReactionVideoPlayerContainerView {
        let view = ReactionVideoPlayerContainerView()
        view.playerLayer.player = player
        view.playerLayer.videoGravity = videoGravity
        return view
    }

    func updateUIView(_ uiView: ReactionVideoPlayerContainerView, context: Context) {
        uiView.playerLayer.player = player
        uiView.playerLayer.videoGravity = videoGravity
    }
}
