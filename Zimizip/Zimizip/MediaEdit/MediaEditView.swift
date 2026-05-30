import SwiftUI
import UIKit

struct MediaEditView: View {
    @Environment(\.dismiss) private var dismiss

    let media: Data

    var body: some View {
        VStack {
            TopBar(
                title: "사진 편집",
                nextButtonTitle: "다음",
                backButtonAction: {
                    dismiss()
                },
                nextButtonAction: {}
            )

            Spacer(minLength: 0)

            mediaPreview

            Spacer(minLength: 0)

            EditToolBar()
                .padding(.bottom, 75)
                .padding(.horizontal, 14)
        }
        .background(Color.white)
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
    }

    private var mediaPreview: some View {
        Group {
            if let image = UIImage(data: media) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 374, maxHeight: 504)
            } else {
                Text("사진을 불러올 수 없어요")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: 374, minHeight: 374)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    MediaEditView(media: Data())
}
