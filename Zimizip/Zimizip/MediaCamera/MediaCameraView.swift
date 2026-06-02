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
    @State private var temporaryShutterSpeedValue: Double = 0.55
    @State private var temporaryISOValue: Double = 100
    @State private var temporaryWhiteBalancePreset: CameraTemporaryWhiteBalancePreset = .auto

    let onPhotoCaptured: (Data) -> Void

    init(onPhotoCaptured: @escaping (Data) -> Void = { _ in }) {
        self.onPhotoCaptured = onPhotoCaptured
    }

    var body: some View {
        GeometryReader { proxy in
            let topBarHeight: CGFloat = 44
            let manualAdjustmentHeight: CGFloat = 64
            let manualControlsHeight: CGFloat = 46
            let shutterBarHeight: CGFloat = 74
            let colorPresetStripHeight: CGFloat = 132
            let adjustmentToControlsSpacing: CGFloat = 2
            let controlsToShutterSpacing: CGFloat = 10
            let colorPresetToShutterSpacing: CGFloat = 2
            let topSafeInset = max(proxy.safeAreaInsets.top, 6)
            let bottomSafeInset = max(proxy.safeAreaInsets.bottom, 4)
            let bottomPanelBottomPadding = max(bottomSafeInset - adjustmentToControlsSpacing, 0)
            let manualPreviewBottomInset = manualControlsHeight + controlsToShutterSpacing + shutterBarHeight + bottomPanelBottomPadding
            let manualBottomPanelHeight = manualAdjustmentHeight + adjustmentToControlsSpacing + manualPreviewBottomInset
            let presetBottomInset = colorPresetStripHeight + colorPresetToShutterSpacing + shutterBarHeight + bottomPanelBottomPadding
            let previewTopInset = topSafeInset + topBarHeight
            let previewBottomInset = isShowingColorPresets ? presetBottomInset : manualPreviewBottomInset
            let previewFrame = CGRect(
                x: 0,
                y: previewTopInset,
                width: proxy.size.width,
                height: max(proxy.size.height - previewTopInset - previewBottomInset, 0)
            )

            ZStack {
                Color.black

                CameraPreviewSurface(session: camera.session)
                    .saturation(camera.selectedColorPreset.saturation)
                    .contrast(camera.selectedColorPreset.contrast)
                    .brightness(camera.selectedColorPreset.brightness)
                    .colorMultiply(camera.selectedColorPreset.colorMultiply)
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

                    VStack(spacing: adjustmentToControlsSpacing) {
                        if isShowingColorPresets {
                            VStack(spacing: colorPresetToShutterSpacing) {
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

                                CameraShutterBar(
                                    isShowingColorPresets: isShowingColorPresets,
                                    onCapture: capturePhoto,
                                    onToggleColorPresets: toggleColorPresets
                                )
                                .frame(height: shutterBarHeight)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.horizontal, CameraUIConstants.screenHorizontalPadding)
                            .padding(.bottom, bottomPanelBottomPadding)
                            .background(Color.black)
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                        } else {
                            manualAdjustmentPanel
                                .frame(height: manualAdjustmentHeight, alignment: .center)

                            VStack(spacing: controlsToShutterSpacing) {
                                CameraManualControlsBar(
                                    values: temporaryManualDisplayValues,
                                    selectedControl: selectedManualControl,
                                    onSelect: selectManualControl
                                )
                                    .frame(height: manualControlsHeight)

                                CameraShutterBar(
                                    isShowingColorPresets: isShowingColorPresets,
                                    onCapture: capturePhoto,
                                    onToggleColorPresets: toggleColorPresets
                                )
                                .frame(height: shutterBarHeight)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.horizontal, CameraUIConstants.screenHorizontalPadding)
                            .padding(.bottom, bottomPanelBottomPadding)
                            .background(Color.black)
                            .transition(.opacity)
                        }
                    }
                    .frame(height: isShowingColorPresets ? presetBottomInset : manualBottomPanelHeight, alignment: .bottom)
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

    private func capturePhoto() {
        camera.capturePhoto { photoData in
            guard let photoData else {
                return
            }

            onPhotoCaptured(photoData)
            dismiss()
        }
    }

    private func toggleColorPresets() {
        withAnimation(.easeInOut(duration: 0.2)) {
            isShowingColorPresets.toggle()
        }
    }

    private func selectManualControl(_ control: CameraManualControl) {
        withAnimation(.easeInOut(duration: 0.16)) {
            selectedManualControl = selectedManualControl == control ? nil : control
        }
    }

    @ViewBuilder
    private var manualAdjustmentPanel: some View {
        switch selectedManualControl {
        case .exposure:
            CameraAdjustmentSlider(
                value: Binding(
                    get: { Double(camera.currentExposureBias) },
                    set: { camera.setExposureBias(Float($0)) }
                ),
                lowerLabel: "-3.0",
                centerLabel: camera.displayValue(for: .exposure),
                upperLabel: "3.0",
                bounds: -3...3,
                step: 0.1
            )
            .transition(.opacity)
        case .shutterSpeed:
            CameraAdjustmentSlider(
                value: $temporaryShutterSpeedValue,
                lowerLabel: "1/1000",
                centerLabel: shutterSpeedDisplayValue,
                upperLabel: "1/4",
                bounds: 0...1,
                step: 0.05
            )
            .transition(.opacity)
        case .iso:
            CameraAdjustmentSlider(
                value: $temporaryISOValue,
                lowerLabel: "50",
                centerLabel: isoDisplayValue,
                upperLabel: "6400",
                bounds: 50...6400,
                step: 10
            )
            .transition(.opacity)
        case .whiteBalance:
            CameraTemporaryWhiteBalancePresetPanel(
                selectedPreset: temporaryWhiteBalancePreset,
                onSelect: { preset in
                    withAnimation(.easeInOut(duration: 0.16)) {
                        temporaryWhiteBalancePreset = preset
                    }
                }
            )
            .transition(.opacity)
        case nil:
            Color.clear
        }
    }

    private var temporaryManualDisplayValues: [CameraManualControl: String] {
        [
            .exposure: camera.displayValue(for: .exposure),
            .shutterSpeed: shutterSpeedDisplayValue,
            .iso: isoDisplayValue,
            .whiteBalance: whiteBalanceDisplayValue
        ]
    }

    private var shutterSpeedDisplayValue: String {
        let shutterSpeedLabels = ["1/1000", "1/500", "1/250", "1/125", "1/60", "1/30", "1/4"]
        let index = min(
            max(Int((temporaryShutterSpeedValue * Double(shutterSpeedLabels.count - 1)).rounded()), 0),
            shutterSpeedLabels.count - 1
        )

        return shutterSpeedLabels[index]
    }

    private var isoDisplayValue: String {
        "\(Int(temporaryISOValue.rounded()))"
    }

    private var whiteBalanceDisplayValue: String {
        temporaryWhiteBalancePreset.shortLabel
    }
}

#Preview {
    MediaCameraView()
}

private struct CameraAdjustmentSlider: View {
    @Binding var value: Double
    let lowerLabel: String
    let centerLabel: String
    let upperLabel: String
    let bounds: ClosedRange<Double>
    let step: Double?

    init(
        value: Binding<Double>,
        lowerLabel: String,
        centerLabel: String,
        upperLabel: String,
        bounds: ClosedRange<Double>,
        step: Double? = nil
    ) {
        self._value = value
        self.lowerLabel = lowerLabel
        self.centerLabel = centerLabel
        self.upperLabel = upperLabel
        self.bounds = bounds
        self.step = step
    }

    var body: some View {
        VStack(spacing: 3) {
            HStack {
                Text(lowerLabel)
                    .frame(width: 52, alignment: .leading)

                Spacer()

                Text(centerLabel)
                    .foregroundStyle(CameraUIConstants.accentColor)
                    .frame(minWidth: 58)

                Spacer()

                Text(upperLabel)
                    .frame(width: 52, alignment: .trailing)
            }
            .font(.system(size: 11, weight: .semibold))
            .foregroundStyle(.white.opacity(0.72))

            if let step {
                Slider(value: $value, in: bounds, step: step)
                    .tint(CameraUIConstants.accentColor)
            } else {
                Slider(value: $value, in: bounds)
                    .tint(CameraUIConstants.accentColor)
            }
        }
        .padding(.horizontal, CameraUIConstants.screenHorizontalPadding)
        .padding(.vertical, 5)
        .background(Color.black.opacity(0.24))
    }
}

private enum CameraTemporaryWhiteBalancePreset: String, CaseIterable, Identifiable {
    case auto
    case incandescent
    case fluorescent
    case daylight
    case cloudy

    var id: String { rawValue }

    var shortLabel: String {
        switch self {
        case .auto:
            "AWB"
        case .incandescent:
            "텅스텐"
        case .fluorescent:
            "형광등"
        case .daylight:
            "태양광"
        case .cloudy:
            "흐림"
        }
    }

    var iconSystemName: String {
        switch self {
        case .auto:
            "camera.aperture"
        case .incandescent:
            "lightbulb.fill"
        case .fluorescent:
            "lamp.desk.fill"
        case .daylight:
            "sun.max.fill"
        case .cloudy:
            "cloud.fill"
        }
    }

    var iconColor: Color {
        switch self {
        case .auto:
            CameraUIConstants.accentColor
        case .incandescent:
            Color.orange
        case .fluorescent:
            Color.cyan
        case .daylight:
            Color.yellow
        case .cloudy:
            Color.blue.opacity(0.85)
        }
    }
}

private struct CameraTemporaryWhiteBalancePresetPanel: View {
    let selectedPreset: CameraTemporaryWhiteBalancePreset
    let onSelect: (CameraTemporaryWhiteBalancePreset) -> Void

    var body: some View {
        HStack(spacing: 0) {
            ForEach(CameraTemporaryWhiteBalancePreset.allCases) { preset in
                Button {
                    onSelect(preset)
                } label: {
                    VStack(spacing: 6) {
                        if preset == .auto {
                            Text("AWB")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundStyle(isSelected(preset) ? CameraUIConstants.accentColor : .white)
                        } else {
                            Image(systemName: preset.iconSystemName)
                                .font(.system(size: 18, weight: .medium))
                                .foregroundStyle(isSelected(preset) ? preset.iconColor : .white)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 34)
                    .padding(.bottom, 4)
                    .overlay(alignment: .bottom) {
                        Rectangle()
                            .fill(isSelected(preset) ? CameraUIConstants.accentColor : .clear)
                            .frame(height: 2)
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .frame(maxWidth: .infinity)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, CameraUIConstants.screenHorizontalPadding)
        .padding(.vertical, 5)
        .background(Color.black.opacity(0.24))
    }

    private func isSelected(_ preset: CameraTemporaryWhiteBalancePreset) -> Bool {
        selectedPreset == preset
    }
}
