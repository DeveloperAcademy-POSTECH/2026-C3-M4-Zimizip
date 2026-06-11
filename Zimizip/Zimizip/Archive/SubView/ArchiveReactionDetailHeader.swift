import SwiftUI

struct ArchiveReactionDetailHeader: View {
    let title: String
    let reactionCount: Int
    let onBack: () -> Void

    var body: some View {
        HStack {
            Button(action: onBack) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 24, weight: .medium))
                    .foregroundStyle(Color.gray450)
                    .frame(width: 38, height: 38)
                    .background(Color.gray100)
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)

            Spacer(minLength: 0)

            VStack(spacing: 4) {
                Text(title)
                    .font(Font.custom("Pretendard-SemiBold", size: 16))
                    .foregroundStyle(Color.textPrimary)
                    .lineLimit(1)

                Text("동영상 \(reactionCount)개")
                    .font(Font.custom("Pretendard-Bold", size: 14))
                    .foregroundStyle(Color.textPrimary)
            }
            .frame(width: 200)

            Spacer(minLength: 0)

            Color.clear
                .frame(width: 38, height: 38)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    ArchiveReactionDetailHeader(
        title: "서프라이즈 프로젝트",
        reactionCount: 3,
        onBack: {}
    )
    .padding(.horizontal, 20)
    .background(Color.backgroundPrimary)
}
