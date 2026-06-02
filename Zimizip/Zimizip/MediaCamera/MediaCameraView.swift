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
    @State private var isShowingColorPresets = false
    @State private var selectedManualControl: CameraManualControl?

    let onPhotoCaptured: (Data) -> Void

    init(onPhotoCaptured: @escaping (Data) -> Void = { _ in }) {
        self.onPhotoCaptured = onPhotoCaptured
    }

    var body: some View {
        GeometryReader { proxy in
            let topBarHeight: CGFloat = 44
            let manualAdjustmentHeight: CGFloat = 46
            let manualControlsHeight: CGFloat = 46
            let shutterBarHeight: CGFloat = 74
            let topSafeInset = max(proxy.safeAreaInsets.top, 6)
            let bottomSafeInset = max(proxy.safeAreaInsets.bottom, 4)
            let standardBottomInset = 2 + manualAdjustmentHeight + 2 + manualControlsHeight + 2 + shutterBarHeight + bottomSafeInset
            let presetBottomInset = 2 + 128 + 2 + shutterBarHeight + bottomSafeInset
            let previewTopInset = topSafeInset + topBarHeight
            let previewBottomInset = isShowingColorPresets ? presetBottomInset : standardBottomInset
            let previewFrame = CGRect(
                x: 0,
                y: previewTopInset,
                width: proxy.size.width,
                height: max(proxy.size.height - previewTopInset - previewBottomInset, 0)
            )

            ZStack {
                Color.black

                CameraPreviewSurface(session: camera.session)
                    .saturation(camera.selectedColorPreset.saturation * camera.whiteBalancePreset.previewSaturation)
                    .contrast(camera.selectedColorPreset.contrast * camera.whiteBalancePreset.previewContrast)
                    .brightness(camera.selectedColorPreset.brightness + camera.whiteBalancePreset.previewBrightness)
                    .colorMultiply(camera.selectedColorPreset.colorMultiply)
                    .colorMultiply(camera.whiteBalancePreset.previewColorMultiply)
                    .frame(width: previewFrame.width, height: previewFrame.height)
                    .clipShape(Rectangle())
                    .position(x: previewFrame.midX, y: previewFrame.midY)

                VStack(spacing: 0) {
                    VStack(spacing: 0) {
                        CameraTopBar(
                            isFlashEnabled: camera.isFlashEnabled,
                            onClose: { dismiss() },
                            onToggleFlash: { camera.toggleFlash() },
                            onSwitchCamera: { camera.switchCamera() }
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
                        if !isShowingColorPresets {
                            ZStack {
                                if let selectedManualControl {
                                    CameraManualAdjustmentPanel(
                                        selectedControl: selectedManualControl,
                                        exposureBias: camera.currentExposureBias,
                                        currentISO: camera.currentISO,
                                        isoRange: camera.isoRange,
                                        currentShutterDuration: camera.currentShutterDuration,
                                        shutterRange: camera.shutterRange,
                                        whiteBalancePreset: camera.whiteBalancePreset,
                                        onExposureChange: { camera.setExposureBias($0) },
                                        onSetISOAuto: { camera.setISOAuto() },
                                        onISOChange: { camera.setISO($0) },
                                        onSetShutterAuto: { camera.setShutterAuto() },
                                        onShutterChange: { camera.setShutterDuration($0) },
                                        onWhiteBalanceChange: { camera.setWhiteBalancePreset($0) }
                                    )
                                    .transition(.opacity)
                                }
                            }
                            .frame(height: manualAdjustmentHeight)

                            CameraManualControlsBar(
                                values: [
                                    .exposure: camera.displayValue(for: .exposure),
                                    .shutterSpeed: camera.displayValue(for: .shutterSpeed),
                                    .iso: camera.displayValue(for: .iso),
                                    .whiteBalance: camera.displayValue(for: .whiteBalance)
                                ],
                                selectedControl: $selectedManualControl,
                                onReset: { camera.resetManualControls() }
                            )
                            .frame(height: manualControlsHeight)
                            .transition(.opacity)
                        } else {
                            CameraColorPresetStrip(
                                selectedPreset: camera.selectedColorPreset,
                                onSelect: { camera.setColorPreset($0) }
                            )
                            .frame(maxWidth: .infinity)
                            .background(Color.black)
                            .clipShape(RoundedRectangle(cornerRadius: 18))
                            .overlay(
                                RoundedRectangle(cornerRadius: 18)
                                    .stroke(Color.white.opacity(0.08), lineWidth: 1)
                            )
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                        }

                        CameraShutterBar(
                            isShowingColorPresets: isShowingColorPresets,
                            onCapture: {
                                camera.capturePhoto { photoData in
                                    guard let photoData else {
                                        return
                                    }

                                    onPhotoCaptured(photoData)
                                    dismiss()
                                }
                            },
                            onToggleColorPresets: {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    if !isShowingColorPresets {
                                        selectedManualControl = nil
                                    }
                                    isShowingColorPresets.toggle()
                                }
                            }
                        )
                        .frame(height: shutterBarHeight)
                    }
                    .frame(height: isShowingColorPresets ? presetBottomInset : standardBottomInset, alignment: .bottom)
                    .padding(.horizontal, CameraUIConstants.screenHorizontalPadding)
                    .padding(.top, 0)
                    .padding(.bottom, max(bottomSafeInset - 2, 0))
                    .background(Color.black)
                }

                if camera.cameraAccessDenied || camera.cameraErrorMessage != nil {
                    CameraPermissionOverlay(message: camera.cameraErrorMessage)
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
