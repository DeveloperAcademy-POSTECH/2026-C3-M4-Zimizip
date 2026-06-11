import SwiftUI

struct IntroductionView: View {
    let onStartButtonTap: () -> Void

    @State private var currentPage: IntroductionPage = .first

    init(onStartButtonTap: @escaping () -> Void = {}) {
        self.onStartButtonTap = onStartButtonTap
    }

    var body: some View {
        ZStack {
            Color.backgroundPrimary
                .ignoresSafeArea()

            VStack {
                Spacer()

                currentPage.animationView

                Text(currentPage.description)
                    .font(Font.custom("Pretendard-Bold", size: 20))
                    .foregroundStyle(Color.textPrimary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(2)

                currentPage.indicatorView
                    .padding(.top, 40)

                Spacer()

                Button(action: handleButtonTap) {
                    Text(currentPage.buttonTitle)
                        .font(Font.custom("Pretendard-Bold", size: 16))
                        .foregroundStyle(Color.baseWhite)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color.orangePrimary)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 20)
                .padding(.bottom, 71)
            }
        }
    }

    private func handleButtonTap() {
        switch currentPage {
        case .first:
            currentPage = .next
        case .next:
            onStartButtonTap()
        }
    }
}

private enum IntroductionPage {
    case first
    case next

    var topSpacing: CGFloat {
        switch self {
        case .first:
            return 205
        case .next:
            return 180
        }
    }

    var description: String {
        switch self {
        case .first:
            return "서프라이즈할 사진을 꾸미고\n커버로 덮어 숨겨보세요"
        case .next:
            return "폰을 건넨 뒤, 사진이 드러나는\n순간의 리액션을 담아보세요"
        }
    }

    var buttonTitle: String {
        switch self {
        case .first:
            return "다음"
        case .next:
            return "서프라이즈 준비하기"
        }
    }

    @ViewBuilder
    var animationView: some View {
        switch self {
        case .first:
            AnimatedImage(name: "pingpong_delay1.5s")
                .frame(width: 250, height: 300)
                .clipped()
        case .next:
            AnimatedImage(name: "intro2")
                .frame(width: 250, height: 300)
                .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 5, style: .continuous)
                        .stroke(Color.backgroundPrimary, lineWidth: 1)
                )
        }
    }

    @ViewBuilder
    var indicatorView: some View {
        HStack(spacing: 4) {
            switch self {
            case .first:
                Capsule()
                    .fill(Color.orangePrimary)
                    .frame(width: 16, height: 8)

                Circle()
                    .fill(Color.gray150)
                    .frame(width: 8, height: 8)
            case .next:
                Circle()
                    .fill(Color.gray150)
                    .frame(width: 8, height: 8)

                Capsule()
                    .fill(Color.orangePrimary)
                    .frame(width: 16, height: 8)
            }
        }
    }
}

#Preview {
    IntroductionView()
}
