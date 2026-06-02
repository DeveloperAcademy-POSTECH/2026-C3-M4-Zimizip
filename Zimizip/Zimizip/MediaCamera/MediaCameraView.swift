//
//  MediaCameraView.swift
//  Zimizip
//
//  Created by Mason's Mac on 5/31/26.
//

import SwiftUI

struct MediaCameraView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var camera = CameraPreviewModel()

    var body: some View {
        GeometryReader { proxy in
            let topBarHeight: CGFloat = 44
            let manualAdjustmentHeight: CGFloat = 46
            let manualControlsHeight: CGFloat = 46
            let shutterBarHeight: CGFloat = 74
            let topSafeInset = max(proxy.safeAreaInsets.top, 6)
            let bottomSafeInset = max(proxy.safeAreaInsets.bottom, 4)
            let standardBottomInset = 2 + manualAdjustmentHeight + 2 + manualControlsHeight + 2 + shutterBarHeight + bottomSafeInset
            let previewTopInset = topSafeInset + topBarHeight
            let previewFrame = CGRect(
                x: 0,
                y: previewTopInset,
                width: proxy.size.width,
                height: max(proxy.size.height - previewTopInset - standardBottomInset, 0)
            )

            ZStack {
                Color.black

                CameraPreviewSurface(session: camera.session)
                    .frame(width: previewFrame.width, height: previewFrame.height)
                    .clipShape(Rectangle())
                    .position(x: previewFrame.midX, y: previewFrame.midY)

                VStack(spacing: 0) {
                    VStack(spacing: 0) {
                        CameraTopBar(
                            isFlashEnabled: camera.isFlashEnabled,
                            onClose: {
                                dismiss()
                            },
                            onToggleFlash: {
                                camera.toggleFlash()
                            },
                            onSwitchCamera: {
                                camera.switchCamera()
                            }
                        )

                    }
                    .padding(.top, topSafeInset)
                    .frame(height: topBarHeight + topSafeInset, alignment: .top)
                    .background(Color.black)

                    Spacer()
                }

                VStack(spacing: 0) {
                    Spacer()

                    VStack(spacing: 10) {
                        Color.clear
                            .frame(height: manualAdjustmentHeight)

                        CameraManualControlsBar(values: CameraManualControl.defaultDisplayValues)
                            .frame(height: manualControlsHeight)

                        CameraShutterBar()
                            .frame(height: shutterBarHeight)
                    }
                    .frame(height: standardBottomInset, alignment: .bottom)
                    .padding(.horizontal, CameraUIConstants.screenHorizontalPadding)
                    .padding(.top, 0)
                    .padding(.bottom, max(bottomSafeInset - 2, 0))
                    .background(Color.black)
                }
            }
            .background(Color.black)
            .ignoresSafeArea()
        }
        .statusBarHidden()
        .task {
            await camera.prepareCameraPreview()
        }
        .onDisappear {
            camera.stopSession()
        }
    }
}

#Preview {
    MediaCameraView()
}
