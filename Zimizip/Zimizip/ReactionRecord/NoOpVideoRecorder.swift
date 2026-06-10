import Foundation

final class NoOpVideoRecorder: VideoRecording {
    func startRecording() async throws {}

    func stopRecording() async throws -> URL {
        throw NoOpVideoRecorderError.noRecordingOutput
    }
}

enum NoOpVideoRecorderError: LocalizedError {
    case noRecordingOutput

    var errorDescription: String? {
        switch self {
        case .noRecordingOutput:
            return "녹화 결과가 없습니다."
        }
    }
}
