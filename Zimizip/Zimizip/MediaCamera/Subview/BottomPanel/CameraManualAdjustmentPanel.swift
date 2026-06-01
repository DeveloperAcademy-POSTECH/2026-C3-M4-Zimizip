import SwiftUI

struct CameraManualAdjustmentPanel: View {
    let selectedControl: CameraManualControl
    let exposureBias: Float
    let currentISO: Float?
    let isoRange: ClosedRange<Float>
    let currentShutterDuration: Double?
    let shutterRange: ClosedRange<Double>
    let whiteBalancePreset: CameraWhiteBalancePreset
    let onExposureChange: (Float) -> Void
    let onSetISOAuto: () -> Void
    let onISOChange: (Float) -> Void
    let onSetShutterAuto: () -> Void
    let onShutterChange: (Double) -> Void
    let onWhiteBalanceChange: (CameraWhiteBalancePreset) -> Void
    private let isoDisplayRange: ClosedRange<Double> = 50...6400
    private let manualSliderStart: Double = 0.06

    var body: some View {
        Group {
            switch selectedControl {
            case .exposure:
                simpleSliderPanel(
                    minimumLabel: String(format: "%.1f", -3.0),
                    maximumLabel: String(format: "%.1f", 3.0),
                    value: Binding(
                        get: { Double(exposureBias) },
                        set: { onExposureChange(Float($0)) }
                    ),
                    range: -3.0...3.0
                )
            case .shutterSpeed:
                autoValuePanel(
                    isAuto: currentShutterDuration == nil,
                    autoLabel: "Auto",
                    minimumLabel: CameraPreviewModel.shutterDisplayString(for: shutterRange.lowerBound),
                    maximumLabel: CameraPreviewModel.shutterDisplayString(for: shutterRange.upperBound),
                    currentValueLabel: currentShutterDuration.map(CameraPreviewModel.shutterDisplayString(for:)) ?? "AUTO",
                    sliderValue: Binding(
                        get: { currentShutterDuration.map(normalizedShutterValue(for:)) ?? 0 },
                        set: { newValue in
                            onShutterChange(denormalizedShutterValue(for: newValue))
                        }
                    ),
                    onAuto: onSetShutterAuto
                )
            case .iso:
                autoValuePanel(
                    isAuto: currentISO == nil,
                    autoLabel: "Auto",
                    minimumLabel: "50",
                    maximumLabel: "6400",
                    currentValueLabel: currentISO.map { "\(Int($0.rounded()))" } ?? "AUTO",
                    sliderValue: Binding(
                        get: { currentISO.map(normalizedISOValue(for:)) ?? 0 },
                        set: { newValue in
                            onISOChange(denormalizedISOValue(for: newValue))
                        }
                    ),
                    onAuto: onSetISOAuto
                )
            case .whiteBalance:
                whiteBalancePanel
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func simpleSliderPanel(
        minimumLabel: String,
        maximumLabel: String,
        value: Binding<Double>,
        range: ClosedRange<Double>
    ) -> some View {
        VStack(spacing: 8) {
            HStack {
                Text(minimumLabel)
                    .foregroundStyle(.white)

                Spacer()

                Text(maximumLabel)
                    .foregroundStyle(.white)
            }
            .font(.system(size: 11, weight: .medium))

            Slider(
                value: value,
                in: range
            )
            .tint(.white)
        }
    }

    private var whiteBalancePanel: some View {
        HStack(spacing: 0) {
            ForEach(CameraWhiteBalancePreset.allCases) { preset in
                Button {
                    onWhiteBalanceChange(preset)
                } label: {
                    VStack(spacing: 6) {
                        if preset == .auto {
                            Text("AWB")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundStyle(
                                    whiteBalancePreset == preset ? CameraUIConstants.accentColor : .white
                                )
                        } else {
                            Image(systemName: preset.iconSystemName)
                                .font(.system(size: 18, weight: .medium))
                                .foregroundStyle(
                                    whiteBalancePreset == preset ? preset.iconColor : .white
                                )
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 34)
                    .padding(.bottom, 4)
                    .overlay(alignment: .bottom) {
                        Rectangle()
                            .fill(whiteBalancePreset == preset ? CameraUIConstants.accentColor : .clear)
                            .frame(height: 2)
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func autoValuePanel(
        isAuto: Bool,
        autoLabel: String,
        minimumLabel: String,
        maximumLabel: String,
        currentValueLabel: String,
        sliderValue: Binding<Double>,
        onAuto: @escaping () -> Void
    ) -> some View {
        VStack(spacing: 8) {
            HStack {
                Text(autoLabel)
                    .foregroundStyle(.white)

                Spacer()
            }
            .font(.system(size: 11, weight: .medium))

            HStack(spacing: 8) {
                Button {
                    onAuto()
                } label: {
                    Circle()
                        .strokeBorder(Color.white, lineWidth: 2)
                        .background(
                            Circle()
                                .fill(isAuto ? CameraUIConstants.accentColor : .clear)
                                .padding(4)
                        )
                        .frame(width: 24, height: 24)
                }
                .buttonStyle(.plain)

                SliderLeadMarker()

                VStack(spacing: 6) {
                    HStack(spacing: 0) {
                        Text(minimumLabel)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        Text(currentValueLabel)
                            .foregroundStyle(CameraUIConstants.accentColor)
                            .frame(maxWidth: .infinity, alignment: .center)

                        Text(maximumLabel)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                    .font(.system(size: 11, weight: .medium))

                    Slider(
                        value: sliderValue,
                        in: 0...1
                    )
                    .tint(.white)
                }
            }
        }
    }

    private func normalizedISOValue(for iso: Float) -> Double {
        let lower = isoDisplayRange.lowerBound
        let upper = isoDisplayRange.upperBound

        guard upper > lower else { return 0 }
        let clamped = min(max(Double(iso), lower), upper)
        let progress = (clamped - lower) / (upper - lower)
        return manualSliderStart + progress * (1 - manualSliderStart)
    }

    private func denormalizedISOValue(for value: Double) -> Float {
        let lower = isoDisplayRange.lowerBound
        let upper = isoDisplayRange.upperBound
        let clampedValue = min(max(value, manualSliderStart), 1)
        let normalized = (clampedValue - manualSliderStart) / (1 - manualSliderStart)
        return Float(lower + normalized * (upper - lower))
    }

    private func normalizedShutterValue(for duration: Double) -> Double {
        let lower = shutterRange.lowerBound
        let upper = shutterRange.upperBound

        guard upper > lower else { return 0 }

        let minLog = log10(lower)
        let maxLog = log10(upper)
        let currentLog = log10(duration)
        let progress = (currentLog - minLog) / (maxLog - minLog)
        return manualSliderStart + progress * (1 - manualSliderStart)
    }

    private func denormalizedShutterValue(for value: Double) -> Double {
        let lower = shutterRange.lowerBound
        let upper = shutterRange.upperBound
        guard upper > lower else { return lower }

        let minLog = log10(lower)
        let maxLog = log10(upper)
        let clampedValue = min(max(value, manualSliderStart), 1)
        let progress = (clampedValue - manualSliderStart) / (1 - manualSliderStart)
        let interpolated = minLog + progress * (maxLog - minLog)
        return pow(10, interpolated)
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
