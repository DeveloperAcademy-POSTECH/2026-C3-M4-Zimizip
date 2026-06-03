import SwiftUI

struct ReactionVideoGeneratingView: View {
    var body: some View {
        VStack {
            Image("Image")
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 200)

            Text("리액션 영상 생성 중")
                .font(Font.custom("Pretendard-Medium", size: 20))
                .padding(.top, 20)

            Text("잠시만 기다려주세요")
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
