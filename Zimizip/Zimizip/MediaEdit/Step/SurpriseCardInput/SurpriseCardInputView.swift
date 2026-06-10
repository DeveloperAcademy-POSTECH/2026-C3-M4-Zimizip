import SwiftUI

struct SurpriseCardInputView: View {
    @State private var isShowingRevealTiming = false
    @State private var surpriseTitle = ""
    @FocusState private var isSurpriseTitleFocused: Bool

    let framingResult: PhotoFramingResult
    let image: UIImage?
    let coverImageName: String

    var body: some View {
        ZStack {
            Color.backgroundPrimary
                .ignoresSafeArea()

            mainContent
        }
        .safeAreaInset(edge: .bottom) {
            bottomInputArea
        }
        .navigationBarBackButtonHidden(true)
        .navigationDestination(isPresented: $isShowingRevealTiming) {
            RevealTimingView(surpriseCardPayload: surpriseCardPayload)
                .navigationBarBackButtonHidden(true)
        }
    }
}

private extension SurpriseCardInputView {
    var mainContent: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZimizipBackButton()

            Spacer()
                .frame(height: 40)

            Text("서프라이즈 커버에\n이름을 붙여주세요")
                .font(.custom("Pretendard", size: 28).weight(.bold))
                .foregroundStyle(.textPrimary)

            Spacer()
                .frame(height: 32)

            cardArea
                .frame(maxWidth: .infinity)
                .frame(maxHeight: .infinity)

            Spacer()
                .frame(height: 12)
        }
        .padding(.horizontal, Self.horizontalPadding)
    }

    var cardArea: some View {
        GeometryReader { proxy in
            let cardWidth = cardWidthThatFits(in: proxy.size)

            VStack {
                Spacer(minLength: 0)

                SurpriseContentFrameView {
                    GeometryReader { proxy in
                        ZStack {
                            MainEditCompletedImageView(
                                framingResult: framingResult,
                                image: image,
                                frameSize: proxy.size
                            )

                            Image(coverImageName)
                                .resizable()
                                .scaledToFill()
                                .frame(width: proxy.size.width, height: proxy.size.height)
                        }
                    }
                }
                .frame(width: cardWidth)
                
                Spacer(minLength: 0)
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
            .padding(0)
        }
        .frame(minHeight: Self.minimumCardAreaHeight)
    }

    var surpriseCardPayload: SurpriseCardPayload {
        SurpriseCardPayload(
            title: surpriseTitle,
            framingResult: framingResult,
            image: image,
            coverImageName: coverImageName
        )
    }

    var bottomInputArea: some View {
        VStack(spacing: 20) {
            TextField("이름을 입력해주세요", text: $surpriseTitle)
                .font(.custom("Pretendard", size: 16).weight(.bold))
                .foregroundStyle(.textPrimary)
                .focused($isSurpriseTitleFocused)
                .onTapGesture {
                    isSurpriseTitleFocused = true
                }
                .frame(height: 56)
                .padding(.horizontal, 20)
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .overlay {
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Self.textFieldBorderColor, lineWidth: 1)
                }

            ZimizipPrimaryButton(title: "서프라이즈 저장하기") {
                isShowingRevealTiming = true
            }
        }
        .padding(.horizontal, Self.horizontalPadding)
        .padding(.top, 8)
        .padding(.bottom, 12)
        .background(Color.backgroundPrimary)
    }

    func cardWidthThatFits(in size: CGSize) -> CGFloat {
        let widthThatFitsHeight = max(
            size.height - Self.cardFramePadding * 2,
            0
        ) * Self.cardAspectRatio + Self.cardFramePadding * 2

        return min(size.width, Self.maximumCardWidth, widthThatFitsHeight)
    }

    static let horizontalPadding: CGFloat = 20
    static let textFieldBorderColor = Color(red: 232 / 255, green: 224 / 255, blue: 218 / 255)
    static let maximumCardWidth: CGFloat = 320
    static let minimumCardAreaHeight: CGFloat = 0
    static let cardFramePadding: CGFloat = 20
    static let cardAspectRatio: CGFloat = 2.0 / 3.0
}

#Preview {
    SurpriseCardInputView(
        framingResult: .surpriseCardInputPreviewValue,
        image: nil,
        coverImageName: "HomeSurpriseCardCenter"
    )
}

private extension PhotoFramingResult {
    static var surpriseCardInputPreviewValue: PhotoFramingResult {
        var transformState = PhotoFramingTransformState()
        transformState.frameSize = CGSize(width: 297, height: 446)
        transformState.basePhotoSize = CGSize(width: 534, height: 300)
        transformState.minimumScale = 0.45
        transformState.scale = 1
        transformState.offset = .zero
        transformState.sourceAspectRatio = 402 / 226

        return PhotoFramingResult(
            source: Data(),
            backgroundColor: .white,
            transformState: transformState,
            sourcePreviewFrame: nil,
            isLandscapeCapture: true
        )
    }
}
