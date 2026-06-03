import Foundation
import ReplayKit

protocol ScreenRecording {
    func startRecording() async throws
    func stopRecording() async throws -> RPPreviewViewController?
}
