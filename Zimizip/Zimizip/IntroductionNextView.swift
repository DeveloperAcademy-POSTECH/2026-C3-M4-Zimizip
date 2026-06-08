import SwiftUI

struct IntroductionNextView: View {
    var body: some View {
        ZStack {
            Color("BackgroundPrimary")
                .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()
                    .frame(height: 180)

                AnimatedImage(name: "intro2")
                    .frame(width: 190, height: 285)
                    .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 5, style: .continuous)
                            .stroke(Color("BackgroundPrimary"), lineWidth: 1)
                    )

                Text("폰을 건넨 뒤, 사진이 드러나는\n순간의 리액션을 담아보세요")
                    .font(Font.custom("Pretendard-Bold", size: 20))
                    .foregroundStyle(Color(red: 17 / 255, green: 17 / 255, blue: 17 / 255))
                    .multilineTextAlignment(.center)
                    .lineSpacing(2)
                    .padding(.top, 24)

                HStack(spacing: 4) {
                    Circle()
                        .fill(Color(red: 0.85, green: 0.85, blue: 0.85))
                        .frame(width: 8, height: 8)

                    Capsule()
                        .fill(Color(red: 1, green: 0.42, blue: 0.13))
                        .frame(width: 16, height: 8)
                }
                .padding(.top, 40)

                Spacer()

                Button {
                } label: {
                    Text("서프라이즈 준비하기")
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
    IntroductionNextView()
}
