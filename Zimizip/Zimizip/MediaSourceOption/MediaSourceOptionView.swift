import PhotosUI
import SwiftUI

struct MediaSourceOptionView: View {
    @State private var selectedMedia: PhotosPickerItem?
    @State private var media: Media?

    var body: some View {
        NavigationStack {
            PhotosPicker(
                selection: $selectedMedia,
                matching: .images,
                photoLibrary: .shared()
            ) {
                Text("갤러리에서 불러오기")
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationDestination(
                item: $media
            ) { media in
                MediaEditView(media: media.source)
                    .navigationBarBackButtonHidden(true)
                    .toolbar(.hidden, for: .navigationBar)
            }
        }
        .task(id: selectedMedia) {
            guard let selectedMediaSource = try? await selectedMedia?.loadTransferable(type: Data.self) else {
                return
            }

            media = Media(source: selectedMediaSource)
            selectedMedia = nil
        }
    }
}

#Preview {
    MediaSourceOptionView()
}
