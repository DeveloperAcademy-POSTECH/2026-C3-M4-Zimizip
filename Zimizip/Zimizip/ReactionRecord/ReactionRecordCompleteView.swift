import SwiftUI
import UIKit

struct ReactionRecordCompleteView: View {
    let surpriseProjectTitle: String
    let thumbnailImage: UIImage?
    let onPrimaryButtonTap: () -> Void
    let onHomeButtonTap: () -> Void

    var body: some View {
        GeometryReader { proxy in
            VStack(alignment: .center) {
                Spacer()
                    .frame(height: 40)

                Text("축하해요!\n소중한 순간이 저장되었어요")
                    .font(Font.custom("Pretendard-Bold", size: 28))
                    .frame(maxWidth: .infinity, alignment: .leading)

                Spacer()
                    .frame(height: 16)

                Text("'\(surpriseProjectTitle)' 보관함에서\n언제든 다시 볼 수 있어요")
                    .font(Font.custom("Pretendard-Regular", size: 18))
                    .foregroundStyle(Color.gray250)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, 28)

                SurpriseContentFrameView {
                    if let thumbnailImage {
                        Image(uiImage: thumbnailImage)
                            .resizable()
                            .scaledToFill()
                    } else {
                        Image("Image")
                            .resizable()
                            .scaledToFit()
                    }
                }
                .frame(maxHeight: cardMaxHeight(for: proxy.size))
                .padding(.bottom, 24)

                ZimizipPrimaryButton(title: "영상 보러가기", action: onPrimaryButtonTap)
                    .padding(.bottom, 12)

                ZimizipSecondaryButton(title: "홈 가기", action: onHomeButtonTap)

                Spacer()
                    .frame(height: 72)
            }
            .padding(.horizontal, 20)
        }
    }
}

private extension ReactionRecordCompleteView {
    func cardMaxHeight(for containerSize: CGSize) -> CGFloat {
        let fixedContentHeight: CGFloat = 40 + 72 + 16 + 48 + 28 + 24 + 56 + 12 + 56 + 72
        let availableHeight = containerSize.height - fixedContentHeight

        return min(max(availableHeight, 180), 420)
    }
}

#Preview {
    ZStack {
        Color.backgroundPrimary
            .ignoresSafeArea()

        ReactionRecordCompleteView(
            surpriseProjectTitle: "서프라이즈 프로젝트",
            thumbnailImage: nil,
            onPrimaryButtonTap: {},
            onHomeButtonTap: {}
        )
    }
}
