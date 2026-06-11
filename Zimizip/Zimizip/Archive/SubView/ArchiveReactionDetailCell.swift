import SwiftUI
import UIKit

struct ArchiveReactionDetailCell: View {
    let title: String
    let thumbnailData: Data?
    let width: CGFloat

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            thumbnailImage()
                .frame(width: 120, height: 180)
                .frame(maxWidth: .infinity)

            HStack(alignment: .top, spacing: 6) {
                Text(title)
                    .font(Font.custom("Pretendard-SemiBold", size: 16))
                    .foregroundStyle(Color.textPrimary)
                    .lineLimit(1)

                Spacer(minLength: 0)

                Image(systemName: "ellipsis")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(Color.textPrimary)
                    .frame(width: 24, height: 24)
                    .padding(.top, 6)
            }
        }
        .frame(width: width, alignment: .leading)
    }

    private func thumbnailImage() -> some View {
        Group {
            if let thumbnailData, let image = UIImage(data: thumbnailData) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                Image("Image")
                    .resizable()
                    .scaledToFit()
                    .padding(.horizontal, 24)
                    .padding(.vertical, 36)
                    .background(Color.gray50)
            }
        }
        .frame(width: 120, height: 180)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}

#Preview {
    ArchiveReactionDetailCell(
        title: "리액션 1",
        thumbnailData: ArchivePreviewData.imageData(color: .systemBlue),
        width: 171
    )
    .padding()
    .background(Color.backgroundPrimary)
}
