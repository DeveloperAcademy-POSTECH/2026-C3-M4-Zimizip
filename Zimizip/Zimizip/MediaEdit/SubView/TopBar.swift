import SwiftUI

struct TopBar: View {
    let title: String
    let nextButtonTitle: String
    let backButtonAction: () -> Void
    let nextButtonAction: () -> Void

    var body: some View {
        ZStack {
            Text(title)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(.black)

            HStack {
                Button {
                    backButtonAction()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 24, weight: .regular))
                        .foregroundStyle(.black)
                        .frame(width: 44, height: 44)
                }

                Spacer()

                Button {
                    nextButtonAction()
                } label: {
                    Text(nextButtonTitle)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 20)
                        .frame(height: 46)
                        .background(Color.blue)
                        .clipShape(Capsule())
                }
            }
        }
        .frame(height: 72)
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
