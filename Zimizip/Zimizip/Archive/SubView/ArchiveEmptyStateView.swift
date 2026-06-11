import SwiftUI

struct ArchiveEmptyStateView: View {
    let onPrepareTap: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Image("ArchiveEmptyCharacter")
                .resizable()
                .scaledToFit()
                .frame(width: 153, height: 178)

            VStack(spacing: 8) {
                Text("보관함이 비어있어요")
                    .font(Font.custom("Pretendard-Medium", size: 20))
                    .foregroundStyle(Color.textPrimary)

                Button(action: onPrepareTap) {
                    HStack(spacing: 4) {
                        Text("서프라이즈 준비하기")
                            .font(Font.custom("Pretendard-Bold", size: 20))

                        Image(systemName: "chevron.right")
                            .font(.system(size: 16, weight: .bold))
                    }
                    .foregroundStyle(Color.brandPrimary)
                }
                .buttonStyle(.plain)
            }
        }
        .frame(width: 204, height: 273)
    }
}

#Preview {
    ZStack {
        Color.backgroundPrimary
            .ignoresSafeArea()

        ArchiveEmptyStateView {}
    }
}
