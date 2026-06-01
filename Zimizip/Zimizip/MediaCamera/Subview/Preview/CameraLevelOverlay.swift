import SwiftUI

struct CameraLevelOverlay: View {
    var body: some View {
        GeometryReader { geometry in
            let centerY = geometry.size.height / 2
            let centerX = geometry.size.width / 2

            Path { path in
                path.move(to: CGPoint(x: 0, y: centerY))
                path.addLine(to: CGPoint(x: geometry.size.width, y: centerY))
                path.move(to: CGPoint(x: centerX, y: centerY - 18))
                path.addLine(to: CGPoint(x: centerX, y: centerY + 18))
            }
            .stroke(Color.white.opacity(0.45), lineWidth: 1.0)
        }
        .allowsHitTesting(false)
    }
}
