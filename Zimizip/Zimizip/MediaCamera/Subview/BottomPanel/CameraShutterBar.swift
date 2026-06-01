import SwiftUI

struct CameraShutterBar: View {
    let isShowingColorPresets: Bool
    let onClose: () -> Void
    let onCapture: () -> Void
    let onToggleColorPresets: () -> Void

    var body: some View {
        HStack {
            Button {
                onClose()
            } label: {
                Text("닫기")
                    .font(.system(size: 14.5, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 68, alignment: .leading)
            }
            .buttonStyle(.plain)

            Spacer()

            Button {
                onCapture()
            } label: {
                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.24), lineWidth: 6)
                        .frame(width: 74, height: 74)

                    Circle()
                        .fill(Color.white)
                        .frame(width: 60, height: 60)
                }
            }
            .buttonStyle(.plain)

            Spacer()

            Button {
                onToggleColorPresets()
            } label: {
                CameraColorPresetButtonIcon(
                    isSelected: isShowingColorPresets
                )
                    .frame(width: 68, height: 36, alignment: .trailing)
            }
            .buttonStyle(.plain)
        }
    }
}

private struct CameraColorPresetButtonIcon: View {
    let isSelected: Bool

    var body: some View {
        ZStack {
            Circle()
                .stroke(isSelected ? CameraUIConstants.accentColor : Color.white, lineWidth: 1.6)
                .frame(width: 22, height: 22)

            HStack(spacing: 1.8) {
                ForEach(0..<4, id: \.self) { column in
                    VStack(spacing: 1.8) {
                        ForEach(0..<(column + 1), id: \.self) { _ in
                            Circle()
                                .fill(isSelected ? CameraUIConstants.accentColor : Color.white)
                                .frame(width: 2, height: 2)
                        }
                    }
                }
            }
            .offset(x: 2.5)
            .clipShape(Circle())
        }
    }
}
