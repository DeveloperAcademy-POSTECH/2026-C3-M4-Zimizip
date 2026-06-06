import SwiftUI

struct ReactionVideoGeneratingView: View {
    var body: some View {
        VStack {
            Image("GeneratingCharactor")
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 200)

            Text("서프라이즈 영상을 만들고 있어요")
                .font(Font.custom("Pretendard-Medium", size: 20))
                .padding(.top, 20)

            Text("문지르는 순간과 리액션이 함께 담겨요")
                .font(Font.custom("Pretendard-Regular", size: 18))
                .foregroundStyle(Color.gray400)
                .padding(.top, 8)
        }
    }
}

#Preview {
    ZStack {
        Color.backgroundPrimary
            .ignoresSafeArea()

        ReactionVideoGeneratingView()
    }
}
