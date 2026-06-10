import AVFoundation
import SwiftUI
import UIKit

struct ReactionVideoPlaybackView: View {
    let title: String
    let subtitle: String
    let videoURL: URL
    let onBack: () -> Void

    @State private var player: AVPlayer
    @State private var isPlaying = false
    @State private var playbackProgress: CGFloat = 0
    @State private var timeObserverToken: Any?
    @State private var videoAspectRatio: CGFloat = 2.0 / 3.0

    init(
        title: String,
        subtitle: String,
        videoURL: URL,
        onBack: @escaping () -> Void
    ) {
        self.title = title
        self.subtitle = subtitle
        self.videoURL = videoURL
        self.onBack = onBack
        _player = State(initialValue: AVPlayer(url: videoURL))
    }

    var body: some View {
        GeometryReader { proxy in
            let horizontalPadding: CGFloat = 20
            let contentWidth = proxy.size.width - (horizontalPadding * 2)
            let headerHeight: CGFloat = 38
            let headerToPlayerSpacing: CGFloat = 44
            let playerToControlSpacing: CGFloat = 32
            let controlHeight: CGFloat = 56
            let controlBottomPadding = proxy.safeAreaInsets.bottom + 40
            let headerTopY = proxy.safeAreaInsets.top
            let headerCenterY = headerTopY + (headerHeight / 2)
            let controlCenterY = proxy.size.height - controlBottomPadding - (controlHeight / 2)
            let playerAreaTopY = headerTopY + headerHeight + headerToPlayerSpacing
            let playerAreaBottomY = controlCenterY - (controlHeight / 2) - playerToControlSpacing
            let maxPlayerHeight = max(120, playerAreaBottomY - playerAreaTopY)
            let preferredPlayerWidth = min(360, contentWidth)
            let preferredPlayerHeight = preferredPlayerWidth / videoAspectRatio
            let playerHeight = min(preferredPlayerHeight, maxPlayerHeight)
            let playerWidth = min(preferredPlayerWidth, playerHeight * videoAspectRatio)
            let playerCenterY = playerAreaTopY + (maxPlayerHeight / 2)

            ZStack {
                Color.backgroundPrimary
                    .ignoresSafeArea()

                ReactionVideoPlaybackHeader(
                    title: title,
                    subtitle: subtitle,
                    onBack: onBack
                )
                .frame(width: contentWidth, height: headerHeight)
                .position(x: proxy.size.width / 2, y: headerCenterY)

                ReactionVideoPlaybackCard(
                    player: player
                )
                .frame(width: playerWidth, height: playerHeight)
                .position(x: proxy.size.width / 2, y: playerCenterY)

                ReactionVideoPlaybackControlBar(
                    isPlaying: isPlaying,
                    progress: playbackProgress,
                    onPlayToggle: togglePlayback
                )
                .frame(width: contentWidth, height: controlHeight)
                .position(x: proxy.size.width / 2, y: controlCenterY)
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            addTimeObserverIfNeeded()
        }
        .task(id: videoURL) {
            await updateVideoAspectRatio()
        }
        .onReceive(
            NotificationCenter.default.publisher(
                for: .AVPlayerItemDidPlayToEndTime,
                object: player.currentItem
            )
        ) { _ in
            handlePlaybackEnd()
        }
        .onDisappear {
            player.pause()
            removeTimeObserver()
        }
    }

    private func togglePlayback() {
        if isPlaying {
            player.pause()
            isPlaying = false
            return
        }

        if playbackProgress >= 1 {
            player.seek(to: .zero)
            playbackProgress = 0
        }

        player.play()
        isPlaying = true
    }

    private func addTimeObserverIfNeeded() {
        guard timeObserverToken == nil else {
            return
        }

        let interval = CMTime(seconds: 0.1, preferredTimescale: 600)
        timeObserverToken = player.addPeriodicTimeObserver(
            forInterval: interval,
            queue: .main
        ) { time in
            updatePlaybackProgress(currentTime: time)
        }
    }

    private func removeTimeObserver() {
        guard let timeObserverToken else {
            return
        }

        player.removeTimeObserver(timeObserverToken)
        self.timeObserverToken = nil
    }

    private func updatePlaybackProgress(currentTime: CMTime) {
        guard let duration = player.currentItem?.duration.seconds,
              duration.isFinite,
              duration > 0 else {
            playbackProgress = 0
            return
        }

        playbackProgress = min(1, currentTime.seconds / duration)
    }

    private func handlePlaybackEnd() {
        isPlaying = false
        playbackProgress = 1
    }

    private func updateVideoAspectRatio() async {
        let asset = AVURLAsset(url: videoURL)

        do {
            guard let videoTrack = try await asset.loadTracks(withMediaType: .video).first else {
                return
            }

            let naturalSize = try await videoTrack.load(.naturalSize)
            let preferredTransform = try await videoTrack.load(.preferredTransform)
            let transformedSize = naturalSize.applying(preferredTransform)
            let width = abs(transformedSize.width)
            let height = abs(transformedSize.height)

            guard width > 0, height > 0 else {
                return
            }

            videoAspectRatio = width / height
        } catch {
            print("[ReactionVideoPlayback] failed to load video aspect ratio: \(error.localizedDescription)")
        }
    }
}

private struct ReactionVideoPlaybackHeader: View {
    let title: String
    let subtitle: String
    let onBack: () -> Void

    var body: some View {
        HStack {
            Button(action: onBack) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 24, weight: .medium))
                    .foregroundStyle(Color.gray450)
                    .frame(width: 38, height: 38)
                    .background(Color.gray100)
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)

            Spacer()

            VStack(spacing: 4) {
                Text(title)
                    .font(Font.custom("Pretendard-SemiBold", size: 16))
                    .foregroundStyle(Color.textPrimary)
                    .lineLimit(1)

                Text(subtitle)
                    .font(Font.custom("Pretendard-Bold", size: 14))
                    .foregroundStyle(Color.gray400)
                    .lineLimit(1)
            }

            Spacer()

            Button {} label: {
                Image("Ellipsis")
                    .resizable()
                    .frame(width: 16, height: 4)
                    .foregroundStyle(Color.gray400)
                    .frame(width: 38, height: 38)
                    .background(Color.gray100)
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
        }
    }
}

private struct ReactionVideoPlaybackCard: View {
    let player: AVPlayer

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.coverLine)

            ReactionVideoPlayerView(player: player, videoGravity: .resizeAspect)
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(Color.baseWhite, lineWidth: 6)
                }
                .padding(6)
        }
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }
}

private struct ReactionVideoPlaybackControlBar: View {
    let isPlaying: Bool
    let progress: CGFloat
    let onPlayToggle: () -> Void

    var body: some View {
        HStack(spacing: 11) {
            Button(action: onPlayToggle) {
                Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(Color.baseBlack)
                    .frame(width: 28, height: 28)
            }
            .buttonStyle(.plain)

            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.gray150)

                    Capsule()
                        .fill(Color.gray250)
                        .frame(width: proxy.size.width * progress)
                }
            }
            .frame(height: 8)

            Image(systemName: "speaker.wave.2.fill")
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(Color.baseBlack)
                .frame(width: 28, height: 28)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Color.baseWhite)
        .clipShape(Capsule())
        .shadow(color: .black.opacity(0.1), radius: 15, x: 1, y: 1)
    }
}

#Preview {
    ReactionVideoPlaybackView(
        title: "지나 쇼미 1차 합격",
        subtitle: "리액션 3",
        videoURL: URL(fileURLWithPath: "/dev/null")
    ) {}
}
