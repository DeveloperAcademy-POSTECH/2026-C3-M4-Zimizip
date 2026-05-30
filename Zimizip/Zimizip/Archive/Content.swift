import SwiftData

@Model
final class Content {
    var media: Media
    var box: String

    init(media: Media, box: String) {
        self.media = media
        self.box = box
    }
}
