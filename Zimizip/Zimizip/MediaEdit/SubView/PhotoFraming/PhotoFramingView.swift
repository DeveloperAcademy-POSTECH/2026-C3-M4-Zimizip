//
//  PhotoFramingView.swift
//  Zimizip
//
//  Created by Mason's Mac on 6/5/26.
//

import SwiftUI
import UIKit

struct PhotoFramingView: View {
    @State private var selectedBackgroundColor: PhotoFramingBackgroundColor = .white

    let media: Data
    let sourcePreviewFrame: CGRect?
    let isLandscapeCapture: Bool
    let cancelButtonAction: () -> Void
    let completeButtonAction: () -> Void

    init(
        media: Data,
        sourcePreviewFrame: CGRect? = nil,
        isLandscapeCapture: Bool = false,
        cancelButtonAction: @escaping () -> Void,
        completeButtonAction: @escaping () -> Void
    ) {
        self.media = media
        self.sourcePreviewFrame = sourcePreviewFrame
        self.isLandscapeCapture = isLandscapeCapture
        self.cancelButtonAction = cancelButtonAction
        self.completeButtonAction = completeButtonAction
    }

    var body: some View {
        VStack(spacing: 0) {
            PhotoFramingTopBar(
                cancelButtonAction: cancelButtonAction,
                completeButtonAction: completeButtonAction
            )

            PhotoFramingEditingArea(
                media: media,
                backgroundColor: selectedBackgroundColor.color,
                sourcePreviewFrame: sourcePreviewFrame,
                isLandscapeCapture: isLandscapeCapture
            )

            PhotoFramingBackgroundPanel(
                selectedBackgroundColor: $selectedBackgroundColor
            )
        }
        .background(Color.black)
    }
}

private struct PhotoFramingTopBar: View {
    let cancelButtonAction: () -> Void
    let completeButtonAction: () -> Void

    var body: some View {
        HStack {
            Button("취소") {
                cancelButtonAction()
            }
            .font(.system(size: 17, weight: .regular))
            .foregroundStyle(.white)
            .frame(width: 56, alignment: .leading)
            .buttonStyle(.plain)

            Spacer()

            Text("사진 배치")
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(.white)

            Spacer()

            Button("완료") {
                completeButtonAction()
            }
            .font(.system(size: 17, weight: .semibold))
            .foregroundStyle(.white)
            .frame(width: 56, alignment: .trailing)
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 18)
        .background(Color.black)
    }
}

private struct PhotoFramingEditingArea: View {
    let media: Data
    let backgroundColor: Color
    let sourcePreviewFrame: CGRect?
    let isLandscapeCapture: Bool

    var body: some View {
        GeometryReader { proxy in
            let availableWidth = max(proxy.size.width - 76, 0)
            let availableHeightWidth = max(proxy.size.height * 2 / 3 - 40, 0)
            let frameWidth = min(availableWidth, availableHeightWidth)
            let frameSize = CGSize(width: frameWidth, height: frameWidth * 3 / 2)
            let image = UIImage(data: media)
            let photoSize = image.map {
                PhotoFramingLayout.photoSize(
                    imageSize: $0.size,
                    frameSize: frameSize,
                    sourcePreviewFrame: sourcePreviewFrame,
                    isLandscapeCapture: isLandscapeCapture
                )
            }

            ZStack {
                Color.black

                if let image, let photoSize {
                    PhotoFramingPhotoLayer(
                        image: image,
                        contentMode: .fill
                    )
                    .frame(width: photoSize.width, height: photoSize.height)
                    .opacity(0.34)
                    .position(x: proxy.size.width / 2, y: proxy.size.height / 2)
                }

                PhotoFramingFrame(
                    image: image,
                    backgroundColor: backgroundColor,
                    frameSize: frameSize,
                    photoSize: photoSize
                )
                .position(x: proxy.size.width / 2, y: proxy.size.height / 2)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private struct PhotoFramingFrame: View {
    let image: UIImage?
    let backgroundColor: Color
    let frameSize: CGSize
    let photoSize: CGSize?

    var body: some View {
        ZStack {
            backgroundColor

            if let image, let photoSize {
                PhotoFramingPhotoLayer(
                    image: image,
                    contentMode: .fill
                )
                .frame(width: photoSize.width, height: photoSize.height)

                PhotoFramingGridGuide()
                    .frame(width: photoSize.width, height: photoSize.height)
            }
        }
        .frame(width: frameSize.width, height: frameSize.height)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

private struct PhotoFramingPhotoLayer: View {
    let image: UIImage
    let contentMode: ContentMode

    var body: some View {
        Image(uiImage: image)
            .resizable()
            .aspectRatio(contentMode: contentMode)
            .clipped()
    }
}

private enum PhotoFramingLayout {
    private static let landscapeCaptureAspectRatio: CGFloat = 402 / 226

    static func photoSize(
        imageSize: CGSize,
        frameSize: CGSize,
        sourcePreviewFrame: CGRect?,
        isLandscapeCapture: Bool
    ) -> CGSize {
        guard imageSize.width > 0, imageSize.height > 0 else {
            return .zero
        }

        let photoAspectRatio = sourceAspectRatio(
            imageSize: imageSize,
            sourcePreviewFrame: sourcePreviewFrame,
            isLandscapeCapture: isLandscapeCapture
        )
        let frameAspectRatio = frameSize.width / frameSize.height

        if photoAspectRatio > frameAspectRatio {
            return CGSize(
                width: frameSize.width,
                height: frameSize.width / photoAspectRatio
            )
        } else {
            return CGSize(
                width: frameSize.height * photoAspectRatio,
                height: frameSize.height
            )
        }
    }

    private static func sourceAspectRatio(
        imageSize: CGSize,
        sourcePreviewFrame: CGRect?,
        isLandscapeCapture: Bool
    ) -> CGFloat {
        if isLandscapeCapture {
            return landscapeCaptureAspectRatio
        }

        if let sourcePreviewFrame,
           sourcePreviewFrame.width > 0,
           sourcePreviewFrame.height > 0 {
            return sourcePreviewFrame.width / sourcePreviewFrame.height
        }

        return imageSize.width / imageSize.height
    }
}

private struct PhotoFramingGridGuide: View {
    var body: some View {
        GeometryReader { proxy in
            Path { path in
                let columnWidth = proxy.size.width / 3
                let rowHeight = proxy.size.height / 3

                for index in 1...2 {
                    let x = columnWidth * CGFloat(index)
                    path.move(to: CGPoint(x: x, y: 0))
                    path.addLine(to: CGPoint(x: x, y: proxy.size.height))

                    let y = rowHeight * CGFloat(index)
                    path.move(to: CGPoint(x: 0, y: y))
                    path.addLine(to: CGPoint(x: proxy.size.width, y: y))
                }
            }
            .stroke(Color.white.opacity(0.62), lineWidth: 1)
        }
    }
}

private enum PhotoFramingBackgroundColor: CaseIterable, Identifiable {
    case white
    case red
    case orange
    case yellow
    case green

    var id: Self { self }

    var color: Color {
        switch self {
        case .white:
            return .white
        case .red:
            return Color(red: 1.0, green: 0.07, blue: 0.05)
        case .orange:
            return Color(red: 1.0, green: 0.48, blue: 0.05)
        case .yellow:
            return Color(red: 1.0, green: 0.88, blue: 0.0)
        case .green:
            return Color(red: 0.12, green: 1.0, blue: 0.34)
        }
    }

    var accessibilityLabel: String {
        switch self {
        case .white:
            return "흰색"
        case .red:
            return "빨간색"
        case .orange:
            return "주황색"
        case .yellow:
            return "노란색"
        case .green:
            return "초록색"
        }
    }
}

private struct PhotoFramingBackgroundPanel: View {
    @Binding var selectedBackgroundColor: PhotoFramingBackgroundColor

    var body: some View {
        VStack(alignment: .leading, spacing: 26) {
            HStack {
                Text("배경색")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Color(red: 1.0, green: 0.37, blue: 0.0))

                Spacer()
            }

            HStack(spacing: 30) {
                ForEach(PhotoFramingBackgroundColor.allCases) { backgroundColor in
                    PhotoFramingBackgroundSwatch(
                        backgroundColor: backgroundColor,
                        isSelected: selectedBackgroundColor == backgroundColor
                    ) {
                        selectedBackgroundColor = backgroundColor
                    }
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
        .padding(.bottom, 24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(red: 0.12, green: 0.10, blue: 0.09))
    }
}

private struct PhotoFramingBackgroundSwatch: View {
    let backgroundColor: PhotoFramingBackgroundColor
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .stroke(
                        Color(red: 1.0, green: 0.37, blue: 0.0),
                        lineWidth: isSelected ? 3 : 0
                    )
                    .frame(width: 48, height: 48)

                Circle()
                    .fill(backgroundColor.color)
                    .frame(width: 36, height: 36)
            }
            .frame(width: 48, height: 48)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(backgroundColor.accessibilityLabel)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

#Preview {
    PhotoFramingView(
        media: Data(),
        cancelButtonAction: {},
        completeButtonAction: {}
    )
}
