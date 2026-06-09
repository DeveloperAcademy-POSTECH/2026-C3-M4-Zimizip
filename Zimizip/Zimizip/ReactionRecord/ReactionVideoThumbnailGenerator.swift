import AVFoundation
import UIKit

struct ReactionVideoThumbnailGenerator {
    func thumbnail(from videoURL: URL) async throws -> UIImage {
        try await Task.detached {
            let asset = AVURLAsset(url: videoURL)
            let imageGenerator = AVAssetImageGenerator(asset: asset)
            imageGenerator.appliesPreferredTrackTransform = true
            imageGenerator.requestedTimeToleranceBefore = .zero
            imageGenerator.requestedTimeToleranceAfter = .zero

            let duration = try await asset.load(.duration)
            let thumbnailSeconds = duration.seconds / 2
            let time = CMTime(seconds: thumbnailSeconds, preferredTimescale: 600)
            let cgImage = try imageGenerator.copyCGImage(at: time, actualTime: nil)

            return UIImage(cgImage: cgImage)
        }.value
    }
}
