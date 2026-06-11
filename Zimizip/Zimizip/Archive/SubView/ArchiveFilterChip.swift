import SwiftUI

struct ArchiveFilterChip: View {
    let icon: String
    let title: String
    let isSelected: Bool

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .bold))

            Text(title)
                .font(Font.custom("Pretendard-Bold", size: 16))
                .fixedSize(horizontal: true, vertical: false)
        }
        .foregroundStyle(isSelected ? Color.brandPrimary : Color.gray450)
        .frame(height: 36)
        .padding(.horizontal, 12)
        .background(isSelected ? Color.brandPrimary.opacity(0.18) : Color.gray50)
        .overlay {
            if !isSelected {
                Capsule()
                    .stroke(Color.gray200, lineWidth: 1)
            }
        }
        .clipShape(Capsule())
    }
}

#Preview {
    HStack {
        ArchiveFilterChip(icon: "play.square.fill", title: "리액션", isSelected: true)
        ArchiveFilterChip(icon: "square.stack.3d.up.fill", title: "서프라이즈 카드", isSelected: false)
    }
    .padding()
    .background(Color.backgroundPrimary)
}
