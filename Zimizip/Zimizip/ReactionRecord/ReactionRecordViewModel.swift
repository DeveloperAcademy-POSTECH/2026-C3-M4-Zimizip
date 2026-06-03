import Foundation
import Combine

@MainActor
final class ReactionRecordViewModel: ObservableObject {
    @Published var isBeforeReveal = true
    @Published var isRecordingCompleted = false
    @Published var isGeneratingReactionVideo = false
    @Published var recordingErrorMessage: String?
    @Published var isStoppingRecording = false

    private let screenRecorder: ScreenRecording
    private var hasStartedRecording = false

    init(screenRecorder: ScreenRecording? = nil) {
        self.screenRecorder = screenRecorder ?? ReplayKitScreenRecorder()
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

        do {
            let previewViewController = try await screenRecorder.stopRecording()
            isGeneratingReactionVideo = false
            isRecordingCompleted = true
        } catch {
            isGeneratingReactionVideo = false
            recordingErrorMessage = error.localizedDescription
        }
    }

    func hideRevealGuide() {
        isBeforeReveal = false
    }

    func clearRecordingError() {
        recordingErrorMessage = nil
    }
}
