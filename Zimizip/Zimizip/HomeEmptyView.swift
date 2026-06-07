import SwiftUI

struct HomeEmptyView: View {
    var onPrepareSurprise: () -> Void = {}

    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let screenHeight = geometry.size.height
            let horizontalPadding: CGFloat = 20
            let contentWidth = min(362, screenWidth - (horizontalPadding * 2))
            let emptyGroupWidth = min(253, screenWidth - 40)
            let emptyGroupCenterY = screenHeight / 2 - 24

            ZStack {
                Color.homeEmptyBackground
                    .ignoresSafeArea()

                VStack(alignment: .leading, spacing: 0) {
                    StrokedHomeEmptyTitleText("soprize")
                        .padding(.top, 82)

                    Spacer(minLength: 0)
                }
                .frame(width: contentWidth, alignment: .leading)
                .frame(maxWidth: .infinity)
                .ignoresSafeArea(edges: .top)

                Button(action: onPrepareSurprise) {
                    VStack(spacing: 20) {
                        Image("HomeEmptyCharacter")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 187, height: 198)

                        VStack(spacing: 8) {
                            Text("오늘을 특별하게 만들\n서프라이즈를 시작해볼까요?")
                                .font(Font.custom("Pretendard-Bold", size: 20))
                                .foregroundStyle(Color.homeEmptyText)
                                .multilineTextAlignment(.center)
                                .lineSpacing(0)

                            HStack(spacing: 4) {
                                Text("서프라이즈 준비하기")
                                    .font(Font.custom("Pretendard-Bold", size: 20))

                                Image(systemName: "chevron.right")
                                    .font(.system(size: 16, weight: .bold))
                            }
                            .foregroundStyle(Color("OrangePrimary"))
                        }
                    }
                    .frame(width: emptyGroupWidth, height: 306)
                }
                .buttonStyle(.plain)
                .position(x: screenWidth / 2 + 0.5, y: emptyGroupCenterY)
            }
        }
    }
}

private struct StrokedHomeEmptyTitleText: View {
    let text: String

    init(_ text: String) {
        self.text = text
    }

    var body: some View {
        ZStack {
            ForEach(strokeOffsets, id: \.self) { offset in
                Text(text)
                    .font(Font.custom("ABeeZee-Regular", size: 28))
                    .foregroundStyle(Color.homeEmptyText)
                    .offset(x: offset.width, y: offset.height)
            }

            Text(text)
                .font(Font.custom("ABeeZee-Regular", size: 28))
                .foregroundStyle(Color.homeEmptyText)
        }
    }

    private var strokeOffsets: [CGSize] {
        [
            CGSize(width: -1, height: 0),
            CGSize(width: 1, height: 0),
            CGSize(width: 0, height: -1),
            CGSize(width: 0, height: 1),
            CGSize(width: -0.7, height: -0.7),
            CGSize(width: 0.7, height: -0.7),
            CGSize(width: -0.7, height: 0.7),
            CGSize(width: 0.7, height: 0.7)
        ]
    }
}

private extension Color {
    static let homeEmptyBackground = Color("BackgroundPrimary")
    static let homeEmptyText = Color(red: 17 / 255, green: 17 / 255, blue: 17 / 255)
}

#Preview {
    HomeEmptyView()
}
