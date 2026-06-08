import Foundation
import ReplayKit

final class ReplayKitScreenRecorder: VideoRecording {
    private let recorder = RPScreenRecorder.shared()
    private var isRecording = false

    func startRecording() async throws {
        guard !isRecording else { return }
        guard recorder.isAvailable else { throw ReplayKitScreenRecorderError.recordingUnavailable }

        recorder.isCameraEnabled = false

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

    func stopRecording() async throws -> URL {
        guard isRecording else { throw ReplayKitScreenRecorderError.notRecording }

        let outputURL = makeScreenRecordingSourceURL()

        try? FileManager.default.removeItem(at: outputURL)

        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            recorder.stopRecording(withOutput: outputURL) { [weak self] error in
                self?.isRecording = false

                if let error {
                    continuation.resume(throwing: error)
                    return
                }

                continuation.resume()
            }
        }

        return outputURL
    }

    private func makeScreenRecordingSourceURL() -> URL {
        FileManager.default.temporaryDirectory
            .appendingPathComponent("screen-recording-\(UUID().uuidString)")
            .appendingPathExtension("mp4")
    }
}

enum ReplayKitScreenRecorderError: Error {
    case recordingUnavailable
    case notRecording
}
