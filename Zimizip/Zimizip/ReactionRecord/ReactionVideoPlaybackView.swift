import AVFoundation
import SwiftUI
import UIKit

struct ReactionVideoPlaybackView: View {
    let title: String
    let subtitle: String
    let videoURL: URL
    let onBack: () -> Void

    @State private var player: AVPlayer

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
            let playerWidth = min(360, contentWidth)
            let playerHeight = playerWidth * 1.5

            ZStack {
                Color.backgroundPrimary
                    .ignoresSafeArea()

                VStack {
                    ReactionVideoPlaybackHeader(
                        title: title,
                        subtitle: subtitle,
                        onBack: onBack
                    )
                    .padding(.horizontal, horizontalPadding)

                    Spacer()

                    ReactionVideoPlaybackCard(
                        player: player
                    )
                    .frame(width: playerWidth, height: playerHeight)

                    Spacer()

                    ReactionVideoPlaybackControlBar()
                        .frame(width: contentWidth, height: 56)

                    Spacer()
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .onDisappear {
            player.pause()
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

            ReactionVideoPlayerView(player: player)
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
    var body: some View {
        HStack(spacing: 11) {
            Image(systemName: "pause.fill")
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(Color.baseBlack)
                .frame(width: 28, height: 28)

            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.gray150)

                    Capsule()
                        .fill(Color.gray250)
                        .frame(width: proxy.size.width * 0.34)
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
