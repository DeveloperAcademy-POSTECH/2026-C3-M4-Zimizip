import SwiftUI

struct RevealGuideView: View {
    var body: some View {
        ZStack {
            Color.overlay
                .ignoresSafeArea()

            VStack {
                HStack {
                    Spacer()

                    Image("close")
                        .resizable()
                        .frame(width: 48, height: 48)
                        .padding(.trailing, 20)
                }

                AnimatedImage(name: "GestureGuide")
                    .frame(width: 267, height: 267)
                    .padding(.top, 88)

                Text("사진이 커버로 가려져 있어요\n좌우로 문질러 지워보세요")
                    .font(Font.custom("Pretendard-Bold", size: 20))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                
                Spacer()
                
            }
        }
    }
}

#Preview {
    RevealGuideView()
}
