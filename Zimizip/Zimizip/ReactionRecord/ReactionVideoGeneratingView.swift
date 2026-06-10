import SwiftUI

struct ReactionVideoGeneratingView: View {
    var body: some View {
        VStack(spacing: 20) {
            AnimatedImage(name: "GeneratingCharactor")
                .frame(width: 200, height: 200)

            VStack(spacing: 8) {
                Text("서프라이즈 영상을 만들고 있어요")
                    .font(Font.custom("Pretendard-Medium", size: 20))
                    .multilineTextAlignment(.center)

                Text("그 순간을 영상으로 담아내고 있어요\n잠시만 기다려주세요")
                    .font(Font.custom("Pretendard-Regular", size: 18))
                    .foregroundStyle(Color.gray400)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        .padding(.bottom, 250)
    }
}

#Preview {
    ZStack {
        Color.backgroundPrimary
            .ignoresSafeArea()

        ReactionVideoGeneratingView()
    }
}
