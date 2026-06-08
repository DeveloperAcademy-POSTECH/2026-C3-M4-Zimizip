import SwiftUI
import UIKit

struct MainEditFilterThumbnail: View {
    let preset: MainEditFilterPreset
    let thumbnailImage: UIImage?
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            thumbnail
        }
        .buttonStyle(.plain)
    }
}

private extension MainEditFilterThumbnail {
    var thumbnail: some View {
        ZStack(alignment: .bottom) {
            thumbnailContent
                .frame(
                    width: MainEditLayout.filterThumbnailSize.width,
                    height: MainEditLayout.filterThumbnailSize.height
                )
                .clipped()

            Text(preset.title)
                .font(.custom("Pretendard", size: MainEditLayout.filterThumbnailLabelFontSize).weight(isSelected ? .semibold : .bold))
                .multilineTextAlignment(.center)
                .foregroundStyle(labelColor)
                .frame(width: MainEditLayout.filterThumbnailSize.width, alignment: .center)
                .background(labelBackgroundColor)
        }
        .frame(
            width: MainEditLayout.filterThumbnailSize.width,
            height: MainEditLayout.filterThumbnailSize.height,
            alignment: .bottom
        )
        .overlay {
            if isSelected {
                Rectangle()
                    .stroke(Color.buttonSelectedLine, lineWidth: 1)
            }
        }
    }

    @ViewBuilder
    var thumbnailContent: some View {
        if let thumbnailImage {
            Image(uiImage: thumbnailImage)
                .resizable()
                .aspectRatio(contentMode: .fill)
        } else {
            Color.gray50
        }
    }

    var labelColor: Color {
        isSelected ? .brandPrimary : .gray400
    }

    var labelBackgroundColor: Color {
        isSelected ? .buttonSelected : .gray50
    }
}

#Preview {
    MainEditFilterThumbnail(
        preset: .original,
        thumbnailImage: nil,
        isSelected: true,
        action: {}
    )
    .padding()
    .background(Color.black)
}
