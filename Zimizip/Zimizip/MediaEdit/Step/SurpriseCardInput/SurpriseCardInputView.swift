import SwiftUI
import UIKit

struct SurpriseCardInputView: View {
    @Environment(\.dismiss) private var dismiss
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

            VStack(alignment: .leading, spacing: 0) {
                backButton

                ScrollViewReader { scrollProxy in
                    ScrollView(showsIndicators: false) {
                        inputContent
                    }
                    .scrollDismissesKeyboard(.interactively)
                    .onChange(of: isSurpriseTitleFocused) { _, isFocused in
                        guard isFocused else {
                            return
                        }

                        DispatchQueue.main.async {
                            withAnimation(.easeInOut) {
                                scrollProxy.scrollTo(Self.contentBottomID, anchor: .bottom)
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, Self.horizontalPadding)
        }
        .navigationBarBackButtonHidden(true)
        .navigationDestination(isPresented: $isShowingRevealTiming) {
            RevealTimingView()
                .navigationBarBackButtonHidden(true)
        }
    }
}

private extension SurpriseCardInputView {
    var backButton: some View {
        Button {
            dismiss()
        } label: {
            Image(systemName: "chevron.left")
                .font(.system(size: 24, weight: .medium))
                .foregroundStyle(Color(red: 36 / 255, green: 33 / 255, blue: 31 / 255))
                .frame(width: 38, height: 38)
                .background(.gray100)
                .clipShape(Circle())
        }
        .padding(.vertical, 13)
    }

    var inputContent: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer()
                .frame(height: 40)

            Text("서프라이즈 커버에\n이름을 붙여주세요")
                .font(.custom("Pretendard", size: 28).weight(.bold))
                .foregroundStyle(.textPrimary)

            Spacer()
                .frame(height: 32)

            SurpriseContentFrameView {
                GeometryReader { proxy in
                    ZStack {
                        MainEditCanvas(
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
            .frame(maxWidth: .infinity, alignment: .center)

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
                .id(Self.surpriseTitleFieldID)

            ZimizipPrimaryButton(title: "서프라이즈 저장하기") {
                isShowingRevealTiming = true
            }
            .padding(.top, 20)

            Spacer()
                .frame(height: 24)
                .id(Self.contentBottomID)
        }
    }

    static let surpriseTitleFieldID = "surpriseTitleField"
    static let contentBottomID = "contentBottom"
    static let horizontalPadding: CGFloat = 20
    static let textFieldBorderColor = Color(red: 232 / 255, green: 224 / 255, blue: 218 / 255)
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
