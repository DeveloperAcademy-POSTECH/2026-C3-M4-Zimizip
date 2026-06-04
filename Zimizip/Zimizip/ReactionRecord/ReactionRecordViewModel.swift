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
}
