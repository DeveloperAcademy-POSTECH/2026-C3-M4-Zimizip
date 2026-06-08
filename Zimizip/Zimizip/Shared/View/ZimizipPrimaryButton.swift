import SwiftUI

struct ZimizipPrimaryButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(title, action: action)
            .font(Font.custom("Pretendard-Bold", size: 16))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(.brandPrimary)
            .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

#Preview {
    ZimizipPrimaryButton(title: "다음") {}
}
