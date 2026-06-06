//
//  PhotoFramingView.swift
//  Zimizip
//
//  Created by Mason's Mac on 6/5/26.
//

import SwiftUI

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

#Preview {
    PhotoFramingView(
        media: Data(),
        cancelButtonAction: {},
        completeButtonAction: {}
    )
}
