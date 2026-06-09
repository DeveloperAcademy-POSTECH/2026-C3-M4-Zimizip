import CoreGraphics
import Foundation

struct MainEditStickerItem: Identifiable, Equatable {
    let id: UUID
    let source: MainEditStickerSource
    var normalizedCenter: CGPoint
    var scale: CGFloat
    var zIndex: Int

    init(
        id: UUID = UUID(),
        source: MainEditStickerSource,
        normalizedCenter: CGPoint = CGPoint(x: 0.5, y: 0.5),
        scale: CGFloat = 1,
        zIndex: Int
    ) {
        self.id = id
        self.source = source
        self.normalizedCenter = normalizedCenter
        self.scale = scale
        self.zIndex = zIndex
    }
}
