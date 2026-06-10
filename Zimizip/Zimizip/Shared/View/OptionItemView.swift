import SwiftUI

struct OptionItemView: View {
    @Environment(\.isOptionItemPressed) private var isPressed

    let icon: String
    let title: String
    let subtitle: String

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
                    .foregroundStyle(.textPrimary)
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
        .background(Color.backgroundPrimary)
        .overlay {
            ZStack {
                if isPressed {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.primary100.opacity(0.65))
                }

                RoundedRectangle(cornerRadius: 12)
                    .stroke(borderColor, lineWidth: 1)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var borderColor: Color { isPressed ? .primary250 : .gray150 }
}

struct OptionItemButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .environment(\.isOptionItemPressed, configuration.isPressed)
    }
}

private struct OptionItemPressedEnvironmentKey: EnvironmentKey {
    static let defaultValue = false
}

private extension EnvironmentValues {
    var isOptionItemPressed: Bool {
        get { self[OptionItemPressedEnvironmentKey.self] }
        set { self[OptionItemPressedEnvironmentKey.self] = newValue }
    }
}

#Preview {
    OptionItemView(
        icon: "CalendarClock",
        title: "나중에 전하기",
        subtitle: "앱에 저장해두고\n원하는 순간에 열어요"
    )
    .padding()
}
