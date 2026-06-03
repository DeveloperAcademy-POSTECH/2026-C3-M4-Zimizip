import SwiftUI

struct ReactionRecordCompleteView: View {
    let surpriseProjectTitle: String
    let onPrimaryButtonTap: () -> Void
    let onHomeButtonTap: () -> Void

    var body: some View {
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

            SurpriseContentFrameView {
                Image("Image")
                    .resizable()
                    .scaledToFit()
            }

            ZimizipPrimaryButton(title: "보관함 보기", action: onPrimaryButtonTap)

            ZimizipSecondaryButton(title: "홈 가기", action: onHomeButtonTap)
            
            Spacer()
                .frame(height: 72)
        }
        .padding(.horizontal, 20)
    }
}

#Preview {
    ZStack {
        Color.backgroundPrimary
            .ignoresSafeArea()

        ReactionRecordCompleteView(
            surpriseProjectTitle: "서프라이즈 프로젝트",
            onPrimaryButtonTap: {},
            onHomeButtonTap: {}
        )
    }
}
