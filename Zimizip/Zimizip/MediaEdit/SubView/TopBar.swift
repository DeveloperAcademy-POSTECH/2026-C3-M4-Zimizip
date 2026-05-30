import SwiftUI

struct TopBar: View {
    let title: String
    let nextButtonTitle: String
    let backButtonAction: () -> Void
    let nextButtonAction: () -> Void
    
    var body: some View {
        HStack {
            Button {
                backButtonAction()
            } label: {
                Image(systemName: "chevron.left")
            }
            .frame(width: 28, height: 28)
            .padding(.vertical, 18)
            .padding(.horizontal, 10)
            .padding(.trailing, 18)
            
            Spacer()
            
            Text(title)
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(.black)
            
            Spacer()
            
            Button {
                nextButtonAction()
            } label: {
                Text(nextButtonTitle)
                    .frame(width: 56, height: 34)
                    .font(.system(size: 15, weight: .regular))
                    .foregroundStyle(.white)
                    .background(.blue)
                    .clipShape(Capsule())
            }
            .padding(.vertical, 15)
            .padding(.horizontal, 10)
        }
    }
}

#Preview {
    TopBar(
        title: "사진 편집",
        nextButtonTitle: "다음",
        backButtonAction: {},
        nextButtonAction: {}
    )
}
