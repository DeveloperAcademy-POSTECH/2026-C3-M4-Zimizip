import Foundation
import SwiftData

@Model
final class ReactionContent {
    var videoURL: URL
    var videoFileName: String?
    var thumbnailData: Data?
    var createdAt: Date = Date()

    init(
        videoURL: URL,
        videoFileName: String? = nil,
        thumbnailData: Data? = nil,
        createdAt: Date = Date()
    ) {
        self.videoURL = videoURL
        self.videoFileName = videoFileName ?? videoURL.lastPathComponent
        self.thumbnailData = thumbnailData
        self.createdAt = createdAt
    }

    var playableVideoURL: URL {
        guard let videoFileName,
              let archivedVideoURL = try? ReactionVideoArchive.videoURL(fileName: videoFileName),
              FileManager.default.fileExists(atPath: archivedVideoURL.path) else {
            return videoURL
        }

        return archivedVideoURL
    }
}
