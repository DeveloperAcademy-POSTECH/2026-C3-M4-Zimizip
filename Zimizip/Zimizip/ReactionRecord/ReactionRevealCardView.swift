import SwiftUI
import UIKit

struct ReactionRevealCardView: View {
    @State private var revealPoints: [CGPoint] = []
    @State private var revealedImage: UIImage?
    @State private var isFullyRevealed = false

    let surpriseCardPayload: SurpriseCardPayload
    private let renderer = CoverRevealRenderer()
    private let brushRadius: CGFloat = 20
    private let autoRevealThreshold = 0.9

    var body: some View {
        SurpriseContentFrameView {
            GeometryReader { proxy in
                ZStack {
                    cardContent(frameSize: proxy.size)
                        .opacity(revealedImage == nil ? 1 : 0)

                    if let revealedImage {
                        Image(uiImage: revealedImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: proxy.size.width, height: proxy.size.height)
                    }
                }
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            appendRevealPoint(value.location, in: proxy.size)
                        }
                )
            }
        }
    }
}

private extension ReactionRevealCardView {
    func cardContent(frameSize: CGSize) -> some View {
        ZStack {
            completedImageView(frameSize: frameSize)

            Image(surpriseCardPayload.coverImageName)
                .resizable()
                .scaledToFill()
                .frame(width: frameSize.width, height: frameSize.height)
        }
    }

    func appendRevealPoint(_ point: CGPoint, in size: CGSize) {
        guard !isFullyRevealed else {
            return
        }

        guard point.x >= 0,
              point.y >= 0,
              point.x <= size.width,
              point.y <= size.height else {
            return
        }

        revealPoints.append(point)
        revealRemainingCoverIfNeeded(size: size)
        renderRevealedImage(size: size)
    }

    func renderRevealedImage(size: CGSize) {
        guard let bottomImage = renderedBottomImage(size: size) else {
            return
        }

        guard !isFullyRevealed else {
            revealedImage = bottomImage
            return
        }

        guard let coverImage = UIImage(named: surpriseCardPayload.coverImageName) else {
            return
        }

        revealedImage = renderer.render(
            bottomImage: bottomImage,
            coverImage: coverImage,
            revealPoints: revealPoints,
            outputSize: size,
            brushRadius: brushRadius
        )
    }

    func revealRemainingCoverIfNeeded(size: CGSize) {
        let revealedRatio = renderer.revealedRatio(
            outputSize: size,
            revealPoints: revealPoints,
            brushRadius: brushRadius
        )

        if revealedRatio >= autoRevealThreshold {
            isFullyRevealed = true
        }
    }

    @MainActor
    func renderedBottomImage(size: CGSize) -> UIImage? {
        let content = completedImageView(frameSize: size)
            .frame(width: size.width, height: size.height)

        let imageRenderer = ImageRenderer(content: content)
        imageRenderer.scale = 1
        return imageRenderer.uiImage
    }

    func completedImageView(frameSize: CGSize) -> some View {
        MainEditCompletedImageView(
            framingResult: surpriseCardPayload.framingResult,
            image: surpriseCardPayload.image,
            frameSize: frameSize
        )
    }
}

#Preview {
    ReactionRevealCardView(surpriseCardPayload: .previewValue)
}
