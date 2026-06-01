import SwiftUI

struct CameraQuickSettingsBar: View {
    let selectedQuickSetting: CameraQuickSetting
    let selectedAspectRatio: CameraAspectRatioOption
    let selectedTimer: CameraTimerOption
    let onSelect: (CameraQuickSetting) -> Void

    var body: some View {
        HStack(spacing: 14) {
            quickSettingButton(
                title: selectedAspectRatio.title,
                iconSystemName: nil,
                isSelected: selectedQuickSetting == .aspectRatio
            ) {
                onSelect(.aspectRatio)
            }

            quickSettingButton(
                title: selectedTimer.quickLabel,
                iconSystemName: "timer",
                isSelected: selectedQuickSetting == .timer
            ) {
                onSelect(.timer)
            }

            quickSettingButton(
                title: nil,
                iconSystemName: "square.grid.3x3",
                isSelected: selectedQuickSetting == .grid
            ) {
                onSelect(.grid)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 4)
        .background(Color.black.opacity(0.25))
        .clipShape(Capsule())
    }

    private func quickSettingButton(
        title: String?,
        iconSystemName: String?,
        isSelected: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button {
            action()
        } label: {
            VStack(spacing: 5) {
                HStack(spacing: 4) {
                    if let title {
                        Text(title)
                            .font(.system(size: 12, weight: .semibold))
                    }

                    if let iconSystemName {
                        Image(systemName: iconSystemName)
                            .font(.system(size: 12, weight: .medium))
                    }
                }
                .foregroundStyle(isSelected ? CameraUIConstants.accentColor : .white)

                Rectangle()
                    .fill(isSelected ? CameraUIConstants.accentColor : .white.opacity(0.15))
                    .frame(height: 2)
            }
        }
        .buttonStyle(.plain)
    }
}
