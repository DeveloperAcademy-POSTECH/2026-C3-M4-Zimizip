import SwiftUI

struct TopBar: View {
    var title: String = "사진 꾸미기"
    var nextButtonTitle: String = "완료"
    let backButtonAction: () -> Void
    let nextButtonAction: () -> Void

    var titleFont: Font = .custom("Pretendard", size: 16).weight(.semibold)
    var titleColor: Color = .white
    var backButtonFont: Font = .system(size: MainEditLayout.backButtonIconSize, weight: .medium)
    var backButtonColor: Color = .white
    var nextButtonFont: Font = .custom("Pretendard", size: 16).weight(.bold)
    var nextButtonBackgroundColor: Color = .brandPrimary
    var nextButtonForegroundColor: Color = .white
    var nextButtonSize = CGSize(
        width: MainEditLayout.completeButtonWidth,
        height: MainEditLayout.topBarButtonHeight
    )
    var nextButtonCornerRadius: CGFloat = MainEditLayout.completeButtonCornerRadius
    var backgroundColor: Color = .black

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
        .padding(.horizontal, MainEditLayout.topBarHorizontalPadding)
        .background(backgroundColor)
    }
}

#Preview {
    TopBar(
        backButtonAction: {},
        nextButtonAction: {}
    )
    .background(Color.black)
}
