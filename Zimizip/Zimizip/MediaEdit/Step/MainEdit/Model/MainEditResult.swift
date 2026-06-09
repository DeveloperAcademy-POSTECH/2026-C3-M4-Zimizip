import UIKit

struct MainEditResult {
    let framingResult: PhotoFramingResult
    let appliedFilterPreset: MainEditFilterPreset
    let appliedAdjustmentValues: [MainEditAdjustmentOption: Int]
    let image: UIImage?
}
