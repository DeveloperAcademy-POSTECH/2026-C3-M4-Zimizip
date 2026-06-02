import SwiftUI

struct OptionItemView: View {
    enum Style: Equatable {
        case mediaSource
        case revealTiming
    }

    let icon: String
    let title: String
    let subtitle: String
    var isSelected = false
    var style: Style = .mediaSource

    var body: some View {
        HStack(spacing: 0) {
            Circle()
                .fill(circleColor)
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
                    .foregroundStyle(Color(red: 36 / 255, green: 33 / 255, blue: 31 / 255))
                    .lineLimit(1)
                    .layoutPriority(1)

                Text(subtitle)
                    .font(.system(size: 14))
                    .foregroundStyle(subtitleColor)
                    .lineSpacing(style == .revealTiming ? 2 : 0)
            }
            .padding(.leading, 24)

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 20, weight: .medium))
                .foregroundStyle(chevronColor)
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

    private var circleColor: Color {
        switch style {
        case .mediaSource:
            isSelected
                ? Color(red: 218 / 255, green: 207 / 255, blue: 200 / 255)
                : Color(red: 239 / 255, green: 231 / 255, blue: 225 / 255)
        case .revealTiming:
            Color(red: 1, green: 239 / 255, blue: 229 / 255)
        }
    }

    private var subtitleColor: Color {
        switch style {
        case .mediaSource:
            Color(red: 129 / 255, green: 121 / 255, blue: 115 / 255)
        case .revealTiming:
            Color(red: 91 / 255, green: 83 / 255, blue: 78 / 255)
        }
    }

    private var chevronColor: Color {
        switch style {
        case .mediaSource:
            Color(red: 36 / 255, green: 33 / 255, blue: 31 / 255)
        case .revealTiming:
            Color(red: 215 / 255, green: 206 / 255, blue: 200 / 255)
        }
    }

    private var borderColor: Color {
        switch style {
        case .mediaSource:
            Color(red: 215 / 255, green: 206 / 255, blue: 200 / 255)
        case .revealTiming:
            Color(red: 227 / 255, green: 218 / 255, blue: 212 / 255)
        }
    }

    private var backgroundColor: Color {
        guard style == .mediaSource, isSelected else {
            return .clear
        }

        return Color(red: 239 / 255, green: 228 / 255, blue: 220 / 255)
    }
}

#Preview {
    OptionItemView(
        icon: "CalendarClock",
        title: "나중에 전하기",
        subtitle: "앱에 저장해두고\n원하는 순간에 열어요",
        style: .revealTiming
    )
    .padding()
}
