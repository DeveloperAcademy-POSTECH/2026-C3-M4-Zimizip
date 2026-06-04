import Foundation

protocol ScreenRecording {
    func startRecording() async throws
    func stopRecording() async throws -> URL
}
