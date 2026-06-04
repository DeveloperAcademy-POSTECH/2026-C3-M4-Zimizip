//
//  HomeView.swift
//  Zimizip
//
//  Created by Sunny Side-Up on 6/1/26.
//

import SwiftUI

struct HomeView: View {
    private let mainCardURL = URL(string: "https://www.figma.com/api/mcp/asset/bc7c5147-7496-42c2-8b2d-a58188193048")
    private let leftCardURL = URL(string: "https://www.figma.com/api/mcp/asset/8094145e-bbad-40de-9ebb-1bb383fa5c03")
    private let rightCardURL = URL(string: "https://www.figma.com/api/mcp/asset/e4944820-5ec9-4c23-9bc0-2fa83eed6019")

    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let screenHeight = geometry.size.height
            let centerX = screenWidth / 2
            let scale = min(screenWidth / 402, 1.08)

            ZStack(alignment: .topLeading) {
                Color("BackgroundPrimary")
                    .ignoresSafeArea()

                Text("soprize")
                    .font(.system(size: 28, weight: .black, design: .rounded))
                    .foregroundStyle(Color.primaryText)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                    .position(x: screenWidth / 2, y: 101)

                Text("대기 중인\n서프라이즈 카드")
                    .font(Font.custom("Pretendard-Bold", size: 28))
                    .foregroundStyle(Color.primaryText)
                    .lineSpacing(2)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                    .position(x: screenWidth / 2, y: 185)

                SurpriseCardCarousel(
                    mainCardURL: mainCardURL,
                    leftCardURL: leftCardURL,
                    rightCardURL: rightCardURL,
                    scale: scale
                )
                .frame(width: screenWidth, height: 430)
                .position(x: centerX, y: min(screenHeight * 0.56, 505))

                Text("연 솔로지옥 등장 리액션")
                    .font(Font.custom("Pretendard-Medium", size: 16))
                    .foregroundStyle(Color.secondaryText)
                    .frame(width: 240)
                    .position(x: centerX, y: min(screenHeight * 0.78, 680))

                BottomTabBar()
                    .position(x: centerX - 77, y: screenHeight - 49)

                Button {
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 30, weight: .regular))
                        .foregroundStyle(.white)
                        .frame(width: 58, height: 58)
                        .background(Color("OrangePrimary"))
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.12), radius: 20, x: 0, y: 8)
                }
                .buttonStyle(.plain)
                .position(x: screenWidth - 51, y: screenHeight - 49)
            }
        }
    }
}

private struct SurpriseCardCarousel: View {
    let mainCardURL: URL?
    let leftCardURL: URL?
    let rightCardURL: URL?
    let scale: CGFloat

    var body: some View {
        ZStack {
            SurpriseCard(url: leftCardURL, imageMode: .leftCrop)
                .frame(width: 160 * scale, height: 240 * scale)
                .position(x: -20 * scale, y: 215 * scale)

            SurpriseCard(url: rightCardURL, imageMode: .rightCrop)
                .frame(width: 160 * scale, height: 240 * scale)
                .position(x: 422 * scale, y: 215 * scale)

            SurpriseCard(url: mainCardURL, imageMode: .fit)
                .frame(width: 240 * scale, height: 360 * scale)
                .position(x: 201 * scale, y: 215 * scale)
        }
    }
}

private struct SurpriseCard: View {
    enum ImageMode {
        case fit
        case leftCrop
        case rightCrop
    }

    let url: URL?
    let imageMode: ImageMode

    var body: some View {
        GeometryReader { geometry in
            let borderWidth: CGFloat = 4

            ZStack {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.cardMat)

                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(.white)
                    .padding(4)

                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .modifier(CardImageModifier(mode: imageMode))
                    case .failure:
                        Color.cardMat
                    case .empty:
                        Color.cardMat.opacity(0.65)
                    @unknown default:
                        Color.cardMat
                    }
                }
                .frame(
                    width: max(0, geometry.size.width - (borderWidth * 2)),
                    height: max(0, geometry.size.height - (borderWidth * 2))
                )
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
        }
    }
}

private struct CardImageModifier: ViewModifier {
    let mode: SurpriseCard.ImageMode

    @ViewBuilder
    func body(content: Content) -> some View {
        switch mode {
        case .fit:
            content
                .scaledToFill()
        case .leftCrop:
            content
                .scaledToFill()
                .scaleEffect(1.2)
                .offset(x: -18, y: -3)
        case .rightCrop:
            content
                .scaledToFill()
                .scaleEffect(1.52)
                .offset(x: -28, y: -4)
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
                .fill(.white.opacity(0.65))
                .shadow(color: .black.opacity(0.12), radius: 20, x: 0, y: 8)
        )
        .overlay(
            Capsule()
                .stroke(.white.opacity(0.4), lineWidth: 1)
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
                .font(.system(size: 25, weight: .semibold))
                .frame(height: 28)

            Text(title)
                .font(.system(size: 10, weight: .semibold))
                .lineLimit(1)
        }
        .foregroundStyle(isSelected ? Color.primaryText : Color.gray.opacity(0.72))
        .frame(width: 102, height: 50)
        .background {
            if isSelected {
                Capsule()
                    .fill(Color(red: 0.93, green: 0.93, blue: 0.93))
            }
        }
    }
}

private extension Color {
    static let primaryText = Color(red: 17 / 255, green: 17 / 255, blue: 17 / 255)
    static let secondaryText = Color(red: 100 / 255, green: 89 / 255, blue: 82 / 255)
    static let cardMat = Color(red: 236 / 255, green: 228 / 255, blue: 209 / 255)
}

#Preview {
    HomeView()
}
