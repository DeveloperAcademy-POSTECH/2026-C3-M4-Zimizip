import SwiftUI

struct MainEditTextPanel: View {
    @State private var selectedTab: MainEditTextPanelTab = .font
    @State private var selectedFontOption: MainEditTextFontOption = .default

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
        HStack(alignment: .top, spacing: 0) {
            if selectedTab == .font {
                fontOptionPanel
            } else {
                Spacer(minLength: 0)
            }
        }
        .padding(MainEditLayout.textContentPanelPadding)
        .frame(maxWidth: .infinity, alignment: .top)
        .frame(height: MainEditLayout.textContentPanelHeight, alignment: .top)
        .background(MainEditLayout.bottomPanelBackgroundColor)
    }

    var fontOptionPanel: some View {
        HStack(alignment: .top, spacing: 0) {
            ForEach(Array(MainEditTextFontOption.allCases.enumerated()), id: \.element.id) { index, option in
                fontOptionButton(option)

                if index < MainEditTextFontOption.allCases.count - 1 {
                    Spacer(minLength: 0)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .top)
    }

    func fontOptionButton(_ option: MainEditTextFontOption) -> some View {
        Button {
            selectedFontOption = option
        } label: {
            Text(option.title)
                .font(.custom("Pretendard", size: MainEditLayout.textFontOptionLabelFontSize).weight(.semibold))
                .multilineTextAlignment(.center)
                .foregroundStyle(Color.black)
                .frame(
                    width: MainEditLayout.textFontOptionSize.width,
                    height: MainEditLayout.textFontOptionSize.height
                )
                .background(Color.baseWhite)
                .clipShape(
                    RoundedRectangle(
                        cornerRadius: MainEditLayout.textFontOptionCornerRadius,
                        style: .continuous
                    )
                )
                .overlay {
                    if selectedFontOption == option {
                        RoundedRectangle(
                            cornerRadius: MainEditLayout.textFontOptionCornerRadius,
                            style: .continuous
                        )
                        .inset(by: MainEditLayout.textFontOptionSelectedBorderWidth / 2)
                        .stroke(
                            Color.brandPrimary,
                            lineWidth: MainEditLayout.textFontOptionSelectedBorderWidth
                        )
                    }
                }
        }
        .buttonStyle(.plain)
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

private enum MainEditTextFontOption: CaseIterable, Identifiable {
    case `default`
    case first
    case second

    var id: Self {
        self
    }

    var title: String {
        switch self {
        case .default:
            return "기본"
        case .first:
            return "글씨체 1"
        case .second:
            return "글씨체 2"
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
