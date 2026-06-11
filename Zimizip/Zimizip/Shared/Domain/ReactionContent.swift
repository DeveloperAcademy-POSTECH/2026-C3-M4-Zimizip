import Foundation
import SwiftData

@Model
final class ReactionContent {
    var videoURL: URL
    var thumbnailData: Data?

    init(videoURL: URL, thumbnailData: Data? = nil) {
        self.videoURL = videoURL
        self.thumbnailData = thumbnailData
    }
}
