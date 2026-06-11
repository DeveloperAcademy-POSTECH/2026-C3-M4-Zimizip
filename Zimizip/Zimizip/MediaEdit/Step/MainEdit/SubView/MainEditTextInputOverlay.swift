import SwiftUI
import UIKit

struct MainEditTextInputOverlay: View {
    @Binding var text: String
    @Binding var styleRuns: [MainEditTextStyleRun]
    @Binding var selectedRange: NSRange

    let framingResult: PhotoFramingResult
    let image: UIImage?
    let texts: [MainEditTextItem]
    let stickers: [MainEditStickerItem]
    let font: MainEditTextFont
    let color: MainEditTextColor
    let cancelAction: () -> Void
    let confirmAction: () -> Void

    var body: some View {
        GeometryReader { proxy in
            let canvasSize = modalCanvasSize(
                in: stableContainerSize(for: proxy.size),
                safeAreaInsets: proxy.safeAreaInsets
            )

            ZStack(alignment: .top) {
                canvasPreview(
                    frameSize: canvasSize
                )
                .frame(width: canvasSize.width, height: canvasSize.height)
                .position(
                    x: proxy.size.width / 2,
                    y: canvasTop(
                        in: proxy.size,
                        canvasSize: canvasSize,
                        safeAreaInsets: proxy.safeAreaInsets
                    ) + canvasSize.height / 2
                )

                topBar(safeAreaTop: proxy.safeAreaInsets.top)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black)
            .ignoresSafeArea(.container)
            .safeAreaInset(edge: .bottom, spacing: 0) {
                bottomInputArea(width: min(proxy.size.width, MainEditLayout.designWidth))
            }
        }
    }
}

private extension MainEditTextInputOverlay {
    var previewText: String {
        text.isEmpty ? MainEditLayout.textPreviewPlaceholder : text
    }

    var previewAttributedText: AttributedString {
        attributedString(
            text: previewText,
            styleRuns: text.isEmpty ? [] : styleRuns,
            fallbackFont: font,
            fallbackColor: color,
            fontSize: MainEditLayout.textInputPreviewFontSize
        )
    }

    func canvasPreview(frameSize: CGSize) -> some View {
        ZStack {
            MainEditCanvas(
                framingResult: framingResult,
                image: image,
                frameSize: frameSize,
                texts: texts,
                selectedTextID: nil,
                stickers: stickers,
                selectedStickerID: nil
            )
            .allowsHitTesting(false)

            RoundedRectangle(
                cornerRadius: PhotoFramingLayout.frameCornerRadius,
                style: .continuous
            )
            .fill(Color.black.opacity(MainEditLayout.textInputCanvasDimOpacity))

            Text(previewAttributedText)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.7)
                .padding(.horizontal, MainEditLayout.textInputPreviewHorizontalPadding)
        }
        .frame(width: frameSize.width, height: frameSize.height)
    }

    func stableContainerSize(for size: CGSize) -> CGSize {
        let screenSize = UIScreen.main.bounds.size

        return CGSize(
            width: size.width,
            height: max(size.height, screenSize.height)
        )
    }

    func modalCanvasSize(in size: CGSize, safeAreaInsets: EdgeInsets) -> CGSize {
        let availableWidth = min(size.width, MainEditLayout.designWidth)
        let maximumWidth = min(
            MainEditLayout.maximumCanvasWidth,
            availableWidth - MainEditLayout.textInputCanvasHorizontalInset * 2
        )
        let width = max(maximumWidth, 0)

        return CGSize(width: width, height: width / MainEditLayout.canvasAspectRatio)
    }

    func canvasTop(
        in size: CGSize,
        canvasSize: CGSize,
        safeAreaInsets: EdgeInsets
    ) -> CGFloat {
        let topBarBottom = safeAreaInsets.top +
            MainEditLayout.textInputTopAdditionalPadding +
            MainEditLayout.textInputTopButtonHeight
        let preferredTop = topBarBottom + MainEditLayout.textInputCanvasTopSpacing
        let inputTop = size.height - MainEditLayout.textInputSmallPreviewHeight
        let attachedTop = inputTop - canvasSize.height

        return max(preferredTop, attachedTop)
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
        smallPreview
            .frame(width: width, height: MainEditLayout.textInputSmallPreviewHeight)
    }

    var smallPreview: some View {
        HStack(alignment: .top, spacing: MainEditLayout.textInputSmallPreviewSpacing) {
            MainEditTextInputTextView(
                text: $text,
                styleRuns: $styleRuns,
                selectedRange: $selectedRange,
                font: font,
                color: color
            )
            .overlay(alignment: .topLeading) {
                if text.isEmpty {
                    Text(MainEditLayout.textPreviewPlaceholder)
                        .font(.custom(font.fontName, size: MainEditLayout.textInputSmallPreviewFontSize))
                        .foregroundStyle(color.color)
                        .allowsHitTesting(false)
                }
            }
            .frame(maxWidth: .infinity)

            Spacer(minLength: 0)
        }
        .padding(.horizontal, MainEditLayout.textInputSmallPreviewHorizontalPadding)
        .padding(.vertical, MainEditLayout.textInputSmallPreviewVerticalPadding)
        .background(Color.textArea)
    }

}

private struct MainEditTextInputTextView: UIViewRepresentable {
    @Binding var text: String
    @Binding var styleRuns: [MainEditTextStyleRun]
    @Binding var selectedRange: NSRange

    let font: MainEditTextFont
    let color: MainEditTextColor

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.backgroundColor = .clear
        textView.delegate = context.coordinator
        textView.font = UIFont(name: font.fontName, size: MainEditLayout.textInputSmallPreviewFontSize)
        textView.textColor = color.uiColor
        textView.tintColor = UIColor(Color.brandPrimary)
        textView.isScrollEnabled = false
        textView.textContainerInset = .zero
        textView.textContainer.lineFragmentPadding = 0
        textView.returnKeyType = .default
        textView.keyboardAppearance = .dark
        textView.autocorrectionType = .no
        textView.autocapitalizationType = .none
        textView.spellCheckingType = .no
        textView.smartDashesType = .no
        textView.smartQuotesType = .no
        textView.smartInsertDeleteType = .no
        textView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        textView.inputAssistantItem.leadingBarButtonGroups = []
        textView.inputAssistantItem.trailingBarButtonGroups = []

        DispatchQueue.main.async {
            textView.becomeFirstResponder()
        }

        return textView
    }

    func updateUIView(_ textView: UITextView, context: Context) {
        context.coordinator.parent = self

        let attributedText: NSAttributedString = attributedString(
            text: text,
            styleRuns: styleRuns,
            fallbackFont: font,
            fallbackColor: color,
            fontSize: MainEditLayout.textInputSmallPreviewFontSize
        )

        if textView.attributedText.string != attributedText.string ||
            textView.attributedText != attributedText {
            let selection = textView.selectedRange
            textView.attributedText = attributedText
            textView.selectedRange = clampedRange(selection, textLength: attributedText.length)
        }

        textView.typingAttributes = [
            .font: UIFont(name: font.fontName, size: MainEditLayout.textInputSmallPreviewFontSize)
                ?? UIFont.systemFont(ofSize: MainEditLayout.textInputSmallPreviewFontSize),
            .foregroundColor: color.uiColor
        ]

        if textView.selectedRange != selectedRange {
            textView.selectedRange = clampedRange(selectedRange, textLength: textView.attributedText.length)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    final class Coordinator: NSObject, UITextViewDelegate {
        var parent: MainEditTextInputTextView

        init(parent: MainEditTextInputTextView) {
            self.parent = parent
        }

        func textViewDidChange(_ textView: UITextView) {
            parent.text = textView.text
            parent.styleRuns = makeStyleRuns(
                from: textView.attributedText,
                fallbackFont: parent.font,
                fallbackColor: parent.color
            )
        }

        func textViewDidChangeSelection(_ textView: UITextView) {
            parent.selectedRange = textView.selectedRange
        }
    }
}

private func attributedString(
    text: String,
    styleRuns: [MainEditTextStyleRun],
    fallbackFont: MainEditTextFont,
    fallbackColor: MainEditTextColor,
    fontSize: CGFloat
) -> NSAttributedString {
    let attributedText = NSMutableAttributedString(
        string: text,
        attributes: [
            .font: UIFont(name: fallbackFont.fontName, size: fontSize) ?? UIFont.systemFont(ofSize: fontSize),
            .foregroundColor: fallbackColor.uiColor
        ]
    )

    styleRuns.forEach { styleRun in
        let range = clampedRange(
            NSRange(location: styleRun.start, length: styleRun.length),
            textLength: attributedText.length
        )

        guard range.length > 0 else {
            return
        }

        attributedText.addAttributes(
            [
                .font: UIFont(name: styleRun.font.fontName, size: fontSize) ?? UIFont.systemFont(ofSize: fontSize),
                .foregroundColor: styleRun.color.uiColor
            ],
            range: range
        )
    }

    return attributedText
}

private func attributedString(
    text: String,
    styleRuns: [MainEditTextStyleRun],
    fallbackFont: MainEditTextFont,
    fallbackColor: MainEditTextColor,
    fontSize: CGFloat
) -> AttributedString {
    var attributedText = AttributedString(text)
    attributedText.font = .custom(fallbackFont.fontName, size: fontSize)
    attributedText.foregroundColor = fallbackColor.color

    styleRuns.forEach { styleRun in
        guard let range = Range(
            NSRange(location: styleRun.start, length: styleRun.length),
            in: text
        ),
              let lowerBound = AttributedString.Index(range.lowerBound, within: attributedText),
              let upperBound = AttributedString.Index(range.upperBound, within: attributedText) else {
            return
        }

        attributedText[lowerBound..<upperBound].font = .custom(styleRun.font.fontName, size: fontSize)
        attributedText[lowerBound..<upperBound].foregroundColor = styleRun.color.color
    }

    return attributedText
}

private func makeStyleRuns(
    from attributedText: NSAttributedString,
    fallbackFont: MainEditTextFont,
    fallbackColor: MainEditTextColor
) -> [MainEditTextStyleRun] {
    var runs: [MainEditTextStyleRun] = []

    attributedText.enumerateAttributes(
        in: NSRange(location: 0, length: attributedText.length)
    ) { attributes, range, _ in
        runs.append(
            MainEditTextStyleRun(
                start: range.location,
                length: range.length,
                font: textFont(from: attributes[.font] as? UIFont) ?? fallbackFont,
                color: textColor(from: attributes[.foregroundColor] as? UIColor) ?? fallbackColor
            )
        )
    }

    return runs
}

private func textFont(from font: UIFont?) -> MainEditTextFont? {
    guard let font else {
        return nil
    }

    return MainEditTextFont.pretendardFonts.first { textFont in
        font.fontName == textFont.fontName ||
            font.fontName.contains(textFont.fontName)
    }
}

private func textColor(from color: UIColor?) -> MainEditTextColor? {
    guard let color else {
        return nil
    }

    return MainEditTextColor.allCases.first { colorOption in
        color.isClose(to: colorOption.uiColor)
    }
}

private func clampedRange(_ range: NSRange, textLength: Int) -> NSRange {
    let location = min(max(range.location, 0), textLength)
    let maximumLength = max(textLength - location, 0)
    let length = min(max(range.length, 0), maximumLength)

    return NSRange(location: location, length: length)
}

private extension UIColor {
    func isClose(to color: UIColor) -> Bool {
        var lhsRed: CGFloat = 0
        var lhsGreen: CGFloat = 0
        var lhsBlue: CGFloat = 0
        var lhsAlpha: CGFloat = 0
        var rhsRed: CGFloat = 0
        var rhsGreen: CGFloat = 0
        var rhsBlue: CGFloat = 0
        var rhsAlpha: CGFloat = 0

        getRed(&lhsRed, green: &lhsGreen, blue: &lhsBlue, alpha: &lhsAlpha)
        color.getRed(&rhsRed, green: &rhsGreen, blue: &rhsBlue, alpha: &rhsAlpha)

        return abs(lhsRed - rhsRed) < 0.01 &&
            abs(lhsGreen - rhsGreen) < 0.01 &&
            abs(lhsBlue - rhsBlue) < 0.01 &&
            abs(lhsAlpha - rhsAlpha) < 0.01
    }
}

#Preview {
    @Previewable @State var text = ""
    @Previewable @State var styleRuns: [MainEditTextStyleRun] = []
    @Previewable @State var selectedRange = NSRange(location: 0, length: 0)

    MainEditTextInputOverlay(
        text: $text,
        styleRuns: $styleRuns,
        selectedRange: $selectedRange,
        framingResult: PhotoFramingResult(
            source: Data(),
            backgroundColor: .white,
            transformState: PhotoFramingTransformState(),
            sourcePreviewFrame: nil,
            isLandscapeCapture: false
        ),
        image: nil,
        texts: [],
        stickers: [],
        font: .default,
        color: .white,
        cancelAction: {},
        confirmAction: {}
    )
}
