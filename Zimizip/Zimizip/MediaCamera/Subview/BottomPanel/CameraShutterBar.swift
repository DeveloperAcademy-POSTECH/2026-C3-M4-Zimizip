import SwiftUI

struct CameraShutterBar: View {
    var body: some View {
        HStack {
            Color.clear
                .frame(width: 68, height: 36)

            Spacer()

            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.24), lineWidth: 6)
                    .frame(width: 74, height: 74)

                Circle()
                    .fill(Color.white)
                    .frame(width: 60, height: 60)
            }

            Spacer()

            CameraPalettePlaceholderIcon()
                .frame(width: 68, height: 36, alignment: .trailing)
        }
    }
}

private struct CameraPalettePlaceholderIcon: View {
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.white, lineWidth: 1.6)
                .frame(width: 22, height: 22)

            HStack(spacing: 1.8) {
                ForEach(0..<4, id: \.self) { column in
                    VStack(spacing: 1.8) {
                        ForEach(0..<(column + 1), id: \.self) { _ in
                            Circle()
                                .fill(Color.white)
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
