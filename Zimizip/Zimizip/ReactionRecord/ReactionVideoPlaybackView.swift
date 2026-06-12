import AVFoundation
import Photos
import SwiftUI
import UIKit

struct ReactionVideoPlaybackView: View {
    @Environment(\.scenePhase) private var scenePhase

    let title: String
    let subtitle: String
    let videoURL: URL
    let onBack: () -> Void

    @State private var player: AVPlayer
    @State private var isPlaying = false
    @State private var playbackProgress: CGFloat = 0
    @State private var timeObserverToken: Any?
    @State private var videoAspectRatio: CGFloat = 2.0 / 3.0
    @State private var isShowingPhotoLibraryPermissionSettingsPrompt = false
    @State private var didOpenPhotoLibraryPermissionSettings = false
    @State private var saveAlertMessage: String?
    @State private var isSavingVideo = false

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
            let bottomPadding = proxy.safeAreaInsets.bottom + 40
            let fixedVerticalSpace = proxy.safeAreaInsets.top
                + headerHeight
                + headerToPlayerSpacing
                + playerToControlSpacing
                + controlHeight
                + bottomPadding
            let maxCardHeight = max(120, proxy.size.height - fixedVerticalSpace)
            let preferredCardWidth = min(360, contentWidth)
            let maxVideoWidth = max(1, preferredCardWidth - ReactionVideoPlaybackCard.horizontalInset)
            let maxVideoHeight = max(1, maxCardHeight - ReactionVideoPlaybackCard.verticalInset)
            let preferredVideoHeight = maxVideoWidth / videoAspectRatio
            let videoHeight = min(preferredVideoHeight, maxVideoHeight)
            let videoWidth = min(maxVideoWidth, videoHeight * videoAspectRatio)
            let cardWidth = videoWidth + ReactionVideoPlaybackCard.horizontalInset
            let cardHeight = videoHeight + ReactionVideoPlaybackCard.verticalInset

            ZStack {
                Color.backgroundPrimary
                    .ignoresSafeArea()

                VStack {
                    ReactionVideoPlaybackHeader(
                        title: title,
                        subtitle: subtitle,
                        onBack: onBack,
                        onSave: {
                            Task {
                                await saveReactionVideoToPhotoLibrary()
                            }
                        }
                    )
                    .frame(width: contentWidth, height: headerHeight)

                    Spacer()

                    ReactionVideoPlaybackCard(
                        player: player
                    )
                    .frame(width: cardWidth, height: cardHeight)

                    Spacer()

                    ReactionVideoPlaybackControlBar(
                        isPlaying: isPlaying,
                        progress: playbackProgress,
                        onPlayToggle: togglePlayback
                    )
                    .frame(width: contentWidth, height: controlHeight)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .padding(.bottom, 44)

                if isShowingPhotoLibraryPermissionSettingsPrompt {
                    PermissionSettingsPrompt(
                        title: "리액션 영상 저장을 위해 권한이 필요합니다",
                        message: "사진 접근을 허용하면 완성된 리액션 영상을 사진 보관함에 저장할 수 있습니다. ‘설정’에서 사진 접근을 허용해 주십시오.",
                        onMoveToSettings: moveToPhotoLibraryPermissionSettings,
                        onLater: {
                            isShowingPhotoLibraryPermissionSettingsPrompt = false
                        }
                    )
                    .transition(.opacity.combined(with: .scale(scale: 0.98)))
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .alert(
            "리액션 영상",
            isPresented: Binding(
                get: { saveAlertMessage != nil },
                set: { isPresented in
                    if !isPresented {
                        saveAlertMessage = nil
                    }
                }
            )
        ) {
            Button("확인") {
                saveAlertMessage = nil
            }
        } message: {
            Text(saveAlertMessage ?? "")
        }
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
        .onChange(of: scenePhase) { _, newPhase in
            guard newPhase == .active, didOpenPhotoLibraryPermissionSettings else {
                return
            }

            Task {
                await refreshPhotoLibraryAddAccessAfterReturningFromSettings()
            }
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

    private func saveReactionVideoToPhotoLibrary() async {
        guard !isSavingVideo else { return }
        isSavingVideo = true
        defer { isSavingVideo = false }

        let isAuthorized = await requestPhotoLibraryAddAccess()

        guard isAuthorized else {
            isShowingPhotoLibraryPermissionSettingsPrompt = true
            return
        }

        do {
            try await saveVideo()
            saveAlertMessage = "리액션 영상을 사진 보관함에 저장했어요."
        } catch {
            saveAlertMessage = "리액션 영상 저장에 실패했어요."
            print("[ReactionVideoPlayback] failed to save video: \(error.localizedDescription)")
        }
    }

    private func requestPhotoLibraryAddAccess() async -> Bool {
        switch PHPhotoLibrary.authorizationStatus(for: .addOnly) {
        case .authorized, .limited:
            return true
        case .notDetermined:
            let status = await PHPhotoLibrary.requestAuthorization(for: .addOnly)
            return status == .authorized || status == .limited
        case .denied, .restricted:
            return false
        @unknown default:
            return false
        }
    }

    private func saveVideo() async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            PHPhotoLibrary.shared().performChanges {
                PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: videoURL)
            } completionHandler: { didSave, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }

                guard didSave else {
                    continuation.resume(throwing: CocoaError(.fileWriteUnknown))
                    return
                }

                continuation.resume()
            }
        }
    }

    private func moveToPhotoLibraryPermissionSettings() {
        guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else {
            return
        }

        didOpenPhotoLibraryPermissionSettings = true
        UIApplication.shared.open(settingsURL) { didOpen in
            if !didOpen {
                Task { @MainActor in
                    didOpenPhotoLibraryPermissionSettings = false
                }
            }
        }
    }

    private func refreshPhotoLibraryAddAccessAfterReturningFromSettings() async {
        didOpenPhotoLibraryPermissionSettings = false

        let isAuthorized = await requestPhotoLibraryAddAccess()
        isShowingPhotoLibraryPermissionSettingsPrompt = !isAuthorized
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
    let onSave: () -> Void

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

            Button(action: onSave) {
                Image("download")
                    .resizable()
                    .frame(width: 24, height: 24)
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
    static let borderWidth: CGFloat = 6
    static let topInset = borderWidth
    static let horizontalInset = borderWidth * 2
    static let verticalInset = topInset + borderWidth

    let player: AVPlayer

    var body: some View {
        let cornerRadius: CGFloat = 24

        ZStack {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(Color.coverLine)

            ReactionVideoPlayerView(player: player, videoGravity: .resizeAspect)
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
                .padding(.top, Self.topInset)
                .padding(.horizontal, Self.borderWidth)
                .padding(.bottom, Self.borderWidth)

            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .stroke(Color.baseWhite, lineWidth: Self.borderWidth)
                .padding(Self.borderWidth)
        }
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
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
