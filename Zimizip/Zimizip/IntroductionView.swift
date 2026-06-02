
import SwiftUI

struct IntroductionView: View {
    var body: some View {
        ZStack {
            Color.backgroundPrimary
                .ignoresSafeArea()

            VStack {
                Spacer()
                    .frame(height: 430)

                Text("상대를 깜짝 놀라게 할 사진을\n예쁘게 포장하고 슬쩍 건네보세요")
                    .font(Font.custom("Pretendard-SemiBold", size: 20))
                    .multilineTextAlignment(.center)

                HStack(spacing: 5) {
                    Circle()
                        .fill(Color(red: 1, green: 0.42, blue: 0.13))
                        .frame(width: 8, height: 8)

                    Circle()
                        .fill(.gray.opacity(0.3))
                        .frame(width: 8, height: 8)
                }
                .padding(.top, 53)

                Spacer()
                
                ZimizipPrimaryButton(title: "다음") {}
                .padding(.bottom, 60)
            }
        }
    }
}

#Preview {
    IntroductionView()
}
