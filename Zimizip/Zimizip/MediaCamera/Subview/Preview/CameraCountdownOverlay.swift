import SwiftUI

struct CameraCountdownOverlay: View {
    let value: Int

    var body: some View {
        ZStack {
            Circle()
                .fill(Color.black.opacity(0.48))
                .frame(width: 112, height: 112)

            Text("\(value)")
                .font(.system(size: 52, weight: .bold))
                .foregroundStyle(.white)
        }
        .allowsHitTesting(false)
    }
}
