import Foundation

struct MainEditEditState: Equatable {
    var filterPreset: MainEditFilterPreset = .original
    var adjustmentValues: [MainEditAdjustmentOption: Int] = [:]
    var stickers: [MainEditStickerItem] = []
}
