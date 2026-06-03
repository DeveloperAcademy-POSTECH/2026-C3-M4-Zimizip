import ReplayKit

final class ReplayKitScreenRecorder: ScreenRecording {
    private let recorder = RPScreenRecorder.shared()
    private var isRecording = false

    func startRecording() async throws {
        guard !isRecording else { return }
        guard recorder.isAvailable else { throw ReplayKitScreenRecorderError.recordingUnavailable }

        recorder.isCameraEnabled = true

        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            recorder.startRecording { [weak self] error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }

                self?.isRecording = true
                continuation.resume()
            }
        }
    }

    func stopRecording() async throws -> RPPreviewViewController? {
        guard isRecording else { return nil }

        return try await withCheckedThrowingContinuation { continuation in
            recorder.stopRecording { [weak self] previewViewController, error in
                self?.isRecording = false

                if let error {
                    continuation.resume(throwing: error)
                    return
                }

                continuation.resume(returning: previewViewController)
            }
        }
    }
}

enum ReplayKitScreenRecorderError: Error {
    case recordingUnavailable
}
