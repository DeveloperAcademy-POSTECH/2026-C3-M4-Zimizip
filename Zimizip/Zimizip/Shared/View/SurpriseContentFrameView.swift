import SwiftUI

struct SurpriseContentFrameView<ImageContent: View>: View {
    @ViewBuilder let imageContent: () -> ImageContent

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24)
                .fill(.white)

            RoundedRectangle(cornerRadius: 24)
                .stroke(Color(red: 236/255, green: 228/255, blue: 209/255), lineWidth: 4)

            imageContent()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .clipShape(RoundedRectangle(cornerRadius: 24))
                .padding(8)
        }
        .aspectRatio(2.0 / 3.0, contentMode: .fit)
        .padding(20)
    }
}

#Preview {
    SurpriseContentFrameView {
        Image("Image")
            .resizable()
            .scaledToFit()
    }
}
