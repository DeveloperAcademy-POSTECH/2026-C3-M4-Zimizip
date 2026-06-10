import SwiftUI

struct MainEditTextInputOverlay: View {
    let cancelAction: () -> Void
    let confirmAction: () -> Void

    var body: some View {
        GeometryReader { proxy in
            VStack(spacing: 0) {
                topBar(safeAreaTop: proxy.safeAreaInsets.top)

                Spacer(minLength: 0)

                Text(MainEditLayout.textPreviewPlaceholder)
                    .font(.custom("Pretendard", size: MainEditLayout.textInputPreviewFontSize).weight(.bold))
                    .foregroundStyle(Color.baseWhite)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.7)
                    .padding(.horizontal, 32)

                Spacer(minLength: 0)

                bottomInputArea(width: min(proxy.size.width, MainEditLayout.designWidth))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black.opacity(0.55))
            .ignoresSafeArea()
        }
    }
}

private extension MainEditTextInputOverlay {
    func topBar(safeAreaTop: CGFloat) -> some View {
        HStack {
            Button("취소", action: cancelAction)
                .font(.custom("Pretendard", size: 16).weight(.bold))
                .foregroundStyle(Color.baseWhite)
                .frame(height: MainEditLayout.textInputTopButtonHeight)

            Spacer(minLength: 0)

            Button("완료", action: confirmAction)
                .font(.custom("Pretendard", size: 16).weight(.bold))
                .foregroundStyle(Color.baseWhite)
                .frame(height: MainEditLayout.textInputTopButtonHeight)
        }
        .buttonStyle(.plain)
        .padding(.top, safeAreaTop + 20)
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
        HStack(alignment: .top, spacing: 4) {
            Text(MainEditLayout.textPreviewPlaceholder)
                .font(.custom("Pretendard", size: MainEditLayout.textInputSmallPreviewFontSize).weight(.bold))
                .foregroundStyle(Color.baseWhite)
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            Spacer(minLength: 0)
        }
        .padding(.horizontal, MainEditLayout.textInputSmallPreviewHorizontalPadding)
        .padding(.vertical, MainEditLayout.textInputSmallPreviewVerticalPadding)
        .background(Color.textArea)
    }

    var keyboardMock: some View {
        VStack(spacing: MainEditLayout.textInputKeyboardRowSpacing) {
            keyboardRow(["ㅂ", "ㅈ", "ㄷ", "ㄱ", "ㅅ", "ㅛ", "ㅕ", "ㅑ", "ㅐ", "ㅔ"])
            keyboardRow(["ㅁ", "ㄴ", "ㅇ", "ㄹ", "ㅎ", "ㅗ", "ㅓ", "ㅏ", "ㅣ"], horizontalInset: 16)
            keyboardRow(["⇧", "ㅋ", "ㅌ", "ㅊ", "ㅍ", "ㅠ", "ㅜ", "ㅡ", "⌫"])
            keyboardBottomRow

            HStack {
                Image(systemName: "globe")
                    .font(.system(size: 30, weight: .regular))
                    .foregroundStyle(Color.baseWhite)

                Spacer(minLength: 0)

                Image(systemName: "mic")
                    .font(.system(size: 30, weight: .regular))
                    .foregroundStyle(Color.baseWhite)
            }
            .padding(.horizontal, 30)
            .padding(.top, 2)
        }
        .padding(.horizontal, MainEditLayout.textInputKeyboardHorizontalPadding)
        .padding(.vertical, MainEditLayout.textInputKeyboardVerticalPadding)
        .background(Color.black.opacity(0.82))
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
            keyboardKey("123", width: 54)
            keyboardKey("☻", width: 46)
            keyboardKey("한", width: nil)
            keyboardKey("↩", width: 90)
        }
    }

    func keyboardKey(_ text: String, width: CGFloat? = 31) -> some View {
        Text(text)
            .font(.custom("Pretendard", size: MainEditLayout.textInputKeyboardKeyFontSize).weight(.medium))
            .foregroundStyle(Color.baseWhite)
            .frame(maxWidth: width == nil ? .infinity : nil)
            .frame(width: width, height: MainEditLayout.textInputKeyboardKeyHeight)
            .background(Color.gray400.opacity(0.75))
            .clipShape(
                RoundedRectangle(
                    cornerRadius: MainEditLayout.textInputKeyboardKeyCornerRadius,
                    style: .continuous
                )
            )
    }
}

#Preview {
    MainEditTextInputOverlay(
        cancelAction: {},
        confirmAction: {}
    )
}
