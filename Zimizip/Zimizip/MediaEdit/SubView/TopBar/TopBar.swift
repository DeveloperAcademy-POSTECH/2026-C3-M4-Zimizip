import SwiftUI

struct TopBar: View {
    let title: String
    let nextButtonTitle: String
    let backButtonAction: () -> Void
    let nextButtonAction: () -> Void

    var titleFont: Font = .system(size: 17, weight: .bold)
    var titleColor: Color = .black
    var backButtonFont: Font = .system(size: 17, weight: .regular)
    var backButtonColor: Color = .black
    var nextButtonFont: Font = .system(size: 15, weight: .regular)
    var nextButtonBackgroundColor: Color = .blue
    var nextButtonForegroundColor: Color = .white
    var nextButtonSize = CGSize(width: 56, height: 34)
    var nextButtonCornerRadius: CGFloat = 17
    var horizontalPadding: CGFloat = 10
    var topPadding: CGFloat = 15
    var bottomPadding: CGFloat = 15
    var backgroundColor: Color = .clear

    var body: some View {
        HStack {
            Button {
                backButtonAction()
            } label: {
                Image(systemName: "chevron.left")
                    .font(backButtonFont)
                    .foregroundStyle(backButtonColor)
                    .frame(width: 44, height: 44)
            }
            .buttonStyle(.plain)
            
            Spacer()
            
            Text(title)
                .font(titleFont)
                .foregroundStyle(titleColor)
            
            Spacer()
            
            Button {
                nextButtonAction()
            } label: {
                Text(nextButtonTitle)
                    .font(nextButtonFont)
                    .foregroundStyle(nextButtonForegroundColor)
                    .frame(width: nextButtonSize.width, height: nextButtonSize.height)
                    .background(nextButtonBackgroundColor)
                    .clipShape(RoundedRectangle(cornerRadius: nextButtonCornerRadius, style: .continuous))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, horizontalPadding)
        .padding(.top, topPadding)
        .padding(.bottom, bottomPadding)
        .background(backgroundColor)
    }
}

#Preview {
    TopBar(
        title: "사진 편집",
        nextButtonTitle: "다음",
        backButtonAction: {},
        nextButtonAction: {}
    )
}
