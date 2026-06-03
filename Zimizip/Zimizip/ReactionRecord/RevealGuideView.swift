import SwiftUI

struct RevealGuideView: View {
    var body: some View {
        ZStack {
            Color(red: 58/255, green: 53/255, blue: 50/255)
                .opacity(0.5)
                .ignoresSafeArea()
            
            VStack {
                Image("HandDrawing")
                
                Text("카드를 문질러보세요")
                    .font(Font.custom("Pretendard-Medium", size: 24))
                    .foregroundStyle(Color(red: 255/255, green: 252/255, blue: 250/255))
            }
        }
    }
}
