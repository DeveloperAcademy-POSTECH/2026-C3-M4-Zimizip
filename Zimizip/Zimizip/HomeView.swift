import SwiftUI

struct HomeView: View {
    @State private var selectedCardIndex = 1

    private let surpriseCards = [
        HomeSurpriseCard(imageName: "HomeSurpriseCardLeft", imageMode: .leftCrop, title: "토바에의 깜짝 소식"),
        HomeSurpriseCard(imageName: "HomeSurpriseCardCenter", imageMode: .fill, title: "지미집 생일파티"),
        HomeSurpriseCard(imageName: "HomeSurpriseCardRight", imageMode: .rightCrop, title: "해피버스데이투유")
    ]

    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let screenHeight = geometry.size.height
            let horizontalPadding: CGFloat = 20
            let contentWidth = min(362, screenWidth - (horizontalPadding * 2))
            let contentLeading = max(horizontalPadding, (screenWidth - contentWidth) / 2)
            let cardScale = min(screenWidth / 402, 1)
            let carouselWidth = 402 * cardScale
            let carouselHeight = 430 * cardScale
            let carouselCenterY = min(screenHeight * 0.5 + 32, 469)
            let titleY = carouselCenterY + (180 * cardScale) + 39

            ZStack(alignment: .bottomLeading) {
                Color.homeBackground
                    .ignoresSafeArea()

                VStack(alignment: .leading, spacing: 0) {
                    StrokedTitleText("soprize")
                        .padding(.top, 82)

                    Text("대기 중인\n서프라이즈 카드")
                        .font(Font.custom("Pretendard-Bold", size: 28))
                        .foregroundStyle(Color.homeText)
                        .lineSpacing(2)
                        .padding(.top, 42)

                    Spacer(minLength: 0)
                }
                .frame(width: contentWidth, alignment: .leading)
                .frame(maxWidth: .infinity)
                .ignoresSafeArea(edges: .top)

                SurpriseCardCarousel(
                    cards: surpriseCards,
                    selectedIndex: $selectedCardIndex,
                    scale: cardScale
                )
                    .frame(width: carouselWidth, height: carouselHeight)
                    .position(x: screenWidth / 2, y: carouselCenterY)

                Text(surpriseCards[selectedCardIndex].title)
                    .font(Font.custom("Pretendard-Bold", size: 16))
                    .foregroundStyle(Color.homeSecondaryText)
                    .frame(width: 240)
                    .position(x: screenWidth / 2, y: titleY)

                BottomTabBar()
                    .padding(.leading, contentLeading)
                    .padding(.bottom, 1)

                Button {
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 30, weight: .regular))
                        .foregroundStyle(Color.homeWhite)
                        .frame(width: 58, height: 58)
                        .background(Color("OrangePrimary"))
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.12), radius: 20, x: 0, y: 8)
                }
                .buttonStyle(.plain)
                .position(x: screenWidth - contentLeading - 40, y: screenHeight - 28)
            }
        }
    }
}

private struct HomeSurpriseCard: Identifiable {
    let id = UUID()
    let imageName: String
    let imageMode: SurpriseCard.ImageMode
    let title: String
}

private struct StrokedTitleText: View {
    let text: String

    init(_ text: String) {
        self.text = text
    }

    var body: some View {
        ZStack {
            ForEach(strokeOffsets, id: \.self) { offset in
                Text(text)
                    .font(Font.custom("ABeeZee-Regular", size: 28))
                    .foregroundStyle(Color.homeText)
                    .offset(x: offset.width, y: offset.height)
            }

            Text(text)
                .font(Font.custom("ABeeZee-Regular", size: 28))
                .foregroundStyle(Color.homeText)
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

private struct SurpriseCardCarousel: View {
    let cards: [HomeSurpriseCard]
    @Binding var selectedIndex: Int
    let scale: CGFloat

    var body: some View {
        let sideOffset = 220 * scale
        let dragThreshold = 50 * scale

        ZStack {
            ForEach(Array(cards.enumerated()), id: \.element.id) { index, card in
                let distance = index - selectedIndex
                let isCenter = distance == 0

                SurpriseCard(
                    imageName: card.imageName,
                    size: isCenter ? .large : .small,
                    imageMode: card.imageMode
                )
                .frame(
                    width: (isCenter ? 240 : 160) * scale,
                    height: (isCenter ? 360 : 240) * scale
                )
                .scaleEffect(isCenter ? 1 : 0.96)
                .opacity(abs(distance) > 1 ? 0 : 1)
                .position(
                    x: (201 * scale) + (CGFloat(distance) * sideOffset),
                    y: 215 * scale
                )
                .zIndex(isCenter ? 2 : 1)
                .animation(.easeInOut(duration: 0.32), value: selectedIndex)
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.32)) {
                        selectedIndex = index
                    }
                }
            }
        }
        .contentShape(Rectangle())
        .gesture(
            DragGesture()
                .onEnded { value in
                    if value.translation.width < -dragThreshold {
                        withAnimation(.easeInOut(duration: 0.32)) {
                            selectedIndex = min(selectedIndex + 1, cards.count - 1)
                        }
                    } else if value.translation.width > dragThreshold {
                        withAnimation(.easeInOut(duration: 0.32)) {
                            selectedIndex = max(selectedIndex - 1, 0)
                        }
                    }
                }
        )
    }
}

private struct SurpriseCard: View {
    enum Size {
        case large
        case small

        var imageSize: CGSize {
            switch self {
            case .large:
                return CGSize(width: 232, height: 348)
            case .small:
                return CGSize(width: 152, height: 228)
            }
        }

        var frameSize: CGSize {
            let imageSize = imageSize
            return CGSize(width: imageSize.width + 8, height: imageSize.height + 12)
        }
    }

    enum ImageMode {
        case fill
        case leftCrop
        case rightCrop
    }

    let imageName: String
    let size: Size
    let imageMode: ImageMode

    var body: some View {
        GeometryReader { geometry in
            let baseFrameSize = size.frameSize
            let baseImageSize = size.imageSize
            let scale = min(geometry.size.width / baseFrameSize.width, geometry.size.height / baseFrameSize.height)
            let frameSize = CGSize(width: baseFrameSize.width * scale, height: baseFrameSize.height * scale)
            let imageSize = CGSize(width: baseImageSize.width * scale, height: baseImageSize.height * scale)
            let radius = 16 * scale

            VStack(alignment: .center, spacing: 0) {
                Color.clear
            }
            .padding(0)
            .frame(width: imageSize.width, height: imageSize.height, alignment: .center)
            .background(
                Image(imageName)
                    .resizable()
                    .modifier(CardImageModifier(mode: imageMode))
                    .frame(width: imageSize.width, height: imageSize.height)
                    .clipped()
            )
            .cornerRadius(radius)
            .overlay(
                RoundedRectangle(cornerRadius: radius)
                    .inset(by: 2 * scale)
                    .stroke(Color.homeWhite, lineWidth: 4 * scale)
            )
            .padding(.horizontal, 4 * scale)
            .padding(.vertical, 6 * scale)
            .background(Color.homeCardMat)
            .cornerRadius(radius)
            .frame(width: frameSize.width, height: frameSize.height)
            .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
        }
    }
}

private struct CardImageModifier: ViewModifier {
    let mode: SurpriseCard.ImageMode

    @ViewBuilder
    func body(content: Content) -> some View {
        switch mode {
        case .fill:
            content
                .scaledToFill()
        case .leftCrop:
            content
                .scaledToFill()
                .scaleEffect(1.18)
                .offset(x: -18, y: -3)
        case .rightCrop:
            content
                .scaledToFill()
                .scaleEffect(1.44)
                .offset(x: -24, y: -3)
        }
    }
}

private struct BottomTabBar: View {
    var body: some View {
        HStack(spacing: -8) {
            TabBarItem(systemName: "house.fill", title: "홈", isSelected: true)
            TabBarItem(systemName: "archivebox.fill", title: "보관함", isSelected: false)
        }
        .padding(.horizontal, 2)
        .padding(.vertical, 4)
        .background(
            Capsule()
                .fill(Color.homeWhite.opacity(0.65))
                .shadow(color: .black.opacity(0.12), radius: 20, x: 0, y: 8)
        )
        .overlay(
            Capsule()
                .stroke(Color.homeWhite.opacity(0.4), lineWidth: 1)
        )
        .frame(width: 208, height: 58)
    }
}

private struct TabBarItem: View {
    let systemName: String
    let title: String
    let isSelected: Bool

    var body: some View {
        VStack(spacing: 1) {
            Image(systemName: systemName)
                .font(.system(size: 18, weight: .semibold))
                .frame(height: 28)

            Text(title)
                .font(.system(size: 10, weight: .semibold))
                .lineLimit(1)
        }
        .foregroundStyle(isSelected ? Color.homeText : Color.homeTabInactive)
        .frame(width: 102, height: 50)
        .background {
            if isSelected {
                Capsule()
                    .fill(Color.homeTabSelection)
                    .padding(.horizontal, -2)
            }
        }
    }
}

private extension Color {
    static let homeBackground = Color("BackgroundPrimary")
    static let homeText = Color(red: 17 / 255, green: 17 / 255, blue: 17 / 255)
    static let homeSecondaryText = Color(red: 100 / 255, green: 89 / 255, blue: 82 / 255)
    static let homeCardMat = Color(red: 236 / 255, green: 228 / 255, blue: 209 / 255)
    static let homeTabSelection = Color(red: 237 / 255, green: 237 / 255, blue: 237 / 255)
    static let homeTabInactive = Color(red: 153 / 255, green: 153 / 255, blue: 153 / 255)
    static let homeWhite = Color.white
}

#Preview {
    HomeView()
}
