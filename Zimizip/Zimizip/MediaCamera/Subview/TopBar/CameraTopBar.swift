import SwiftUI

struct CameraTopBar: View {
    let isFlashEnabled: Bool
    let isQuickSettingsExpanded: Bool
    let onToggleFlash: () -> Void
    let onSwitchCamera: () -> Void
    let onToggleQuickSettings: () -> Void

    var body: some View {
        ZStack {
            HStack {
                topBarButton(systemName: isFlashEnabled ? "bolt.fill" : "bolt.slash", isActive: isFlashEnabled, action: onToggleFlash)

                Spacer()

                CameraMoreButton(isExpanded: isQuickSettingsExpanded, action: onToggleQuickSettings)
            }

            topBarButton(systemName: "camera.rotate", isActive: false, action: onSwitchCamera)
        }
        .padding(.horizontal, 8)
        .padding(.bottom, 4)
    }

    private func topBarButton(systemName: String, isActive: Bool, action: @escaping () -> Void) -> some View {
        Button {
            action()
        } label: {
            Image(systemName: systemName)
                .font(.system(size: 16, weight: .regular))
                .foregroundStyle(isActive ? CameraUIConstants.accentColor : .white)
                .frame(width: 32, height: 32)
        }
        .buttonStyle(.plain)
    }
}
