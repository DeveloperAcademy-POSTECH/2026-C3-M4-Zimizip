import SwiftUI

struct MediaSourceOptionItemView: View {
    let icon: String
    let title: String
    let subtitle: String
    @State var isSelected: Bool

    var body: some View {
        HStack {
            Circle()
                .fill(isSelected ? Color(red: 218 / 255, green: 207 / 255, blue: 200 / 255) : Color(red: 239 / 255, green: 231 / 255, blue: 225 / 255))
                .frame(width: 86, height: 86)
                .overlay {
                    Image(systemName: icon)
                        .font(.system(size: 32))
                        .foregroundStyle(Color(red: 1, green: 0.42, blue: 0.13))
                }

            Spacer()
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(Color(red: 36 / 255, green: 33 / 255, blue: 31 / 255))
                    .lineLimit(1)
                    .layoutPriority(1)

                Text(subtitle)
                    .font(.system(size: 14))
                    .foregroundStyle(Color(red: 129 / 255, green: 121 / 255, blue: 115 / 255))
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 20, weight: .medium))
                .foregroundStyle(Color(red: 36 / 255, green: 33 / 255, blue: 31 / 255))
        }
        .padding(.horizontal, 16)
        .frame(height: 128)
        .background(isSelected ? Color(red: 239 / 255, green: 228 / 255, blue: 220 / 255) : .clear)
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(red: 215 / 255, green: 206 / 255, blue: 200 / 255), lineWidth: 1)
        }
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    MediaSourceOptionItemView(icon: "camera", title: "직접 촬영하기", subtitle: "서프라이즈를 할 순간을\n바로 담아보세요", isSelected: false)
}
