import Foundation

struct ArchiveDisplayItem: Identifiable {
    let id = UUID()
    let surpriseProject: SurpriseProject
    let title: String
    let count: String
    let thumbnail: ArchiveThumbnail
}

enum ArchiveThumbnail {
    case reaction(thumbnailData: [Data], overlayText: String?)
    case surpriseCard(coverImageName: String)
}
