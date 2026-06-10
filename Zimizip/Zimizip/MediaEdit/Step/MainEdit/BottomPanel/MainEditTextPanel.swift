import SwiftUI

struct MainEditTextPanel: View {
    @State private var selectedTab: MainEditTextPanelTab = .font

    @Binding var selectedFont: MainEditTextFont
    @Binding var selectedColor: MainEditTextColor

    let selectFontAction: (MainEditTextFont) -> Void
    let cancelAction: () -> Void
    let confirmAction: () -> Void

    init(
        selectedFont: Binding<MainEditTextFont>,
        selectedColor: Binding<MainEditTextColor>,
        selectFontAction: @escaping (MainEditTextFont) -> Void,
        cancelAction: @escaping () -> Void,
        confirmAction: @escaping () -> Void
    ) {
        self._selectedFont = selectedFont
        self._selectedColor = selectedColor
        self.selectFontAction = selectFontAction
        self.cancelAction = cancelAction
        self.confirmAction = confirmAction
    }

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
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .top, spacing: MainEditLayout.textFontOptionSpacing) {
                ForEach(MainEditTextFont.pretendardFonts) { font in
                    fontOptionButton(font)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .top)
    }

    func fontOptionButton(_ font: MainEditTextFont) -> some View {
        Button {
            selectedFont = font
            selectFontAction(font)
        } label: {
            Text(font.displayTitle)
                .font(.custom(font.fontName, size: MainEditLayout.textFontOptionLabelFontSize))
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
                    if selectedFont == font {
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
            ForEach(Array(MainEditTextColor.allCases.enumerated()), id: \.element.id) { index, option in
                colorOptionButton(option)

                if index < MainEditTextColor.allCases.count - 1 {
                    Spacer(minLength: 0)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }

    func colorOptionButton(_ option: MainEditTextColor) -> some View {
        Button {
            selectedColor = option
        } label: {
            ZStack {
                if selectedColor == option {
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
        .accessibilityAddTraits(selectedColor == option ? .isSelected : [])
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
    @Previewable @State var selectedFont = MainEditTextFont.default
    @Previewable @State var selectedColor = MainEditTextColor.white

    MainEditTextPanel(
        selectedFont: $selectedFont,
        selectedColor: $selectedColor,
        selectFontAction: { _ in },
        cancelAction: {},
        confirmAction: {}
    )
    .frame(width: MainEditLayout.designWidth)
    .background(Color.black)
}
