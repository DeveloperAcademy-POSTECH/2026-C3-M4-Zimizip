
import SwiftUI
import UIKit
import ImageIO

struct IntroductionPage {
    let text: String
    let buttonTitle: String
}

struct IntroductionView: View {
    let onStartButtonTap: () -> Void

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

    init(onStartButtonTap: @escaping () -> Void = {}) {
        self.onStartButtonTap = onStartButtonTap
    }

    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let screenHeight = geometry.size.height
            let scale = min(screenWidth / 402, 1)
            let imageScale = scale * 0.5
            let contentWidth = min(362, screenWidth - 40)
            let imageWidth = 244.38 * imageScale
            let imageHeight = 301.05 * imageScale
            let imageCenterY = 205 * scale + imageHeight / 2
            let textGroupTop = screenHeight / 2 + 98
            let textGroupHeight: CGFloat = 98
            let buttonCenterY = screenHeight - 88

            ZStack {
                Color("BackgroundPrimary")
                    .ignoresSafeArea()

                AnimatedAssetImage(name: "IntroductionCoverCharacter")
                    .frame(width: imageWidth, height: imageHeight)
                    .position(x: screenWidth / 2, y: imageCenterY)

                VStack(spacing: 40) {
                    Text("서프라이즈할 사진을 꾸미고\n커버로 덮어 숨겨보세요")
                        .font(Font.custom("Pretendard-Bold", size: 20))
                        .foregroundStyle(Color.introductionText)
                        .multilineTextAlignment(.center)
                        .lineSpacing(2)
                        .frame(maxWidth: .infinity)

                    HStack(spacing: 4) {
                        Capsule()
                            .fill(Color.introductionPrimary)
                            .frame(width: 16, height: 8)

                        Circle()
                            .fill(Color.introductionInactiveDot)
                            .frame(width: 8, height: 8)
                    }
                }
                .frame(width: contentWidth)
                .position(x: screenWidth / 2, y: textGroupTop + textGroupHeight / 2)

                Button {
                } label: {
                    Text("다음")
                        .font(Font.custom("Pretendard-Bold", size: 16))
                        .foregroundStyle(.white)
                        .frame(width: contentWidth, height: 56)
                        .background(Color.introductionPrimary)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
                .buttonStyle(.plain)
                .position(x: screenWidth / 2, y: buttonCenterY)
            }
        }
    }
}

private struct AnimatedAssetImage: UIViewRepresentable {
    let name: String

    func makeUIView(context: Context) -> UIImageView {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        configure(imageView)
        return imageView
    }

    func updateUIView(_ imageView: UIImageView, context: Context) {
        configure(imageView)
    }

    private func configure(_ imageView: UIImageView) {
        if let animation = UIImage.apngAnimationAsset(named: "\(name)Data") {
            imageView.image = animation.frames.first
            imageView.animationImages = animation.frames
            imageView.animationDuration = animation.duration
            imageView.animationRepeatCount = 0
        } else {
            imageView.image = UIImage(named: name)
            imageView.animationImages = nil
        }

        imageView.startAnimating()
    }
}

private extension UIImage {
    struct PNGAnimation {
        let frames: [UIImage]
        let duration: TimeInterval
    }

    static func apngAnimationAsset(named name: String) -> PNGAnimation? {
        guard let dataAsset = NSDataAsset(name: name) else {
            return nil
        }

        return pngAnimation(from: dataAsset.data)
    }

    static func pngAnimation(from data: Data) -> PNGAnimation? {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else {
            return nil
        }

        let frameCount = CGImageSourceGetCount(source)
        guard frameCount > 1 else {
            return nil
        }

        var frames: [UIImage] = []
        var duration: TimeInterval = 0

        for index in 0..<frameCount {
            guard let cgImage = CGImageSourceCreateImageAtIndex(source, index, nil) else {
                continue
            }

            frames.append(UIImage(cgImage: cgImage, scale: UIScreen.main.scale, orientation: .up))
            duration += frameDuration(at: index, source: source)
        }

        guard !frames.isEmpty else {
            return nil
        }

        let fasterDuration = duration * 0.6
        return PNGAnimation(frames: frames, duration: max(fasterDuration, TimeInterval(frames.count) * 0.02))
    }

    static func frameDuration(at index: Int, source: CGImageSource) -> TimeInterval {
        guard
            let properties = CGImageSourceCopyPropertiesAtIndex(source, index, nil) as? [CFString: Any],
            let pngProperties = properties[kCGImagePropertyPNGDictionary] as? [CFString: Any]
        else {
            return 0.1
        }

        if let unclampedDelay = pngProperties[kCGImagePropertyAPNGUnclampedDelayTime] as? TimeInterval {
            return max(unclampedDelay, 0.015)
        }

        if let delay = pngProperties[kCGImagePropertyAPNGDelayTime] as? TimeInterval {
            return max(delay, 0.015)
        }

        return 0.1
    }
}

private extension Color {
    static let introductionPrimary = Color(red: 1, green: 0.42, blue: 0.13)
    static let introductionText = Color(red: 17 / 255, green: 17 / 255, blue: 17 / 255)
    static let introductionInactiveDot = Color(red: 0.85, green: 0.85, blue: 0.85)
}

#Preview {
    IntroductionView()
}
