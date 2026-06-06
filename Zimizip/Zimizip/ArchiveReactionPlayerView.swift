import SwiftUI

struct ArchiveReactionPlayerView: View {
    let title: String
    let subtitle: String
    let imageName: String
    let cardFrameName: String
    let onBack: () -> Void

    @State private var isPlaying = false
    @State private var isSoundOn = true
    @State private var playbackProgress: CGFloat = 0
    @State private var playbackTask: Task<Void, Never>?

    private let playbackDuration: TimeInterval = 5

    var body: some View {
        GeometryReader { geometry in
            let headerTop: CGFloat = 82
            let headerHeight: CGFloat = 38
            let horizontalPadding: CGFloat = 20
            let contentWidth = min(362, geometry.size.width - (horizontalPadding * 2))
            let mediaHorizontalPadding: CGFloat = 27
            let mediaWidth = min(360, geometry.size.width - (mediaHorizontalPadding * 2))
            let mediaHeight = mediaWidth * 1.5
            let mediaTop = headerTop + headerHeight + 58
            let mediaCenterY = mediaTop + (mediaHeight / 2)
            let preferredControlCenterY = mediaTop + mediaHeight + 84
            let controlCenterY = min(preferredControlCenterY, geometry.size.height - 72)
            let scale = mediaWidth / 360

            ZStack {
                Color.reactionPlayerBackground
                    .ignoresSafeArea()

                ArchiveReactionPlayerHeader(title: title, subtitle: subtitle, onBack: onBack)
                    .frame(width: contentWidth)
                    .position(x: geometry.size.width / 2, y: headerTop + (headerHeight / 2))

                ArchiveReactionPlayerMedia(
                    imageName: imageName,
                    cardFrameName: cardFrameName,
                    width: mediaWidth,
                    height: mediaHeight,
                    scale: scale,
                    isPlaying: isPlaying,
                    progress: playbackProgress
                )
                .position(x: geometry.size.width / 2, y: mediaCenterY)

                ArchiveReactionPlaybackControl(
                    isPlaying: isPlaying,
                    isSoundOn: isSoundOn,
                    progress: playbackProgress,
                    onPlayToggle: {
                        togglePlayback()
                    },
                    onSoundToggle: {
                        withAnimation(.easeInOut(duration: 0.18)) {
                            isSoundOn.toggle()
                        }
                    }
                )
                .frame(width: contentWidth, height: 56)
                .position(x: geometry.size.width / 2, y: controlCenterY)
            }
        }
        .ignoresSafeArea()
        .onDisappear {
            playbackTask?.cancel()
        }
    }

    private func togglePlayback() {
        if isPlaying {
            playbackTask?.cancel()
            withAnimation(.easeInOut(duration: 0.18)) {
                isPlaying = false
            }
            return
        }

        if playbackProgress >= 1 {
            playbackProgress = 0
        }

        withAnimation(.easeInOut(duration: 0.18)) {
            isPlaying = true
        }

        playbackTask?.cancel()
        playbackTask = Task {
            let startProgress = playbackProgress
            let remainingDuration = playbackDuration * Double(1 - startProgress)
            let startDate = Date()

            while !Task.isCancelled {
                let elapsed = Date().timeIntervalSince(startDate)
                let nextProgress = min(1, startProgress + CGFloat(elapsed / remainingDuration) * (1 - startProgress))

                await MainActor.run {
                    playbackProgress = nextProgress
                }

                if nextProgress >= 1 {
                    await MainActor.run {
                        isPlaying = false
                    }
                    break
                }

                try? await Task.sleep(nanoseconds: 16_000_000)
            }
        }
    }
}

private struct ArchiveReactionPlayerHeader: View {
    let title: String
    let subtitle: String
    let onBack: () -> Void

    var body: some View {
        HStack {
            Button(action: onBack) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 24, weight: .medium))
                    .foregroundStyle(Color.reactionPlayerGray450)
                    .frame(width: 38, height: 38)
                    .background(Color.reactionPlayerGray100)
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)

            Spacer(minLength: 0)

            VStack(spacing: 4) {
                Text(title)
                    .font(Font.custom("Pretendard-SemiBold", size: 16))
                    .foregroundStyle(Color.reactionPlayerText)
                    .lineLimit(1)
                    .multilineTextAlignment(.center)

                Text(subtitle)
                    .font(Font.custom("Pretendard-Bold", size: 14))
                    .foregroundStyle(Color.reactionPlayerGray400)
                    .lineLimit(1)
                    .multilineTextAlignment(.center)
            }
            .frame(width: 200)

            Spacer(minLength: 0)

            Button {} label: {
                Image(systemName: "ellipsis")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(Color.reactionPlayerGray450)
                    .frame(width: 38, height: 38)
                    .background(Color.reactionPlayerGray100)
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
        }
    }
}

private struct ArchiveReactionPlayerMedia: View {
    let imageName: String
    let cardFrameName: String
    let width: CGFloat
    let height: CGFloat
    let scale: CGFloat
    let isPlaying: Bool
    let progress: CGFloat

    var body: some View {
        let surpriseAmount = isPlaying ? sin(progress * .pi * 8) : 0
        let zoom = isPlaying ? 1 + (0.035 * sin(min(progress * 2.4, 1) * .pi)) : 1
        let horizontalJolt = surpriseAmount * 2.4 * scale

        ZStack {
            RoundedRectangle(cornerRadius: 24 * scale, style: .continuous)
                .fill(Color.reactionPlayerCoverLine)

            ZStack(alignment: .bottomTrailing) {
                Image(imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: width - 12 * scale, height: height - 18 * scale)
                    .scaleEffect(zoom)
                    .offset(x: horizontalJolt)
                    .clipShape(RoundedRectangle(cornerRadius: 24 * scale, style: .continuous))
                    .animation(.easeInOut(duration: 0.08), value: progress)

                Image(cardFrameName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 96 * scale, height: 144 * scale)
                    .clipShape(RoundedRectangle(cornerRadius: 24 * scale, style: .continuous))
                    .padding(.trailing, 27 * scale)
                    .padding(.bottom, 27 * scale)
            }
            .frame(width: width - 12 * scale, height: height - 18 * scale)
            .overlay {
                RoundedRectangle(cornerRadius: 24 * scale, style: .continuous)
                    .stroke(Color.reactionPlayerWhite, lineWidth: 6 * scale)
            }
            .clipShape(RoundedRectangle(cornerRadius: 24 * scale, style: .continuous))
        }
        .frame(width: width, height: height)
        .clipShape(RoundedRectangle(cornerRadius: 24 * scale, style: .continuous))
    }
}

private struct ArchiveReactionPlaybackControl: View {
    let isPlaying: Bool
    let isSoundOn: Bool
    let progress: CGFloat
    let onPlayToggle: () -> Void
    let onSoundToggle: () -> Void

    var body: some View {
        HStack(spacing: 11) {
            Button(action: onPlayToggle) {
                Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(Color.reactionPlayerBlack)
                    .frame(width: 28, height: 28)
            }
            .buttonStyle(.plain)

            GeometryReader { geometry in
                let progressWidth = min(260, geometry.size.width)

                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.reactionPlayerGray150)
                        .frame(width: progressWidth, height: 8)

                    if progress > 0 {
                        Capsule()
                            .fill(Color.reactionPlayerGray250)
                            .frame(width: progressWidth * progress, height: 8)
                    }
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
            }
            .frame(width: 260, height: 28)

            Button(action: onSoundToggle) {
                Image(systemName: isSoundOn ? "speaker.wave.2.fill" : "speaker.slash.fill")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(Color.reactionPlayerBlack)
                    .frame(width: 28, height: 28)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Color.reactionPlayerWhite)
        .clipShape(Capsule())
        .shadow(color: .black.opacity(0.1), radius: 15, x: 1, y: 1)
    }
}

private extension Color {
    static let reactionPlayerBackground = Color("BackgroundPrimary")
    static let reactionPlayerText = Color("TextPrimary")
    static let reactionPlayerBlack = Color("BaseBlack")
    static let reactionPlayerWhite = Color("BaseWhite")
    static let reactionPlayerGray100 = Color("Gray100")
    static let reactionPlayerGray150 = Color("Gray150")
    static let reactionPlayerGray250 = Color("Gray250")
    static let reactionPlayerGray400 = Color("Gray400")
    static let reactionPlayerGray450 = Color("Gray450")
    static let reactionPlayerCoverLine = Color("CoverLine")
}

#Preview {
    ArchiveReactionPlayerView(
        title: "아카데미 C6 시작 잇슈",
        subtitle: "리액션 3",
        imageName: "ArchiveReaction1",
        cardFrameName: "ReactionCardFrame1"
    ) {}
}
