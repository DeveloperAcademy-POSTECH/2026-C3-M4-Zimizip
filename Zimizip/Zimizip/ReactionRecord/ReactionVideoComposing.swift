import Foundation

protocol ReactionVideoComposing {
    func compose(
        frontCameraVideoURL: URL,
        screenRecordingURL: URL
    ) async throws -> URL
}
