import Foundation

struct MainEditEditState: Equatable {
    var filterPreset: MainEditFilterPreset = .original
    var adjustmentValues: [MainEditAdjustmentOption: Int] = [:]
    var texts: [MainEditTextItem] = []
    var stickers: [MainEditStickerItem] = []
}
