import SwiftUI

struct MainEditTextPanel: View {
    @State private var selectedTab: MainEditTextPanelTab = .font
    @State private var selectedFontOption: MainEditTextFontOption = .default
    @State private var selectedColorOption: MainEditTextColorOption = .white

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
            } else if selectedTab == .color {
                colorOptionPanel
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

    var colorOptionPanel: some View {
        HStack(alignment: .center, spacing: 0) {
            ForEach(Array(MainEditTextColorOption.allCases.enumerated()), id: \.element.id) { index, option in
                colorOptionButton(option)

                if index < MainEditTextColorOption.allCases.count - 1 {
                    Spacer(minLength: 0)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }

    func colorOptionButton(_ option: MainEditTextColorOption) -> some View {
        Button {
            selectedColorOption = option
        } label: {
            ZStack {
                if selectedColorOption == option {
                    RoundedRectangle(cornerRadius: MainEditLayout.textColorSelectedRingCornerRadius)
                        .fill(.clear)
                        .frame(
                            width: MainEditLayout.textColorSelectedRingSize,
                            height: MainEditLayout.textColorSelectedRingSize
                        )
                        .overlay {
                            RoundedRectangle(cornerRadius: MainEditLayout.textColorSelectedRingCornerRadius)
                                .inset(by: -2)
                                .stroke(
                                    Color.brandPrimary,
                                    lineWidth: MainEditLayout.textColorSelectedRingWidth
                                )
                        }

                    RoundedRectangle(cornerRadius: MainEditLayout.textColorSelectedFillCornerRadius)
                        .fill(option.color)
                        .frame(
                            width: MainEditLayout.textColorSelectedFillSize,
                            height: MainEditLayout.textColorSelectedFillSize
                        )
                } else {
                    Circle()
                        .fill(option.color)
                        .frame(
                            width: MainEditLayout.textColorSwatchSize,
                            height: MainEditLayout.textColorSwatchSize
                        )
                }
            }
            .frame(
                width: MainEditLayout.textColorSwatchSize,
                height: MainEditLayout.textColorSwatchSize
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(option.accessibilityLabel)
        .accessibilityAddTraits(selectedColorOption == option ? .isSelected : [])
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

private enum MainEditTextColorOption: CaseIterable, Identifiable {
    case white
    case red
    case orange
    case yellow
    case green

    var id: Self {
        self
    }

    var color: Color {
        switch self {
        case .white:
            return .white
        case .red:
            return Color(red: 1.0, green: 0.08, blue: 0.08)
        case .orange:
            return Color(red: 1.0, green: 0.49, blue: 0.04)
        case .yellow:
            return Color(red: 1.0, green: 0.90, blue: 0.0)
        case .green:
            return Color(red: 0.13, green: 1.0, blue: 0.34)
        }
    }

    var accessibilityLabel: String {
        switch self {
        case .white:
            return "흰색"
        case .red:
            return "빨간색"
        case .orange:
            return "주황색"
        case .yellow:
            return "노란색"
        case .green:
            return "초록색"
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
