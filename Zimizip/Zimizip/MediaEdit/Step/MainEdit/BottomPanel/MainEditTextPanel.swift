import SwiftUI

struct MainEditTextPanel: View {
    @State private var selectedTab: MainEditTextPanelTab = .font

    let cancelAction: () -> Void
    let confirmAction: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            tabBar

            contentPanel

            MainEditBottomPanelActionBar(
                title: MainEditLayout.textPanelTitle,
                cancelAction: cancelAction,
                confirmAction: confirmAction
            )
        }
        .background(MainEditLayout.bottomPanelBackgroundColor)
    }
}

private extension MainEditTextPanel {
    var tabBar: some View {
        HStack(alignment: .center, spacing: MainEditLayout.textMenuItemSpacing) {
            ForEach(MainEditTextPanelTab.allCases) { tab in
                Button {
                    selectedTab = tab
                } label: {
                    Text(tab.title)
                        .font(.custom("Pretendard", size: MainEditLayout.textMenuFontSize).weight(tab == selectedTab ? .semibold : .bold))
                        .foregroundStyle(tab == selectedTab ? Color.brandPrimary : Color.baseWhite)
                }
                .buttonStyle(.plain)
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, MainEditLayout.textMenuHorizontalPadding)
        .padding(.vertical, MainEditLayout.textMenuVerticalPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: MainEditLayout.textMenuBarHeight, alignment: .center)
        .background(MainEditLayout.bottomPanelBackgroundColor)
    }

    var contentPanel: some View {
        HStack(alignment: .top) {
            Spacer(minLength: 0)
        }
        .padding(MainEditLayout.textContentPanelPadding)
        .frame(maxWidth: .infinity, alignment: .top)
        .frame(height: MainEditLayout.textContentPanelHeight, alignment: .top)
        .background(MainEditLayout.bottomPanelBackgroundColor)
    }
}

private enum MainEditTextPanelTab: CaseIterable, Identifiable {
    case font
    case color

    var id: Self {
        self
    }

    var title: String {
        switch self {
        case .font:
            return "폰트"
        case .color:
            return "컬러"
        }
    }
}

#Preview {
    MainEditTextPanel(
        cancelAction: {},
        confirmAction: {}
    )
    .frame(width: MainEditLayout.designWidth)
    .background(Color.black)
}
