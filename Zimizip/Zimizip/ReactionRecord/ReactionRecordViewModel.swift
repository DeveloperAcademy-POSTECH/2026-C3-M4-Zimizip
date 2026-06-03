import Foundation
import Combine
import ReplayKit

@MainActor
final class ReactionRecordViewModel: ObservableObject {
    @Published var isBeforeReveal = true
    @Published var recordingPreviewController: RPPreviewViewController?
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
        } catch {
            recordingErrorMessage = error.localizedDescription
        }
    }

    func stopRecording() async {
        guard !isStoppingRecording else { return }
        isStoppingRecording = true
        defer { isStoppingRecording = false }

        do {
            recordingPreviewController = try await screenRecorder.stopRecording()
        } catch {
            recordingErrorMessage = error.localizedDescription
        }
    }

    func hideRevealGuide() {
        isBeforeReveal = false
    }
}
