import SwiftUI

struct CameraPermissionOverlay: View {
    let message: String?

    var body: some View {
        ZStack {
            Color.black.opacity(0.78)
                .ignoresSafeArea()

            VStack(spacing: 14) {
                Image(systemName: "camera.slash.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(.white)

                Text(message ?? "카메라 권한이 없어 preview를 표시할 수 없습니다.")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)
            }
        }
    }
}
