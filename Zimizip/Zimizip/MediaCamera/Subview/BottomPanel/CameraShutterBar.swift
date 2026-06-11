import SwiftUI

struct CameraShutterBar: View {
    let onCapture: () -> Void

    var body: some View {
        HStack {
            Color.clear
                .frame(width: 68, height: 36)

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

            Color.clear
                .frame(width: 68, height: 36)
        }
    }
}
