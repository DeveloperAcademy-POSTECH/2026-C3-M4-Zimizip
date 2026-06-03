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

    var recordingTimeText: String {
        let hours = recordingElapsedSeconds / 3600
        let minutes = recordingElapsedSeconds % 3600 / 60
        let seconds = recordingElapsedSeconds % 60

        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }

    private let screenRecorder: ScreenRecording
    private var hasStartedRecording = false
    private var recordingTimerTask: Task<Void, Never>?

    init(screenRecorder: ScreenRecording? = nil) {
        self.screenRecorder = screenRecorder ?? ReplayKitScreenRecorder()
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
            _ = try await screenRecorder.stopRecording()
            isGeneratingReactionVideo = false
            isRecordingCompleted = true
        } catch {
            isGeneratingReactionVideo = false
            recordingErrorMessage = error.localizedDescription
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
}
