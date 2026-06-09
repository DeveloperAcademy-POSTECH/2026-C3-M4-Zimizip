import Foundation

struct CoverSelectionOption: Identifiable, Hashable {
    let imageName: String

    var id: String {
        imageName
    }
}

extension CoverSelectionOption {
    static let defaultOptions: [CoverSelectionOption] = [
        CoverSelectionOption(imageName: "ArchivedSurpriseCard1"),
        CoverSelectionOption(imageName: "ArchivedSurpriseCard2"),
        CoverSelectionOption(imageName: "ArchivedSurpriseCard3"),
        CoverSelectionOption(imageName: "ArchivedSurpriseCard4"),
        CoverSelectionOption(imageName: "ArchivedSurpriseCard5"),
        CoverSelectionOption(imageName: "ArchivedSurpriseCard6"),
        CoverSelectionOption(imageName: "ArchivedSurpriseCard7"),
        CoverSelectionOption(imageName: "ArchivedSurpriseCard8"),
        CoverSelectionOption(imageName: "ArchivedSurpriseCard9"),
        CoverSelectionOption(imageName: "ArchivedSurpriseCard10"),
        CoverSelectionOption(imageName: "ArchivedSurpriseCard11"),
        CoverSelectionOption(imageName: "ArchivedSurpriseCard12"),
        CoverSelectionOption(imageName: "ArchivedSurpriseCard13"),
        CoverSelectionOption(imageName: "ArchivedSurpriseCard14")
    ]
}
