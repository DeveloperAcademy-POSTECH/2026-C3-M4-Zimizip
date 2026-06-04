import Foundation
import Combine

@MainActor
final class ReactionRecordViewModel: ObservableObject {
    @Published var isBeforeReveal = true
    @Published var isRecordingCompleted = false
    @Published var isGeneratingReactionVideo = false
    @Published var recordingErrorMessage: String?
    @Published var isStoppingRecording = false
    @Published var recordingElapsedSeconds = 0
    @Published var screenRecordingURL: URL?
    @Published var frontCameraRecordingURL: URL?
    @Published var composedReactionVideoURL: URL?

    var recordingTimeText: String {
        let hours = recordingElapsedSeconds / 3600
        let minutes = recordingElapsedSeconds % 3600 / 60
        let seconds = recordingElapsedSeconds % 60

        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }

    private let screenRecorder: VideoRecording
    private let frontCameraRecorder: VideoRecording
    private let reactionVideoComposer: ReactionVideoComposing
    private var hasStartedRecording = false
    private var isComposingReactionVideo = false
    private var recordingTimerTask: Task<Void, Never>?

    init(
        screenRecorder: VideoRecording? = nil,
        frontCameraRecorder: VideoRecording? = nil,
        reactionVideoComposer: ReactionVideoComposing? = nil
    ) {
        self.screenRecorder = screenRecorder ?? ReplayKitScreenRecorder()
        self.frontCameraRecorder = frontCameraRecorder ?? AVFoundationFrontCameraRecorder()
        self.reactionVideoComposer = reactionVideoComposer ?? AVFoundationReactionVideoComposer()
    }

    deinit {
        recordingTimerTask?.cancel()
    }

    func startRecordingIfNeeded() async {
        guard !hasStartedRecording else { return }
        hasStartedRecording = true

        do {
            try await screenRecorder.startRecording()
            isBeforeReveal = true
        } catch {
            recordingErrorMessage = error.localizedDescription
        }
    }

    func stopRecording() async {
        guard !isStoppingRecording else { return }
        isStoppingRecording = true
        defer { isStoppingRecording = false }
        stopRecordingTimer()

        do {
            screenRecordingURL = try await screenRecorder.stopRecording()
            frontCameraRecordingURL = try await frontCameraRecorder.stopRecording()
            isGeneratingReactionVideo = true
        } catch {
            stopRemainingRecordersIfNeeded()
            isGeneratingReactionVideo = false
            recordingErrorMessage = error.localizedDescription
        }
    }

    func startFrontCameraRecording() async throws {
        try await frontCameraRecorder.startRecording()
    }

    func composeReactionVideoIfNeeded() async {
        guard canStartReactionVideoComposition() else { return }

        isComposingReactionVideo = true
        defer { isComposingReactionVideo = false }

        do {
            let composedVideoURL = try await makeReactionVideo()
            handleReactionVideoCompositionSuccess(composedVideoURL)
        } catch {
            handleReactionVideoCompositionFailure(error)
        }
    }

    func startRecordingTimerIfNeeded() {
        guard recordingTimerTask == nil else { return }
        recordingElapsedSeconds = 0

        recordingTimerTask = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(1))
                guard !Task.isCancelled else { return }

                await MainActor.run {
                    self?.recordingElapsedSeconds += 1
                }
            }
        }
    }

    func stopRecordingTimer() {
        recordingTimerTask?.cancel()
        recordingTimerTask = nil
    }

    func hideRevealGuide() {
        isBeforeReveal = false
    }

    func clearRecordingError() {
        recordingErrorMessage = nil
    }

    private func stopRemainingRecordersIfNeeded() {
        Task {
            if screenRecordingURL == nil {
                screenRecordingURL = try? await screenRecorder.stopRecording()
            }

            if frontCameraRecordingURL == nil {
                frontCameraRecordingURL = try? await frontCameraRecorder.stopRecording()
            }
        }
    }

    private func canStartReactionVideoComposition() -> Bool {
        guard isGeneratingReactionVideo else { return false }
        guard !isComposingReactionVideo else { return false }
        guard frontCameraRecordingURL != nil, screenRecordingURL != nil else {
            isGeneratingReactionVideo = false
            recordingErrorMessage = ReactionRecordError.missingRecordingFile.localizedDescription
            return false
        }
        return true
    }

    private func makeReactionVideo() async throws -> URL {
        guard let frontCameraRecordingURL, let screenRecordingURL else {
            throw ReactionRecordError.missingRecordingFile
        }

        return try await reactionVideoComposer.compose(
            frontCameraVideoURL: frontCameraRecordingURL,
            screenRecordingURL: screenRecordingURL
        )
    }

    private func handleReactionVideoCompositionSuccess(_ composedVideoURL: URL) {
        composedReactionVideoURL = composedVideoURL
        isGeneratingReactionVideo = false
        isRecordingCompleted = true
    }

    private func handleReactionVideoCompositionFailure(_ error: Error) {
        isGeneratingReactionVideo = false
        recordingErrorMessage = error.localizedDescription
    }
}

private enum ReactionRecordError: LocalizedError {
    case missingRecordingFile

    var errorDescription: String? {
        switch self {
        case .missingRecordingFile:
            return "리액션 영상 생성에 필요한 녹화 파일을 찾을 수 없습니다."
        }
    }
}
