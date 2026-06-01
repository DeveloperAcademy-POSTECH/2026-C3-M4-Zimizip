import SwiftUI

struct CameraFilteredPreviewOverlay: View {
    let cgImage: CGImage

    var body: some View {
        Image(decorative: cgImage, scale: 1.0)
            .resizable()
            .scaledToFill()
            .ignoresSafeArea()
            .allowsHitTesting(false)
    }
}
