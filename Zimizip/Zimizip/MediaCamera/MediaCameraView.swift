//
//  MediaCameraView.swift
//  Zimizip
//
//  Created by Mason's Mac on 5/31/26.
//

import AVFoundation
import SwiftUI
import UIKit

struct MediaCameraView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var camera = CameraPreviewModel()
    @State private var isShowingColorPresets = false
    @State private var selectedManualControl: CameraManualControl?
    @State private var pendingShutterDuration: Double?
    @State private var pendingISO: Float?
    @State private var capturedPhotoData: Data?
    @State private var capturedPreviewFrame: CGRect = .zero
    @State private var isCapturedLandscape = false
    @State private var physicalDeviceOrientation: UIDeviceOrientation = .portrait
    @State private var captureOrientation: AVCaptureVideoOrientation = .portrait
    @State private var isShowingCameraPermissionSettingsPrompt = false
    @State private var didOpenCameraPermissionSettings = false

    let onPhotoCaptured: (Data, CGRect, Bool) -> Void

    init(onPhotoCaptured: @escaping (Data, CGRect, Bool) -> Void = { _, _, _ in }) {
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
                if let capturedPhotoData {
                    CapturedPhotoConfirmationView(
                        photoData: capturedPhotoData,
                        previewFrame: capturedPreviewFrame,
                        isLandscapeCapture: isCapturedLandscape,
                        onRetake: retakePhoto,
                        onUsePhoto: useCapturedPhoto
                    )
                } else {
                    cameraCaptureView(
                        previewFrame: previewFrame,
                        topSafeInset: topSafeInset,
                        topBarHeight: topBarHeight,
                        manualAdjustmentHeight: manualAdjustmentHeight,
                        manualControlsHeight: manualControlsHeight,
                        shutterBarHeight: shutterBarHeight,
                        controlRotation: controlRotation,
                        adjustmentToControlsSpacing: adjustmentToControlsSpacing,
                        controlsToShutterSpacing: controlsToShutterSpacing,
                        colorPresetToShutterSpacing: colorPresetToShutterSpacing,
                        bottomPanelBottomPadding: bottomPanelBottomPadding,
                        manualBottomPanelHeight: manualBottomPanelHeight,
                        presetBottomInset: presetBottomInset
                    )
                }

                if isShowingCameraPermissionSettingsPrompt {
                    CameraPermissionSettingsPrompt(
                        onMoveToSettings: moveToCameraPermissionSettings,
                        onLater: {
                            isShowingCameraPermissionSettingsPrompt = false
                        }
                    )
                    .transition(.opacity.combined(with: .scale(scale: 0.98)))
                }
            }
            .background(Color.black)
            .ignoresSafeArea()
        }
        .statusBarHidden(capturedPhotoData == nil)
        .task {
            startMonitoringDeviceOrientation()
            await requestCameraAccessFromPreview()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
            updateCaptureOrientation()
        }
        .onChange(of: scenePhase) { _, newPhase in
            guard newPhase == .active, didOpenCameraPermissionSettings else {
                return
            }

            Task {
                await refreshCameraAccessAfterReturningFromSettings()
            }
        }
        .onDisappear {
            camera.stopSession()
        }
        .onChange(of: camera.currentShutterDuration) { _, newValue in
            guard pendingShutterDuration != nil else {
                closeUnavailableExposurePanel()
                return
            }

            pendingShutterDuration = newValue.map {
                CameraPreviewModel.nearestStandardShutterDuration(
                    to: $0,
                    in: camera.shutterRange
                )
            }
            closeUnavailableExposurePanel()
        }
        .onChange(of: camera.currentISO) { _, newValue in
            guard pendingISO != nil else {
                closeUnavailableExposurePanel()
                return
            }

            pendingISO = newValue.map {
                CameraPreviewModel.nearestStandardISO(
                    to: $0,
                    in: camera.isoRange
                )
            }
            closeUnavailableExposurePanel()
        }
    }

    private func capturePhoto(previewFrame: CGRect) {
        guard camera.isPreviewSessionActive else {
            return
        }

        camera.capturePhoto(videoOrientation: captureOrientation) { photoData in
            guard let photoData else {
                return
            }

            capturedPreviewFrame = previewFrame
            isCapturedLandscape = physicalDeviceOrientation.isLandscape
            capturedPhotoData = photoData
        }
    }

    private func requestCameraAccessFromPreview() async {
        await Task.yield()

        let isGranted = await camera.requestCameraPreviewAccess()
        isShowingCameraPermissionSettingsPrompt = !isGranted
    }

    private func moveToCameraPermissionSettings() {
        guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else {
            return
        }

        didOpenCameraPermissionSettings = true
        UIApplication.shared.open(settingsURL) { didOpen in
            if !didOpen {
                Task { @MainActor in
                    didOpenCameraPermissionSettings = false
                }
            }
        }
    }

    private func refreshCameraAccessAfterReturningFromSettings() async {
        didOpenCameraPermissionSettings = false

        let isGranted = await camera.requestCameraPreviewAccess()
        isShowingCameraPermissionSettingsPrompt = !isGranted
    }

    private func retakePhoto() {
        capturedPhotoData = nil
        capturedPreviewFrame = .zero
        isCapturedLandscape = false
    }

    private func useCapturedPhoto() {
        guard let capturedPhotoData else {
            return
        }

        onPhotoCaptured(
            capturedPhotoData,
            capturedPreviewFrame,
            isCapturedLandscape
        )
        dismiss()
    }

    private func toggleColorPresets() {
        withAnimation(.easeInOut(duration: 0.2)) {
            isShowingColorPresets.toggle()
        }
    }

    private func selectManualControl(_ control: CameraManualControl) {
        guard !disabledManualControls.contains(control) else {
            return
        }

        withAnimation(.easeInOut(duration: 0.16)) {
            selectedManualControl = selectedManualControl == control ? nil : control
        }
    }

    private func resetManualControls() {
        pendingShutterDuration = nil
        pendingISO = nil
        camera.resetManualControls()
    }

    private func switchCamera() {
        pendingShutterDuration = nil
        pendingISO = nil
        camera.switchCamera()
    }

    private func closeUnavailableExposurePanel() {
        guard selectedManualControl == .exposure, !isExposureBiasAvailable else {
            return
        }

        withAnimation(.easeInOut(duration: 0.16)) {
            selectedManualControl = nil
        }
    }

    private func cameraCaptureView(
        previewFrame: CGRect,
        topSafeInset: CGFloat,
        topBarHeight: CGFloat,
        manualAdjustmentHeight: CGFloat,
        manualControlsHeight: CGFloat,
        shutterBarHeight: CGFloat,
        controlRotation: Angle,
        adjustmentToControlsSpacing: CGFloat,
        controlsToShutterSpacing: CGFloat,
        colorPresetToShutterSpacing: CGFloat,
        bottomPanelBottomPadding: CGFloat,
        manualBottomPanelHeight: CGFloat,
        presetBottomInset: CGFloat
    ) -> some View {
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
                        contentRotation: controlRotation,
                        onClose: {
                            dismiss()
                        },
                        onToggleFlash: {
                            camera.toggleFlash()
                        },
                        onSwitchCamera: {
                            switchCamera()
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
                                contentRotation: controlRotation,
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
                                contentRotation: controlRotation,
                                onCapture: { capturePhoto(previewFrame: previewFrame) },
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
                                disabledControls: disabledManualControls,
                                contentRotation: controlRotation,
                                onSelect: selectManualControl,
                                onReset: resetManualControls
                            )
                            .frame(height: manualControlsHeight)

                            CameraShutterBar(
                                isShowingColorPresets: isShowingColorPresets,
                                contentRotation: controlRotation,
                                onCapture: { capturePhoto(previewFrame: previewFrame) },
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
            let shutterDurations = CameraPreviewModel.standardShutterDurations(in: camera.shutterRange)
            let shutterSliderBounds = 0.0...max(Double(shutterDurations.count - 1), 0.0)

            CameraAutoAdjustmentSlider(
                isAuto: camera.currentShutterDuration == nil,
                autoLabel: "Auto",
                lowerLabel: shutterDurations.first.map(CameraPreviewModel.shutterDisplayString(for:)) ?? "AUTO",
                centerLabel: shutterDisplayValue,
                upperLabel: shutterDurations.last.map(CameraPreviewModel.shutterDisplayString(for:)) ?? "AUTO",
                value: Binding(
                    get: {
                        shutterSliderIndex(
                            for: pendingShutterDuration ?? camera.currentShutterDuration,
                            in: shutterDurations
                        )
                    },
                    set: { newValue in
                        let duration = shutterDuration(
                            at: newValue,
                            in: shutterDurations
                        )

                        pendingShutterDuration = duration
                        camera.setShutterDuration(duration)
                    }
                ),
                bounds: shutterSliderBounds,
                onAuto: {
                    pendingShutterDuration = nil
                    camera.setShutterAuto()
                }
            )
            .transition(.opacity)
        case .iso:
            let isoValues = CameraPreviewModel.standardISOs(in: camera.isoRange)
            let isoSliderBounds = 0.0...max(Double(isoValues.count - 1), 0.0)

            CameraAutoAdjustmentSlider(
                isAuto: camera.currentISO == nil,
                autoLabel: "Auto",
                lowerLabel: isoValues.first.map(CameraPreviewModel.isoDisplayString(for:)) ?? "AUTO",
                centerLabel: isoDisplayValue,
                upperLabel: isoValues.last.map(CameraPreviewModel.isoDisplayString(for:)) ?? "AUTO",
                value: Binding(
                    get: {
                        isoSliderIndex(
                            for: pendingISO ?? camera.currentISO,
                            in: isoValues
                        )
                    },
                    set: { newValue in
                        let iso = isoValue(
                            at: newValue,
                            in: isoValues
                        )

                        pendingISO = iso
                        camera.setISO(iso)
                    }
                ),
                bounds: isoSliderBounds,
                onAuto: {
                    pendingISO = nil
                    camera.setISOAuto()
                }
            )
            .transition(.opacity)
        case .whiteBalance:
            CameraWhiteBalancePresetPanel(
                selectedPreset: camera.whiteBalancePreset,
                onSelect: { preset in
                    withAnimation(.easeInOut(duration: 0.16)) {
                        camera.setWhiteBalancePreset(preset)
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
            .shutterSpeed: shutterDisplayValue,
            .iso: isoDisplayValue,
            .whiteBalance: camera.displayValue(for: .whiteBalance)
        ]
    }

    private var shutterDisplayValue: String {
        pendingShutterDuration.map(CameraPreviewModel.shutterDisplayString(for:)) ?? camera.displayValue(for: .shutterSpeed)
    }

    private var isoDisplayValue: String {
        pendingISO.map(CameraPreviewModel.isoDisplayString(for:)) ?? camera.displayValue(for: .iso)
    }

    private var disabledManualControls: Set<CameraManualControl> {
        isExposureBiasAvailable ? [] : [.exposure]
    }

    private var isExposureBiasAvailable: Bool {
        pendingShutterDuration == nil &&
            pendingISO == nil &&
            camera.currentShutterDuration == nil &&
            camera.currentISO == nil
    }

    private var controlRotation: Angle {
        switch physicalDeviceOrientation {
        case .landscapeLeft:
            return .degrees(90)
        case .landscapeRight:
            return .degrees(-90)
        default:
            return .zero
        }
    }

    private func startMonitoringDeviceOrientation() {
        UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        updateCaptureOrientation()
    }

    private func updateCaptureOrientation() {
        let deviceOrientation = UIDevice.current.orientation

        guard let orientation = AVCaptureVideoOrientation(deviceOrientation: deviceOrientation) else {
            return
        }

        physicalDeviceOrientation = deviceOrientation
        captureOrientation = orientation
    }

    private func shutterSliderIndex(
        for duration: Double?,
        in shutterDurations: [Double]
    ) -> Double {
        guard let duration, !shutterDurations.isEmpty else {
            return 0
        }

        let snappedDuration = CameraPreviewModel.nearestStandardShutterDuration(
            to: duration,
            in: camera.shutterRange
        )

        let index = shutterDurations.enumerated().min { lhs, rhs in
            abs(log10(lhs.element) - log10(snappedDuration)) < abs(log10(rhs.element) - log10(snappedDuration))
        }?.offset ?? 0

        return Double(index)
    }

    private func shutterDuration(
        at index: Double,
        in shutterDurations: [Double]
    ) -> Double {
        guard !shutterDurations.isEmpty else {
            return camera.shutterRange.lowerBound
        }

        let roundedIndex = Int(index.rounded())
        let clampedIndex = min(max(roundedIndex, 0), shutterDurations.count - 1)
        return shutterDurations[clampedIndex]
    }

    private func isoSliderIndex(
        for iso: Float?,
        in isoValues: [Float]
    ) -> Double {
        guard let iso, !isoValues.isEmpty else {
            return 0
        }

        let snappedISO = CameraPreviewModel.nearestStandardISO(
            to: iso,
            in: camera.isoRange
        )

        let index = isoValues.enumerated().min { lhs, rhs in
            abs(log10(Double(lhs.element)) - log10(Double(snappedISO))) < abs(log10(Double(rhs.element)) - log10(Double(snappedISO)))
        }?.offset ?? 0

        return Double(index)
    }

    private func isoValue(
        at index: Double,
        in isoValues: [Float]
    ) -> Float {
        guard !isoValues.isEmpty else {
            return camera.isoRange.lowerBound
        }

        let roundedIndex = Int(index.rounded())
        let clampedIndex = min(max(roundedIndex, 0), isoValues.count - 1)
        return isoValues[clampedIndex]
    }
}

#Preview {
    MediaCameraView()
}

private struct CameraPermissionSettingsPrompt: View {
    let onMoveToSettings: () -> Void
    let onLater: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 22) {
            VStack(alignment: .leading, spacing: 12) {
                Text("서프라이즈 사진 촬영을 위해 권한이\n필요합니다")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(Color(red: 36 / 255, green: 33 / 255, blue: 31 / 255))
                    .fixedSize(horizontal: false, vertical: true)

                Text("권한을 허용하면 앱에서 서프라이즈\n사진을 바로 촬영할 수 있습니다. ‘설정’에서 카메라 접근을 허용해 주십시오.")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(Color(red: 36 / 255, green: 33 / 255, blue: 31 / 255))
                    .lineSpacing(3)
                    .fixedSize(horizontal: false, vertical: true)
            }

            VStack(spacing: 10) {
                Button(action: onMoveToSettings) {
                    Text("설정으로 이동하기")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.brandSecondary)
                        .clipShape(RoundedRectangle(cornerRadius: 25))
                }
                .buttonStyle(.plain)

                Button(action: onLater) {
                    Text("나중에 하기")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(Color(red: 36 / 255, green: 33 / 255, blue: 31 / 255))
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color(red: 221 / 255, green: 221 / 255, blue: 221 / 255))
                        .clipShape(RoundedRectangle(cornerRadius: 25))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 22)
        .padding(.vertical, 24)
        .frame(maxWidth: 312)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 30))
        .shadow(color: .black.opacity(0.14), radius: 24, x: 0, y: 16)
    }
}

private extension AVCaptureVideoOrientation {
    init?(deviceOrientation: UIDeviceOrientation) {
        switch deviceOrientation {
        case .portrait:
            self = .portrait
        case .portraitUpsideDown:
            self = .portraitUpsideDown
        case .landscapeLeft:
            self = .landscapeRight
        case .landscapeRight:
            self = .landscapeLeft
        default:
            return nil
        }
    }
}

private struct CameraAdjustmentSlider: View {
    @Binding var value: Double
    let lowerLabel: String
    let centerLabel: String
    let upperLabel: String
    let bounds: ClosedRange<Double>
    let step: Double?
    let isEnabled: Bool

    init(
        value: Binding<Double>,
        lowerLabel: String,
        centerLabel: String,
        upperLabel: String,
        bounds: ClosedRange<Double>,
        step: Double? = nil,
        isEnabled: Bool = true
    ) {
        self._value = value
        self.lowerLabel = lowerLabel
        self.centerLabel = centerLabel
        self.upperLabel = upperLabel
        self.bounds = bounds
        self.step = step
        self.isEnabled = isEnabled
    }

    var body: some View {
        let controlOpacity = isEnabled ? 1.0 : 0.42

        VStack(spacing: 3) {
            HStack {
                Text(lowerLabel)
                    .frame(width: 52, alignment: .leading)

                Spacer()

                Text(centerLabel)
                    .foregroundStyle(CameraUIConstants.accentColor)
                    .frame(minWidth: 72)

                Spacer()

                Text(upperLabel)
                    .frame(width: 52, alignment: .trailing)
            }
            .font(.system(size: 11, weight: .semibold))
            .foregroundStyle(.white.opacity(0.72))

            if let step {
                Slider(value: $value, in: bounds, step: step)
                    .tint(CameraUIConstants.accentColor)
                    .disabled(!isEnabled)
            } else {
                Slider(value: $value, in: bounds)
                    .tint(CameraUIConstants.accentColor)
                    .disabled(!isEnabled)
            }
        }
        .opacity(controlOpacity)
        .padding(.horizontal, CameraUIConstants.screenHorizontalPadding)
        .padding(.vertical, 5)
        .background(Color.black.opacity(0.24))
    }
}

private struct CameraAutoAdjustmentSlider: View {
    let isAuto: Bool
    let autoLabel: String
    let lowerLabel: String
    let centerLabel: String
    let upperLabel: String
    @Binding var value: Double
    let bounds: ClosedRange<Double>
    let onAuto: () -> Void

    init(
        isAuto: Bool,
        autoLabel: String,
        lowerLabel: String,
        centerLabel: String,
        upperLabel: String,
        value: Binding<Double>,
        bounds: ClosedRange<Double>,
        onAuto: @escaping () -> Void
    ) {
        self.isAuto = isAuto
        self.autoLabel = autoLabel
        self.lowerLabel = lowerLabel
        self.centerLabel = centerLabel
        self.upperLabel = upperLabel
        self._value = value
        self.bounds = bounds
        self.onAuto = onAuto
    }

    var body: some View {
        let controlOpacity = isAuto ? 0.42 : 1.0

        VStack(spacing: 6) {
            HStack {
                Text(autoLabel)
                    .foregroundStyle(isAuto ? CameraUIConstants.accentColor : .white.opacity(0.72))
                    .fontWeight(isAuto ? .bold : .semibold)

                Spacer()
            }
            .font(.system(size: 11, weight: .semibold))

            HStack(spacing: 8) {
                Button {
                    onAuto()
                } label: {
                    Circle()
                        .strokeBorder(Color.white.opacity(0.9), lineWidth: 2)
                        .background(
                            Circle()
                                .fill(isAuto ? CameraUIConstants.accentColor : .clear)
                                .padding(4)
                        )
                        .frame(width: 24, height: 24)
                        .overlay {
                            if isAuto {
                                Circle()
                                    .stroke(CameraUIConstants.accentColor.opacity(0.35), lineWidth: 6)
                            }
                        }
                }
                .buttonStyle(.plain)

                SliderLeadMarker()
                    .opacity(controlOpacity)

                VStack(spacing: 3) {
                    HStack(spacing: 0) {
                        Text(lowerLabel)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        Text(centerLabel)
                            .foregroundStyle(CameraUIConstants.accentColor)
                            .frame(maxWidth: .infinity, alignment: .center)

                        Text(upperLabel)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.72))

                    Slider(value: $value, in: bounds, step: 1)
                        .tint(CameraUIConstants.accentColor)
                }
                .opacity(controlOpacity)
            }
        }
        .padding(.horizontal, CameraUIConstants.screenHorizontalPadding)
        .padding(.vertical, 3)
        .background(Color.black.opacity(0.24))
    }
}

private struct SliderLeadMarker: View {
    var body: some View {
        HStack(spacing: 4) {
            HStack(spacing: 2) {
                ForEach(0..<3, id: \.self) { _ in
                    Circle()
                        .fill(Color.white.opacity(0.82))
                        .frame(width: 2, height: 2)
                }
            }

            Capsule()
                .fill(Color.white.opacity(0.88))
                .frame(width: 2.5, height: 12)
        }
        .frame(width: 18, alignment: .leading)
    }
}

private struct CameraWhiteBalancePresetPanel: View {
    let selectedPreset: CameraWhiteBalancePreset
    let onSelect: (CameraWhiteBalancePreset) -> Void

    var body: some View {
        HStack(spacing: 0) {
            ForEach(CameraWhiteBalancePreset.allCases) { preset in
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

    private func isSelected(_ preset: CameraWhiteBalancePreset) -> Bool {
        selectedPreset == preset
    }
}
