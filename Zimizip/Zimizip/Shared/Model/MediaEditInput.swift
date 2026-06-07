import CoreGraphics
import Foundation

struct MediaEditInput: Identifiable {
    let id = UUID()
    let source: Data
    let sourcePreviewFrame: CGRect?
    let isLandscapeCapture: Bool

    init(
        source: Data,
        sourcePreviewFrame: CGRect? = nil,
        isLandscapeCapture: Bool = false
    ) {
        self.source = source
        self.sourcePreviewFrame = sourcePreviewFrame
        self.isLandscapeCapture = isLandscapeCapture
    }
}
