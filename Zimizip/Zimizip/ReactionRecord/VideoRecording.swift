import Foundation

protocol VideoRecording {
    func startRecording() async throws
    func stopRecording() async throws -> URL
}
