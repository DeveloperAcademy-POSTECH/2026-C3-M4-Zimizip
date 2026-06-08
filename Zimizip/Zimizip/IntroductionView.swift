
import SwiftUI

struct IntroductionPage {
    let text: String
    let buttonTitle: String
}

struct IntroductionView: View {
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

    var body: some View {
        ZStack {
            Color.backgroundPrimary
                .ignoresSafeArea()

            VStack {
                Spacer()
                    .frame(height: 460)

                Text(pages[currentPage].text)
                    .font(Font.custom("Pretendard-Bold", size: 20))
                    .multilineTextAlignment(.center)

                HStack(spacing: 5) {
                    ForEach(pages.indices, id: \.self) { index in
                        Circle()
                            .fill(index == currentPage ? Color("OrangePrimary") : .gray.opacity(0.3))
                            .frame(width: 8, height: 8)
                    }
                }
                .padding(.top, 48)

                Spacer()
                
                Button(pages[currentPage].buttonTitle) {
                    if currentPage < pages.count - 1 {
                        var transaction = Transaction()
                        transaction.disablesAnimations = true

                        withTransaction(transaction) {
                            currentPage += 1
                        }
                    }
                }
                .font(Font.custom("Pretendard-Bold", size: 16))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(Color("OrangePrimary"))
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .padding(.horizontal, 20)
                .padding(.bottom, 60)
                .buttonStyle(.plain)
            }
        }
    }
}

#Preview {
    IntroductionView()
}
