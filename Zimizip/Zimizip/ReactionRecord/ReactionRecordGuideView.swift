import SwiftUI

struct ReactionRecordGuideView: View {
    var body: some View {
        ZStack {
            Color.backgroundPrimary
                .ignoresSafeArea()

            VStack(alignment: .leading) {
                VStack(alignment: .leading, spacing: 16) {
                    Text("시작하기 버튼을 누르고\n기기를 상대방에게 건네주세요")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(Color(red: 36 / 255, green: 33 / 255, blue: 31 / 255))

                    Text("버튼을 누름과 동시에\n화면 및 전면 녹화가 시작됩니다")
                        .font(.system(size: 18))
                        .foregroundStyle(Color(red: 181 / 255, green: 170 / 255, blue: 162 / 255))
                        .lineSpacing(4)
                }
                .padding(.horizontal, 20)
                .padding(.top, 75)

                Spacer()

                ZimizipPrimaryButton(title: "시작하기") {}
                    .padding(.bottom, 60)
            }
        }
    }
}

#Preview {
    ReactionRecordGuideView()
}
