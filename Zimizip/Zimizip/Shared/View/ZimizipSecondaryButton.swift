import SwiftUI

struct ZimizipSecondaryButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(title, action: action)
            .font(Font.custom("Pretendard-Bold", size: 16))
            .foregroundStyle(.primary)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(.white)
            .overlay {
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color(.primary), lineWidth: 1)
            }
            .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

#Preview {
    ZimizipSecondaryButton(title: "홈 가기") {}
}
