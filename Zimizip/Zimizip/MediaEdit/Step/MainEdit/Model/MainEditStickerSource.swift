import Foundation

enum MainEditStickerSource: String, CaseIterable, Hashable, Identifiable {
    case greenFirecracker
    case pinkFirecracker
    case heartFill
    case heartEmpty
    case stars
    case congrat
    case yellowStars
    case pop

    var id: Self { self }

    var imageName: String {
        rawValue
    }
}
