import SwiftUI

struct IntroductionPage {
    let text: String
    let buttonTitle: String
}

struct IntroductionView: View {
    let onStartButtonTap: () -> Void

    @State private var currentPage = 0

    private let pages = [
        IntroductionPage(
            text: "상대를 깜짝 놀라게 할 사진을\n예쁘게 포장하고 슬쩍 건네보세요",
            buttonTitle: "다음"
        ),
        IntroductionPage(
            text: "상대가 카드를 지워낼 때 화면과\n생생한 반응이 영상으로 기록돼요",
            buttonTitle: "서프라이즈 준비하기"
        )
    ]

    init(onStartButtonTap: @escaping () -> Void = {}) {
        self.onStartButtonTap = onStartButtonTap
    }

    var body: some View {
        ZStack {
            Color("BackgroundPrimary")
                .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()
                    .frame(height: 205)

                Image("IntroductionCoverCharacter")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 244, height: 301)

                Text("서프라이즈할 사진을 꾸미고\n커버로 덮어 숨겨보세요")
                    .font(Font.custom("Pretendard-Bold", size: 20))
                    .foregroundStyle(Color(red: 17 / 255, green: 17 / 255, blue: 17 / 255))
                    .multilineTextAlignment(.center)
                    .lineSpacing(2)
                    .padding(.top, -16)

                HStack(spacing: 4) {
                    Capsule()
                        .fill(Color(red: 1, green: 0.42, blue: 0.13))
                        .frame(width: 16, height: 8)

                    Circle()
                        .fill(Color(red: 0.85, green: 0.85, blue: 0.85))
                        .frame(width: 8, height: 8)
                }
                .padding(.top, 40)

                Spacer()

                Button {
                } label: {
                    Text("다음")
                        .font(Font.custom("Pretendard-Bold", size: 16))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color(red: 1, green: 0.42, blue: 0.13))
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 20)
                .padding(.bottom, 71)
            }
        }
    }
}

#Preview {
    IntroductionView()
}
