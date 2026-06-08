import SwiftUI

struct MainEditBottomPanelActionBar: View {
    let title: String
    let cancelAction: () -> Void
    let confirmAction: () -> Void

    var body: some View {
        HStack(alignment: .top) {
            Button(action: cancelAction) {
                Image(MainEditLayout.bottomPanelCancelIconName)
                    .resizable()
                    .renderingMode(.template)
                    .foregroundStyle(Color.baseWhite)
                    .scaledToFit()
                    .frame(
                        width: MainEditLayout.bottomPanelActionIconSize,
                        height: MainEditLayout.bottomPanelActionIconSize
                    )
            }
            .buttonStyle(.plain)

            Spacer(minLength: 0)

            Text(title)
                .font(.custom("Pretendard", size: MainEditLayout.bottomPanelActionTitleFontSize).weight(.semibold))
                .foregroundStyle(Color.baseWhite)

            Spacer(minLength: 0)

            Button(action: confirmAction) {
                Image(MainEditLayout.bottomPanelConfirmIconName)
                    .resizable()
                    .renderingMode(.template)
                    .foregroundStyle(Color.brandPrimary)
                    .scaledToFit()
                    .frame(
                        width: MainEditLayout.bottomPanelActionIconSize,
                        height: MainEditLayout.bottomPanelActionIconSize
                    )
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, MainEditLayout.bottomPanelActionHorizontalPadding)
        .padding(.top, 0)
        .padding(.bottom, MainEditLayout.bottomPanelActionBottomPadding)
        .background(MainEditLayout.bottomPanelBackgroundColor)
    }
}

#Preview {
    MainEditBottomPanelActionBar(
        title: MainEditLayout.filterPanelTitle,
        cancelAction: {},
        confirmAction: {}
    )
    .background(Color.black)
}
