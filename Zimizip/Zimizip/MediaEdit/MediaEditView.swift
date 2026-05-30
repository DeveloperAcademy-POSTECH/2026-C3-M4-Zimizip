import SwiftUI

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

            Spacer()

            MediaPreview(media: media)

            Spacer()

            EditToolBar()
                .padding(.bottom, 75)
                .padding(.horizontal, 14)
        }
        .background(Color.white)
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
    }
}

#Preview {
    MediaEditView(media: Data())
}
