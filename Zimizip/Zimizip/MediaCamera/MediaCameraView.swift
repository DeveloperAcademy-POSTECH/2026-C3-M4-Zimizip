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
    @State private var isShowingQuickSettings = false
    @State private var isShowingColorPresets = false
    @State private var selectedQuickSetting: CameraQuickSetting = .aspectRatio
    @State private var selectedAspectRatio: CameraAspectRatioOption = .threeByFour
    @State private var selectedTimer: CameraTimerOption = .off
    @State private var gridMode: CameraGridMode = .off
    @State private var selectedManualControl: CameraManualControl?

    let onPhotoCaptured: (Data) -> Void

    init(onPhotoCaptured: @escaping (Data) -> Void = { _ in }) {
        self.onPhotoCaptured = onPhotoCaptured
    }

    var body: some View {
        GeometryReader { proxy in
            let topBarHeight: CGFloat = 44
            let quickSettingsPanelHeight: CGFloat = 124
            let manualAdjustmentHeight: CGFloat = 46
            let manualControlsHeight: CGFloat = 46
            let shutterBarHeight: CGFloat = 74
            let topSafeInset = max(proxy.safeAreaInsets.top, 6)
            let bottomSafeInset = max(proxy.safeAreaInsets.bottom, 4)
            let standardBottomInset = 2 + manualAdjustmentHeight + 2 + manualControlsHeight + 2 + shutterBarHeight + bottomSafeInset
            let presetBottomInset = 2 + 128 + 2 + shutterBarHeight + bottomSafeInset
            let previewTopInset = topSafeInset + topBarHeight
            let previewBottomInset = isShowingColorPresets ? presetBottomInset : standardBottomInset
            let previewContentRect = CGRect(
                x: 0,
                y: previewTopInset,
                width: proxy.size.width,
                height: max(proxy.size.height - previewTopInset - previewBottomInset, 0)
            )
            let isNativePreviewAspect = selectedAspectRatio == .threeByFour
            let previewFrame = isNativePreviewAspect
                ? previewContentRect
                : selectedAspectRatio.frame(in: previewContentRect)

            ZStack {
                Color.black

                CameraPreviewSurface(session: camera.session)
                    .saturation(camera.selectedColorPreset.saturation)
                    .contrast(camera.selectedColorPreset.contrast)
                    .brightness(camera.selectedColorPreset.brightness)
                    .colorMultiply(camera.selectedColorPreset.colorMultiply)
                    .frame(width: previewFrame.width, height: previewFrame.height)
                    .clipShape(Rectangle())
                    .overlay {
                        if !isNativePreviewAspect {
                            CameraAspectRatioOverlay()
                                .animation(.easeInOut(duration: 0.24), value: selectedAspectRatio)
                        }
                    }
                    .overlay {
                        if gridMode != .off {
                            CameraGridOverlay(gridMode: gridMode)
                                .animation(.easeInOut(duration: 0.24), value: selectedAspectRatio)
                        }
                    }
                    .position(x: previewFrame.midX, y: previewFrame.midY)

                VStack(spacing: 0) {
                    VStack(spacing: 0) {
                        CameraTopBar(
                            isFlashEnabled: camera.isFlashEnabled,
                            isQuickSettingsExpanded: isShowingQuickSettings,
                            onToggleFlash: { camera.toggleFlash() },
                            onSwitchCamera: { camera.switchCamera() },
                            onToggleQuickSettings: toggleQuickSettings
                        )

                    }
                    .padding(.top, topSafeInset)
                    .frame(height: topBarHeight + topSafeInset, alignment: .top)
                    .background(Color.black)

                    Spacer()
                }

                if isShowingQuickSettings {
                    VStack(spacing: 8) {
                        CameraQuickSettingsBar(
                            selectedQuickSetting: selectedQuickSetting,
                            selectedAspectRatio: selectedAspectRatio,
                            selectedTimer: selectedTimer
                        ) { quickSetting in
                            withAnimation(.easeInOut(duration: 0.18)) {
                                selectedQuickSetting = quickSetting
                            }
                        }

                        CameraSettingsPanel(
                            selectedQuickSetting: selectedQuickSetting,
                            selectedAspectRatio: $selectedAspectRatio,
                            selectedTimer: $selectedTimer,
                            gridMode: $gridMode
                        )
                    }
                    .frame(maxWidth: 188)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 10)
                    .background(Color.black.opacity(0.92))
                    .clipShape(RoundedRectangle(cornerRadius: 18))
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(Color.white.opacity(0.08), lineWidth: 1)
                    )
                    .frame(height: quickSettingsPanelHeight)
                    .position(x: previewFrame.midX, y: previewFrame.midY)
                    .transition(.opacity.combined(with: .scale(scale: 0.96)))
                }

                if let countdownValue = camera.countdownValue {
                    CameraCountdownOverlay(value: countdownValue)
                        .position(x: previewFrame.midX, y: previewFrame.midY)
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
                            onClose: { dismiss() },
                            onCapture: {
                                camera.capturePhoto(
                                    using: selectedTimer,
                                    aspectRatio: selectedAspectRatio
                                ) { photoData in
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

    private func toggleQuickSettings() {
        withAnimation(.easeInOut(duration: 0.18)) {
            isShowingQuickSettings.toggle()
        }
    }
}

#Preview {
    MediaCameraView()
}
