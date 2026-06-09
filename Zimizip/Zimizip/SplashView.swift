import SwiftUI

struct SplashView: View {
    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let screenHeight = geometry.size.height
            let scale = min(screenWidth / 402, screenHeight / 874)
            let centerX = screenWidth / 2
            let centerY = screenHeight / 2

            ZStack {
                Color.white
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    StrokedText(
                        text: "soprize",
                        fontName: "ABeeZee-Regular",
                        size: 56 * scale,
                        colorName: "OrangePrimary",
                        strokeWidth: 3
                    )
                    .frame(width: 208 * scale, height: 72 * scale, alignment: .leading)

                    Text("지우는 순간 시작되는 서프라이즈")
                        .font(Font.custom("Pretendard-Bold", size: 20 * scale))
                        .foregroundStyle(Color("OrangePrimary"))
                        .padding(.top, 13 * scale)
                }
                .position(x: centerX, y: centerY - 261 * scale)

                AnimatedImage(name: "SplashAnimation", speed: 1.2)
                    .frame(width: 245 * 1.2 * scale, height: 316 * 1.2 * scale)
                    .clipped()
                    .foregroundStyle(Color("BackgroundPrimary"))
                    .position(x: centerX, y: centerY + 31 * scale)
            }
        }
    }
}

#Preview {
    SplashView()
}
