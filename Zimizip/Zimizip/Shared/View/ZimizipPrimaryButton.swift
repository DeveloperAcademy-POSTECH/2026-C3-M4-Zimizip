import SwiftUI

struct ZimizipPrimaryButton: View {
    let title: String
    var backgroundColor: Color = .brandPrimary
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(Font.custom("Pretendard-Bold", size: 16))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(backgroundColor)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .contentShape(RoundedRectangle(cornerRadius: 14))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ZimizipPrimaryButton(title: "다음") {}
}
