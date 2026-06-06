import SwiftUI

struct ReactionRecordGuideView: View {
    @State private var isShowingReactionRecord = false

    var body: some View {
        ZStack {
            Color.backgroundPrimary
                .ignoresSafeArea()

            VStack(alignment: .leading) {
                
                Spacer()
                    .frame(height: 108)
                
                Text("시작하기 버튼을 누르고\n기기를 상대방에게 건네주세요")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(.text)
                    .padding(.horizontal, 20)
                
                Spacer()
                    .frame(height: 16)

                Text("버튼을 누름과 동시에\n화면 및 전면 녹화가 시작됩니다")
                    .font(.system(size: 18))
                    .foregroundStyle(.gray250)
                    .padding(.horizontal, 20)

                Spacer()

                ZimizipPrimaryButton(title: "시작하기") {
                    isShowingReactionRecord = true
                }
                    .padding(.bottom, 60)
                    .padding(.horizontal, 20)
            }
        }
        .navigationDestination(isPresented: $isShowingReactionRecord) {
            ReactionRecordView()
        }
    }
}

#Preview {
    ReactionRecordGuideView()
}
