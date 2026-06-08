import CoreGraphics
import Foundation

struct MediaEditInput: Hashable, Identifiable {
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

    static func == (lhs: MediaEditInput, rhs: MediaEditInput) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
