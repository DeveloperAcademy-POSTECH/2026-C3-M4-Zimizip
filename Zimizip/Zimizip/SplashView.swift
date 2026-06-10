import SwiftUI

struct SplashView: View {
    let onAnimationCompleted: () -> Void

    @State private var hasCompletedAnimation = false

    private let animationName = "SplashAnimation"
    private let animationSpeed = 1.2

    init(onAnimationCompleted: @escaping () -> Void = {}) {
        self.onAnimationCompleted = onAnimationCompleted
    }

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

                VStack(alignment: .center) {
                    StrokedText(
                        text: "soprize",
                        fontName: "ABeeZee-Regular",
                        size: 56 * scale,
                        colorName: "OrangePrimary",
                        strokeWidth: 3
                    )
                    .frame(width: 208 * scale, height: 72 * scale, alignment: .center)

                    Text("지우는 순간 시작되는 서프라이즈")
                        .font(Font.custom("Pretendard-Bold", size: 20 * scale))
                        .foregroundStyle(Color("OrangePrimary"))
                        .padding(.top, 13 * scale)
                }
                .position(x: centerX, y: centerY - 261 * scale)

                AnimatedImage(name: animationName, speed: animationSpeed)
                    .frame(width: 245 * 1.2 * scale, height: 316 * 1.2 * scale)
                    .clipped()
                    .foregroundStyle(Color("BackgroundPrimary"))
                    .position(x: centerX, y: centerY + 31 * scale)
            }
        }
        .task {
            await completeAnimationAfterDelay()
        }
    }

    private func completeAnimationAfterDelay() async {
        guard !hasCompletedAnimation else {
            return
        }

        let animationDuration = AnimatedImage.animationDuration(
            name: animationName,
            speed: animationSpeed
        ) ?? 2.5

        try? await Task.sleep(for: .seconds(animationDuration))

        guard !Task.isCancelled, !hasCompletedAnimation else {
            return
        }

        hasCompletedAnimation = true
        onAnimationCompleted()
    }
}

#Preview {
    SplashView()
}
