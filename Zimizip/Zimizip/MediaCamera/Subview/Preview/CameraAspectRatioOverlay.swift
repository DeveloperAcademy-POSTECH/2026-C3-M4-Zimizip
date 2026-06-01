import SwiftUI

struct CameraAspectRatioOverlay: View {
    var body: some View {
        Rectangle()
            .stroke(Color.white.opacity(0.35), lineWidth: 1.0)
        .allowsHitTesting(false)
    }
}
