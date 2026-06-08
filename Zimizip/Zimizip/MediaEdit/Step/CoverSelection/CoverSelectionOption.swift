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
        CoverSelectionOption(imageName: "HomeSurpriseCardRight")
    ]
}
