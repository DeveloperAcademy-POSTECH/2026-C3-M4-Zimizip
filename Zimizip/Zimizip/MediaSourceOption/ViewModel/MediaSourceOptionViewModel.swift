import Foundation
import PhotosUI

@MainActor
final class MediaSourceOptionViewModel {
    func importMedia(from selectedMedia: PhotosPickerItem?) async -> Media? {
        guard let selectedMediaSource = try? await selectedMedia?.loadTransferable(type: Data.self) else {
            return nil
        }

        return Media(source: selectedMediaSource)
    }
}
