import SwiftUI

struct PermissionSettingsPrompt: View {
    let title: String
    let message: String
    let onMoveToSettings: () -> Void
    let onLater: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 22) {
            VStack(alignment: .leading, spacing: 12) {
                Text(title)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(Color(red: 36 / 255, green: 33 / 255, blue: 31 / 255))
                    .fixedSize(horizontal: false, vertical: true)

                Text(message)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(Color(red: 36 / 255, green: 33 / 255, blue: 31 / 255))
                    .lineSpacing(3)
                    .fixedSize(horizontal: false, vertical: true)
            }

            VStack(spacing: 10) {
                Button(action: onMoveToSettings) {
                    Text("설정으로 이동하기")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.brandSecondary)
                        .clipShape(RoundedRectangle(cornerRadius: 25))
                }
                .buttonStyle(.plain)

                Button(action: onLater) {
                    Text("나중에 하기")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(Color(red: 36 / 255, green: 33 / 255, blue: 31 / 255))
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color(red: 221 / 255, green: 221 / 255, blue: 221 / 255))
                        .clipShape(RoundedRectangle(cornerRadius: 25))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 22)
        .padding(.vertical, 24)
        .frame(maxWidth: 312)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 30))
        .shadow(color: .black.opacity(0.14), radius: 24, x: 0, y: 16)
    }
}

#Preview {
    PermissionSettingsPrompt(
        title: "서프라이즈 사진 촬영을 위해 권한이\n필요합니다",
        message: "권한을 허용하면 앱에서 서프라이즈\n사진을 바로 촬영할 수 있습니다. ‘설정’에서 카메라 접근을 허용해 주십시오.",
        onMoveToSettings: {},
        onLater: {}
    )
}
