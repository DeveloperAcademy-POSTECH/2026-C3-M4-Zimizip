import Foundation

final class MediaSourceOptionViewModel {
    func importMedia(from source: Data) -> Media {
        Media(source: source)
    }
}
