import Foundation

struct ArchivedReactionVideo {
    let fileName: String
    let url: URL
}

enum ReactionVideoArchive {
    static func copyVideoToArchive(from sourceURL: URL) throws -> ArchivedReactionVideo {
        let archiveDirectory = try archiveDirectoryURL()

        try FileManager.default.createDirectory(
            at: archiveDirectory,
            withIntermediateDirectories: true
        )

        let fileExtension = sourceURL.pathExtension.isEmpty ? "mp4" : sourceURL.pathExtension
        let fileName = "\(UUID().uuidString).\(fileExtension)"
        let destinationURL = archiveDirectory.appendingPathComponent(fileName)

        try FileManager.default.copyItem(at: sourceURL, to: destinationURL)
        return ArchivedReactionVideo(fileName: fileName, url: destinationURL)
    }

    static func videoURL(fileName: String) throws -> URL {
        try archiveDirectoryURL().appendingPathComponent(fileName)
    }

    private static func archiveDirectoryURL() throws -> URL {
        try FileManager.default
            .url(
                for: .applicationSupportDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: true
            )
            .appendingPathComponent("ReactionVideos", isDirectory: true)
    }
}
