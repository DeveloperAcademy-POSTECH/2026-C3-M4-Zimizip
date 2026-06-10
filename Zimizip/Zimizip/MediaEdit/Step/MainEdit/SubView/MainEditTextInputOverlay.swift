import SwiftUI

struct MainEditTextInputOverlay: View {
    @Binding var text: String
    @FocusState private var isTextFieldFocused: Bool

    let font: MainEditTextFont
    let cancelAction: () -> Void
    let confirmAction: () -> Void

    var body: some View {
        GeometryReader { proxy in
            VStack(spacing: 0) {
                topBar(safeAreaTop: proxy.safeAreaInsets.top)

                Spacer(minLength: 0)

                Text(previewText)
                    .font(.custom(font.fontName, size: MainEditLayout.textInputPreviewFontSize))
                    .foregroundStyle(Color.baseWhite)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.7)
                    .padding(.horizontal, MainEditLayout.textInputPreviewHorizontalPadding)

                Spacer(minLength: 0)

                bottomInputArea(width: min(proxy.size.width, MainEditLayout.designWidth))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black.opacity(MainEditLayout.textInputOverlayOpacity))
            .ignoresSafeArea()
        }
        .onAppear {
            isTextFieldFocused = true
        }
    }
}

private extension MainEditTextInputOverlay {
    var previewText: String {
        text.isEmpty ? MainEditLayout.textPreviewPlaceholder : text
    }

    func topBar(safeAreaTop: CGFloat) -> some View {
        HStack {
            Button(MainEditLayout.textInputCancelTitle, action: cancelAction)
                .font(.custom("Pretendard", size: MainEditLayout.textInputTopButtonFontSize).weight(.bold))
                .foregroundStyle(Color.baseWhite)
                .frame(height: MainEditLayout.textInputTopButtonHeight)

            Spacer(minLength: 0)

            Button(MainEditLayout.textInputConfirmTitle, action: confirmAction)
                .font(.custom("Pretendard", size: MainEditLayout.textInputTopButtonFontSize).weight(.bold))
                .foregroundStyle(Color.baseWhite)
                .frame(height: MainEditLayout.textInputTopButtonHeight)
        }
        .buttonStyle(.plain)
        .padding(.top, safeAreaTop + MainEditLayout.textInputTopAdditionalPadding)
        .padding(.horizontal, MainEditLayout.textInputTopHorizontalPadding)
    }

    func bottomInputArea(width: CGFloat) -> some View {
        VStack(spacing: 0) {
            smallPreview
                .frame(width: width, height: MainEditLayout.textInputSmallPreviewHeight)

            keyboardMock
                .frame(width: width, height: MainEditLayout.textInputKeyboardHeight)
        }
        .frame(width: width)
    }

    var smallPreview: some View {
        HStack(alignment: .top, spacing: MainEditLayout.textInputSmallPreviewSpacing) {
            TextField(MainEditLayout.textPreviewPlaceholder, text: $text)
                .font(.custom(font.fontName, size: MainEditLayout.textInputSmallPreviewFontSize))
                .foregroundStyle(Color.baseWhite)
                .tint(Color.brandPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .focused($isTextFieldFocused)
                .submitLabel(.done)
                .onSubmit(confirmAction)

            Spacer(minLength: 0)
        }
        .padding(.horizontal, MainEditLayout.textInputSmallPreviewHorizontalPadding)
        .padding(.vertical, MainEditLayout.textInputSmallPreviewVerticalPadding)
        .background(Color.textArea)
    }

    var keyboardMock: some View {
        VStack(spacing: MainEditLayout.textInputKeyboardRowSpacing) {
            keyboardRow(["ㅂ", "ㅈ", "ㄷ", "ㄱ", "ㅅ", "ㅛ", "ㅕ", "ㅑ", "ㅐ", "ㅔ"])
            keyboardRow(
                ["ㅁ", "ㄴ", "ㅇ", "ㄹ", "ㅎ", "ㅗ", "ㅓ", "ㅏ", "ㅣ"],
                horizontalInset: MainEditLayout.textInputKeyboardSecondRowInset
            )
            keyboardRow(["⇧", "ㅋ", "ㅌ", "ㅊ", "ㅍ", "ㅠ", "ㅜ", "ㅡ", "⌫"])
            keyboardBottomRow

            HStack {
                Image(systemName: MainEditLayout.textInputGlobeIconName)
                    .font(.system(size: MainEditLayout.textInputKeyboardUtilityIconSize, weight: .regular))
                    .foregroundStyle(Color.baseWhite)

                Spacer(minLength: 0)

                Image(systemName: MainEditLayout.textInputMicrophoneIconName)
                    .font(.system(size: MainEditLayout.textInputKeyboardUtilityIconSize, weight: .regular))
                    .foregroundStyle(Color.baseWhite)
            }
            .padding(.horizontal, MainEditLayout.textInputKeyboardUtilityHorizontalPadding)
            .padding(.top, MainEditLayout.textInputKeyboardUtilityTopPadding)
        }
        .padding(.horizontal, MainEditLayout.textInputKeyboardHorizontalPadding)
        .padding(.vertical, MainEditLayout.textInputKeyboardVerticalPadding)
        .background(Color.black.opacity(MainEditLayout.textInputKeyboardBackgroundOpacity))
        .clipShape(
            RoundedRectangle(
                cornerRadius: MainEditLayout.textInputKeyboardCornerRadius,
                style: .continuous
            )
        )
    }

    func keyboardRow(_ keys: [String], horizontalInset: CGFloat = 0) -> some View {
        HStack(spacing: MainEditLayout.textInputKeyboardKeySpacing) {
            ForEach(keys, id: \.self) { key in
                keyboardKey(key)
            }
        }
        .padding(.horizontal, horizontalInset)
    }

    var keyboardBottomRow: some View {
        HStack(spacing: MainEditLayout.textInputKeyboardKeySpacing) {
            keyboardKey("123", width: MainEditLayout.textInputKeyboardNumberKeyWidth)
            keyboardKey("☻", width: MainEditLayout.textInputKeyboardEmojiKeyWidth)
            keyboardKey("한", width: nil)
            keyboardKey("↩", width: MainEditLayout.textInputKeyboardReturnKeyWidth)
        }
    }

    func keyboardKey(
        _ text: String,
        width: CGFloat? = MainEditLayout.textInputKeyboardKeyWidth
    ) -> some View {
        Text(text)
            .font(.custom("Pretendard", size: MainEditLayout.textInputKeyboardKeyFontSize).weight(.medium))
            .foregroundStyle(Color.baseWhite)
            .frame(maxWidth: width == nil ? .infinity : nil)
            .frame(width: width, height: MainEditLayout.textInputKeyboardKeyHeight)
            .background(Color.gray400.opacity(MainEditLayout.textInputKeyboardKeyOpacity))
            .clipShape(
                RoundedRectangle(
                    cornerRadius: MainEditLayout.textInputKeyboardKeyCornerRadius,
                    style: .continuous
                )
            )
    }
}

#Preview {
    @Previewable @State var text = ""

    MainEditTextInputOverlay(
        text: $text,
        font: .default,
        cancelAction: {},
        confirmAction: {}
    )
}
