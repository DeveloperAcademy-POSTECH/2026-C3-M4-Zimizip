import SwiftUI

struct ReactionRecordGuideView: View {
    var body: some View {
        ZStack {
            Color.backgroundPrimary
                .ignoresSafeArea()

            VStack(alignment: .leading) {
                
                Spacer()
                    .frame(height: 108)
                
                Text("시작하기 버튼을 누르고\n기기를 상대방에게 건네주세요")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(Color(red: 47 / 255, green: 41 / 255, blue: 37 / 255))
                    .padding(.horizontal, 20)
                
                Spacer()
                    .frame(height: 16)

                Text("버튼을 누름과 동시에\n화면 및 전면 녹화가 시작됩니다")
                    .font(.system(size: 18))
                    .foregroundStyle(Color(red: 179 / 255, green: 167 / 255, blue: 159 / 255))
                    .padding(.horizontal, 20)

                Spacer()

                ZimizipPrimaryButton(title: "시작하기") {}
                    .padding(.bottom, 60)
                    .padding(.horizontal, 20)
            }
        }
    }
}

#Preview {
    ReactionRecordGuideView()
}
