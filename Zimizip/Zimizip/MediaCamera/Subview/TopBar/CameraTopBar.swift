import SwiftUI

struct CameraTopBar: View {
    var body: some View {
        ZStack {
            HStack {
                topBarButton(systemName: "xmark")

                Spacer()

                topBarButton(systemName: "bolt.slash")
            }

            topBarButton(systemName: "camera.rotate")
        }
        .padding(.horizontal, 8)
        .padding(.bottom, 4)
    }

    private func topBarButton(systemName: String) -> some View {
        Image(systemName: systemName)
            .font(.system(size: 16, weight: .regular))
            .foregroundStyle(.white)
            .frame(width: 32, height: 32)
    }
}
