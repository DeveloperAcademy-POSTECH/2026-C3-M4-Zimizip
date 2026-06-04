import Foundation
import SwiftData

@Model
final class ReactionContent {
    var videoURL: URL

    init(videoURL: URL) {
        self.videoURL = videoURL
    }
}
