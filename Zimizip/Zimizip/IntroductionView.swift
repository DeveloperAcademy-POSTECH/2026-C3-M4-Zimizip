import SwiftUI

struct IntroductionPage {
    let text: String
    let buttonTitle: String
}

struct IntroductionView: View {
    var body: some View {
        ZStack {
            Color("BackgroundPrimary")
                .ignoresSafeArea()

            if showsNextView {
                IntroductionNextView()
            } else {
                VStack(spacing: 0) {
                    Spacer()
                        .frame(height: 205)

                    AnimatedImage(name: "pingpong_delay1.5s")
                        .frame(width: 244, height: 301)
                        .clipped()

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
                        showsNextView = true
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
}

#Preview {
    IntroductionView()
}
