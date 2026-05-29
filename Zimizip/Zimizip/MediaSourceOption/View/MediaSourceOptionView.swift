import PhotosUI
import SwiftUI

struct MediaSourceOptionView: View {
    private let viewModel = MediaSourceOptionViewModel()
    @State private var selectedMedia: PhotosPickerItem?
    @State private var media: Media?

    var body: some View {
        NavigationStack {
            VStack {
                PhotosPicker(
                    selection: $selectedMedia,
                    matching: .images,
                    photoLibrary: .shared()
                ) {
                    Text("갤러리에서 불러오기")
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationDestination(
                item: $media
            ) { media in
                MediaEditView(media: media.source)
            }
        }
        .task(id: selectedMedia) {
            guard let media = await viewModel.importMedia(from: selectedMedia) else {
                return
            }

            self.media = media
            selectedMedia = nil
        }
    }
}

#Preview {
    MediaSourceOptionView()
}
