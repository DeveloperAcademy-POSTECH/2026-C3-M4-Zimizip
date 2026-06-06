import SwiftUI

struct OptionItemView: View {
    let icon: String
    let title: String
    let subtitle: String
    var isSelected = false

    var body: some View {
        HStack(spacing: 0) {
            Circle()
                .fill(.primary100)
                .frame(width: 86, height: 86)
                .overlay {
                    Image(icon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 36, height: 36)
                }

            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(.text)
                    .lineLimit(1)
                    .layoutPriority(1)

                Text(subtitle)
                    .font(.system(size: 14))
                    .foregroundStyle(.gray400)
            }
            .padding(.leading, 24)

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 20, weight: .medium))
                .foregroundStyle(.gray250)
        }
        .padding(.horizontal, 16)
        .frame(height: 128)
        .background(backgroundColor)
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .stroke(borderColor, lineWidth: 1)
        }
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var borderColor: Color { isSelected ? .gray150 : .primary250 }

    private var backgroundColor: Color { isSelected ? .backgroundPrimary : .primary100 }
}

#Preview {
    OptionItemView(
        icon: "CalendarClock",
        title: "나중에 전하기",
        subtitle: "앱에 저장해두고\n원하는 순간에 열어요"
    )
    .padding()
}
