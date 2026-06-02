import PhotosUI
import SwiftUI

struct MediaSourceOptionView: View {
    @State private var selectedMedia: PhotosPickerItem?
    @State private var media: Media?

    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 255 / 255, green: 252 / 255, blue: 250 / 255)
                    .ignoresSafeArea()

                VStack(alignment: .leading) {
                    Button {

                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 24, weight: .medium))
                            .foregroundStyle(Color(red: 36 / 255, green: 33 / 255, blue: 31 / 255))
                            .frame(width: 38, height: 38)
                            .background(.white.opacity(0.75))
                            .clipShape(Circle())
                    }
                    .padding(.vertical, 13)

                    VStack(alignment: .leading, spacing: 16) {
                        Text("어떤 방식으로\n시작해볼까요?")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundStyle(Color(red: 36 / 255, green: 33 / 255, blue: 31 / 255))

                        Text("서프라이즈 사진을 준비하는\n방법을 선택해주세요")
                            .font(.system(size: 18))
                            .foregroundStyle(Color(red: 129 / 255, green: 121 / 255, blue: 115 / 255))
                            .lineSpacing(4)
                    }
                    .padding(.bottom, 60)

                    OptionItemView(
                        icon: "Camera",
                        title: "직접 촬영하기",
                        subtitle: "서프라이즈를 할 순간을\n바로 담아보세요",
                        isSelected: false
                    )

                    Spacer()
                        .frame(height: 20)

                    PhotosPicker(
                        selection: $selectedMedia,
                        matching: .images,
                        photoLibrary: .shared()
                    ) {
                        OptionItemView(
                            icon: "Image",
                            title: "갤러리에서 불러오기",
                            subtitle: "이미 저장된 사진으로\n시작해보세요",
                            isSelected: false
                        )
                    }
                    .buttonStyle(.plain)

                    Spacer()
                }
                .padding(.horizontal, 20)
            }
            .navigationDestination(item: $media) { media in
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
