import SwiftUI

struct MainEditFilterActionBar: View {
    let cancelAction: () -> Void
    let confirmAction: () -> Void

    var body: some View {
        HStack(alignment: .top) {
            Button(action: cancelAction) {
                Image("close")
                    .resizable()
                    .renderingMode(.template)
                    .foregroundStyle(Color.baseWhite)
                    .scaledToFit()
                    .frame(
                        width: MainEditLayout.filterActionIconSize,
                        height: MainEditLayout.filterActionIconSize
                    )
            }
            .buttonStyle(.plain)

            Spacer(minLength: 0)

            Text("필터")
                .font(.custom("Pretendard", size: 16).weight(.semibold))
                .foregroundStyle(Color.baseWhite)

            Spacer(minLength: 0)

            Button(action: confirmAction) {
                Image("check")
                    .resizable()
                    .renderingMode(.template)
                    .foregroundStyle(Color.brandPrimary)
                    .scaledToFit()
                    .frame(
                        width: MainEditLayout.filterActionIconSize,
                        height: MainEditLayout.filterActionIconSize
                    )
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, MainEditLayout.filterActionBarHorizontalPadding)
        .padding(.top, 0)
        .padding(.bottom, MainEditLayout.filterActionBarBottomPadding)
        .background(MainEditLayout.panelBackgroundColor)
    }
}

#Preview {
    MainEditFilterActionBar(
        cancelAction: {},
        confirmAction: {}
    )
    .background(Color.black)
}
