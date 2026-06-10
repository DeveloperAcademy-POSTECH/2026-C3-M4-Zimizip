//
//  PhotoFramingView.swift
//  Zimizip
//
//  Created by Mason's Mac on 6/5/26.
//

import SwiftUI

struct PhotoFramingView: View {
    @State private var selectedBackgroundColor: PhotoFramingBackgroundColor = .white
    @State private var transformState: PhotoFramingTransformState?

    let media: Data
    let sourcePreviewFrame: CGRect?
    let isLandscapeCapture: Bool
    let cancelButtonAction: () -> Void
    let completeButtonAction: (PhotoFramingResult) -> Void

    init(
        media: Data,
        sourcePreviewFrame: CGRect? = nil,
        isLandscapeCapture: Bool = false,
        cancelButtonAction: @escaping () -> Void,
        completeButtonAction: @escaping (PhotoFramingResult) -> Void
    ) {
        self.media = media
        self.sourcePreviewFrame = sourcePreviewFrame
        self.isLandscapeCapture = isLandscapeCapture
        self.cancelButtonAction = cancelButtonAction
        self.completeButtonAction = completeButtonAction
    }

    var body: some View {
        ZStack(alignment: .top) {
            VStack(spacing: 0) {
                Color.clear
                    .frame(height: Self.topBarHeight)

                PhotoFramingEditingArea(
                    media: media,
                    backgroundColor: selectedBackgroundColor.color,
                    sourcePreviewFrame: sourcePreviewFrame,
                    isLandscapeCapture: isLandscapeCapture,
                    transformChangeAction: { transformState in
                        self.transformState = transformState
                    }
                )

                PhotoFramingBackgroundPanel(
                    selectedBackgroundColor: $selectedBackgroundColor
                )
            }

            PhotoFramingTopBar(
                cancelButtonAction: cancelButtonAction,
                completeButtonAction: completeFraming
            )
            .zIndex(1)
        }
        .background(Color.black)
    }

    private static let topBarHeight: CGFloat = 48

    private func completeFraming() {
        guard let transformState,
              transformState.isValid else {
            return
        }

        completeButtonAction(
            PhotoFramingResult(
                source: media,
                backgroundColor: selectedBackgroundColor,
                transformState: transformState,
                sourcePreviewFrame: sourcePreviewFrame,
                isLandscapeCapture: isLandscapeCapture
            )
        )
    }
}

#Preview {
    PhotoFramingView(
        media: Data(),
        cancelButtonAction: {},
        completeButtonAction: { _ in }
    )
}
