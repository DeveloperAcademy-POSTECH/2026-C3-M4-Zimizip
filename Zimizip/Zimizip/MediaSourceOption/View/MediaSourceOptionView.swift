import PhotosUI
import SwiftUI

struct MediaSourceOptionView: View {
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
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.accentColor)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 24)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationDestination(
                item: $media
            ) { media in
                MediaEditView(media: media.source)
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
