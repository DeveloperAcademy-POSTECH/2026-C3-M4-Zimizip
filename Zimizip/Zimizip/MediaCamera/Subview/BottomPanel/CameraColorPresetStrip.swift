import SwiftUI

struct CameraColorPresetStrip: View {
    let selectedPreset: CameraColorPreset
    let contentRotation: Angle
    let onSelect: (CameraColorPreset) -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(CameraColorPreset.allCases) { preset in
                    Button {
                        onSelect(preset)
                    } label: {
                        VStack(alignment: .leading, spacing: 8) {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(
                                    LinearGradient(
                                        colors: preset.previewColors,
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 78, height: 96)
                                .overlay {
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(
                                            selectedPreset == preset
                                                ? CameraUIConstants.accentColor
                                                : Color.white.opacity(0.18),
                                            lineWidth: selectedPreset == preset ? 3 : 1
                                        )
                                }

                            Text(preset.title)
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundStyle(selectedPreset == preset ? CameraUIConstants.accentColor : .white)
                                .rotationEffect(contentRotation)
                        }
                        .frame(width: 78, alignment: .leading)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
        }
        .frame(height: 132)
    }
}
