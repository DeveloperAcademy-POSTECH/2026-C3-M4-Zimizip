import Foundation
import CoreGraphics
import SwiftData

@Model
final class Media {
    var source: Data
    var sourcePreviewFrameX: Double?
    var sourcePreviewFrameY: Double?
    var sourcePreviewFrameWidth: Double?
    var sourcePreviewFrameHeight: Double?
    var isLandscapeCapture: Bool

    init(
        source: Data,
        sourcePreviewFrame: CGRect? = nil,
        isLandscapeCapture: Bool = false
    ) {
        self.source = source
        self.sourcePreviewFrameX = sourcePreviewFrame.map { Double($0.origin.x) }
        self.sourcePreviewFrameY = sourcePreviewFrame.map { Double($0.origin.y) }
        self.sourcePreviewFrameWidth = sourcePreviewFrame.map { Double($0.size.width) }
        self.sourcePreviewFrameHeight = sourcePreviewFrame.map { Double($0.size.height) }
        self.isLandscapeCapture = isLandscapeCapture
    }

    var sourcePreviewFrame: CGRect? {
        guard let sourcePreviewFrameX,
              let sourcePreviewFrameY,
              let sourcePreviewFrameWidth,
              let sourcePreviewFrameHeight else {
            return nil
        }

        return CGRect(
            x: sourcePreviewFrameX,
            y: sourcePreviewFrameY,
            width: sourcePreviewFrameWidth,
            height: sourcePreviewFrameHeight
        )
    }
}
