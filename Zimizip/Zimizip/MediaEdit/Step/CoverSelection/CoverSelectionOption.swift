import Foundation

struct CoverSelectionOption: Identifiable, Hashable {
    let imageName: String

    var id: String {
        imageName
    }
}

extension CoverSelectionOption {
    static let defaultOptions: [CoverSelectionOption] = [
        CoverSelectionOption(imageName: "HomeSurpriseCardCenter"),
        CoverSelectionOption(imageName: "HomeSurpriseCardLeft"),
        CoverSelectionOption(imageName: "HomeSurpriseCardRight"),
        CoverSelectionOption(imageName: "ReactionCardFrame3"),
        CoverSelectionOption(imageName: "ReactionCardFrame1"),
        CoverSelectionOption(imageName: "ReactionCardFrame2"),
        CoverSelectionOption(imageName: "ReactionCardFrame4")
    ]
}
