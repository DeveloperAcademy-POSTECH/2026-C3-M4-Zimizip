import SwiftUI
import UIKit

struct ArchiveThumbnailView: View {
    let thumbnail: ArchiveThumbnail
    let width: CGFloat

    var body: some View {
        switch thumbnail {
        case let .reaction(thumbnailData, overlayText):
            ReactionArchiveThumbnail(thumbnailData: thumbnailData, overlayText: overlayText, size: width)
        case let .surpriseCard(coverImageName):
            SurpriseCardArchiveThumbnail(coverImageName: coverImageName)
                .frame(width: width, height: 180)
        }
    }
}

private struct ReactionArchiveThumbnail: View {
    let thumbnailData: [Data]
    let overlayText: String?
    let size: CGFloat

    var body: some View {
        let imageScale = size / 171

        ZStack {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.gray50)

            if thumbnailData.isEmpty {
                Image("Image")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 72 * imageScale, height: 108 * imageScale)
            } else if thumbnailData.count == 1 {
                reactionImage(thumbnailData[0], width: 72 * imageScale, height: 108 * imageScale)
            } else if thumbnailData.count == 2 {
                reactionImage(thumbnailData[0], width: 60 * imageScale, height: 90 * imageScale)
                    .rotationEffect(.degrees(-13.43))
                    .offset(x: -26 * imageScale, y: -2 * imageScale)

                reactionImage(thumbnailData[1], width: 60 * imageScale, height: 90 * imageScale)
                    .rotationEffect(.degrees(13))
                    .offset(x: 25 * imageScale, y: -2 * imageScale)
            } else {
                reactionImage(thumbnailData[0], width: 60 * imageScale, height: 90 * imageScale)
                    .rotationEffect(.degrees(-13.43))
                    .offset(x: -34 * imageScale, y: 4 * imageScale)

                reactionImage(thumbnailData[1], width: 60 * imageScale, height: 90 * imageScale)
                    .offset(x: 0, y: -4 * imageScale)

                ZStack {
                    reactionImage(thumbnailData[2], width: 60 * imageScale, height: 90 * imageScale)

                    if let overlayText {
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(Color.gray450.opacity(0.5))

                        Text(overlayText)
                            .font(Font.custom("Pretendard-SemiBold", size: 16))
                            .foregroundStyle(Color.backgroundPrimary)
                    }
                }
                .frame(width: 60 * imageScale, height: 90 * imageScale)
                .rotationEffect(.degrees(8.13))
                .offset(x: 32 * imageScale, y: 8 * imageScale)
            }
        }
        .frame(width: size, height: size)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private func reactionImage(_ data: Data, width: CGFloat, height: CGFloat) -> some View {
        Group {
            if let image = UIImage(data: data) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: width, height: height)
                    .clipShape(RoundedRectangle(cornerRadius: width == 72 ? 9.6 : 8, style: .continuous))
            } else {
                RoundedRectangle(cornerRadius: width == 72 ? 9.6 : 8, style: .continuous)
                    .fill(Color.gray150)
                    .frame(width: width, height: height)
            }
        }
        .frame(width: width, height: height)
    }
}

private struct SurpriseCardArchiveThumbnail: View {
    let coverImageName: String

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(Color.coverLine)
                .frame(width: 120, height: 180)

            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(Color.baseWhite)
                .frame(width: 116, height: 174)

            Image(coverImageName)
                .resizable()
                .scaledToFill()
                .frame(width: 116, height: 174)
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview("Reaction") {
    ArchiveThumbnailView(
        thumbnail: ArchivePreviewData.reactionDisplayItem().thumbnail,
        width: 171
    )
    .padding()
    .background(Color.backgroundPrimary)
}

#Preview("Surprise Card") {
    ArchiveThumbnailView(
        thumbnail: ArchivePreviewData.surpriseCardDisplayItem().thumbnail,
        width: 171
    )
    .padding()
    .background(Color.backgroundPrimary)
}
