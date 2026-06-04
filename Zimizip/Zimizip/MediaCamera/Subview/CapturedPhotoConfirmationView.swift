import SwiftUI
import UIKit

struct CapturedPhotoConfirmationView: View {
    let photoData: Data
    let previewFrame: CGRect
    let isLandscapeCapture: Bool
    let onRetake: () -> Void
    let onUsePhoto: () -> Void

    private let designWidth: CGFloat = 402
    private let designImageHeight: CGFloat = 226
    private let bottomBarHeight: CGFloat = 108

    var body: some View {
        GeometryReader { proxy in
            let photoFrame = photoFrame(in: proxy.size, previewFrame: previewFrame)

            ZStack {
                Color.black
                    .ignoresSafeArea()

                capturedPhoto
                    .frame(
                        width: photoFrame.width,
                        height: photoFrame.height
                    )
                    .clipped()
                    .position(x: proxy.size.width / 2, y: photoFrame.midY)

                VStack {
                    Spacer()

                    HStack {
                        Button(action: onRetake) {
                            Text("다시 찍기")
                                .font(.custom("Pretendard", size: 16).weight(.bold))
                                .foregroundStyle(.white)
                                .frame(minWidth: 72, minHeight: 44, alignment: .leading)
                        }
                        .buttonStyle(.plain)

                        Spacer()

                        Button(action: onUsePhoto) {
                            Text("사진 사용")
                                .font(.custom("Pretendard", size: 16).weight(.bold))
                                .foregroundStyle(.white)
                                .frame(minWidth: 72, minHeight: 44, alignment: .trailing)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                    .frame(width: proxy.size.width, height: bottomBarHeight, alignment: .center)
                    .background(Color(red: 0.23, green: 0.21, blue: 0.2).opacity(0.5))
                }
                .ignoresSafeArea(edges: .bottom)
            }
        }
        .background(Color.black)
    }

    @ViewBuilder
    private var capturedPhoto: some View {
        if let image = UIImage(data: photoData) {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fill)
        } else {
            Text("사진을 불러올 수 없어요")
                .font(.custom("Pretendard", size: 16).weight(.bold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.white.opacity(0.08))
        }
    }

    private func photoFrame(in containerSize: CGSize, previewFrame: CGRect) -> CGRect {
        let contentHeight = max(containerSize.height - bottomBarHeight, 0)

        guard previewFrame.width > 0, previewFrame.height > 0 else {
            return CGRect(x: 0, y: 0, width: containerSize.width, height: contentHeight)
        }

        if isLandscapeCapture {
            let imageHeight = containerSize.width * designImageHeight / designWidth
            return CGRect(
                x: 0,
                y: (contentHeight - imageHeight) / 2,
                width: containerSize.width,
                height: imageHeight
            )
        }

        let imageHeight = min(previewFrame.height, contentHeight)
        let imageTop = min(max(previewFrame.minY, 0), max(contentHeight - imageHeight, 0))
        return CGRect(
            x: 0,
            y: imageTop,
            width: previewFrame.width,
            height: imageHeight
        )
    }
}

#Preview {
    CapturedPhotoConfirmationView(
        photoData: Data(),
        previewFrame: CGRect(x: 0, y: 108, width: 402, height: 510),
        isLandscapeCapture: false,
        onRetake: {},
        onUsePhoto: {}
    )
}
