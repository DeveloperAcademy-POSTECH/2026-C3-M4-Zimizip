import SwiftUI

struct RevealGuideView: View {
    var body: some View {
        ZStack {
            Color("Overlay")
                .ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    Spacer()

                    Image("close")
                        .resizable()
                        .frame(width: 48, height: 48)
                        .padding(.trailing, 20)
                }
                .padding(.top, 49)

                Spacer()
                    .frame(height: 101)

                AnimatedImage(name: "GestureGuide")
                    .frame(width: 267, height: 267)

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
