import SwiftData

@Model
final class Content {
    @Relationship(deleteRule: .cascade)
    var media: Media
    var box: String

    init(media: Media, box: String) {
        self.media = media
        self.box = box
    }
}
