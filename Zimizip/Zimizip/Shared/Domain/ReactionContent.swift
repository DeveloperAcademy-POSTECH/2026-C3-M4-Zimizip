import Foundation
import SwiftData

@Model
final class ReactionContent {
    var videoURL: URL
    var thumbnailData: Data?
    var createdAt: Date = Date()

    init(
        videoURL: URL,
        thumbnailData: Data? = nil,
        createdAt: Date = Date()
    ) {
        self.videoURL = videoURL
        self.thumbnailData = thumbnailData
        self.createdAt = createdAt
    }
}
