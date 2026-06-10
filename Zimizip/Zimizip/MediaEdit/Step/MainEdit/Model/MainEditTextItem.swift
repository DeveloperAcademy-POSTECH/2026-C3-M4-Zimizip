import CoreGraphics
import Foundation

struct MainEditTextItem: Codable, Identifiable, Equatable {
    let id: UUID
    var text: String
    var styleRuns: [MainEditTextStyleRun]
    var normalizedCenter: CGPoint
    var scale: CGFloat
    var zIndex: Int

    init(
        id: UUID = UUID(),
        text: String = MainEditLayout.textPreviewPlaceholder,
        styleRuns: [MainEditTextStyleRun]? = nil,
        normalizedCenter: CGPoint = CGPoint(x: 0.5, y: 0.5),
        scale: CGFloat = 1,
        zIndex: Int
    ) {
        self.id = id
        self.text = text
        self.styleRuns = styleRuns ?? [
            MainEditTextStyleRun(
                start: 0,
                length: text.count,
                font: .default,
                color: .white
            )
        ]
        self.normalizedCenter = normalizedCenter
        self.scale = scale
        self.zIndex = zIndex
    }
}

struct MainEditTextStyleRun: Codable, Equatable {
    var start: Int
    var length: Int
    var font: MainEditTextFont
    var color: MainEditTextColor
}
