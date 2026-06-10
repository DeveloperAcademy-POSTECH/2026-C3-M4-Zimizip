import Foundation
import Combine
import UIKit

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
    @Published var reactionThumbnailImage: UIImage?

    var recordingTimeText: String {
        let hours = recordingElapsedSeconds / 3600
        let minutes = recordingElapsedSeconds % 3600 / 60
        let seconds = recordingElapsedSeconds % 60

        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }

    private let screenRecorder: VideoRecording
    private let frontCameraRecorder: VideoRecording
    private let reactionVideoComposer: ReactionVideoComposing
    private let thumbnailGenerator = ReactionVideoThumbnailGenerator()
    private var hasStartedRecording = false
    private var recordingTimerTask: Task<Void, Never>?

    init(
        screenRecorder: VideoRecording? = nil,
        frontCameraRecorder: VideoRecording? = nil,
        reactionVideoComposer: ReactionVideoComposing? = nil
    ) {
        self.screenRecorder = screenRecorder ?? SampleBufferReactionVideoRecorder()
        self.frontCameraRecorder = frontCameraRecorder ?? NoOpVideoRecorder()
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
        isGeneratingReactionVideo = true
        stopRecordingTimer()

        do {
            screenRecordingURL = try await screenRecorder.stopRecording()
            frontCameraRecordingURL = try? await frontCameraRecorder.stopRecording()
            composedReactionVideoURL = try await composeReactionVideoIfNeeded()
            try await generateReactionThumbnailIfNeeded()
            isGeneratingReactionVideo = false
            isRecordingCompleted = true
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

    private func generateReactionThumbnailIfNeeded() async throws {
        guard let composedReactionVideoURL else {
            return
        }

        reactionThumbnailImage = try await thumbnailGenerator.thumbnail(from: composedReactionVideoURL)
    }

    private func composeReactionVideoIfNeeded() async throws -> URL? {
        guard let screenRecordingURL else {
            return nil
        }

        guard let frontCameraRecordingURL else {
            return screenRecordingURL
        }

        return try await reactionVideoComposer.compose(
            frontCameraVideoURL: frontCameraRecordingURL,
            screenRecordingURL: screenRecordingURL
        )
    }
}
