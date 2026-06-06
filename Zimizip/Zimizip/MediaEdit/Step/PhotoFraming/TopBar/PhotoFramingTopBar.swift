import SwiftUI

struct PhotoFramingTopBar: View {
    let cancelButtonAction: () -> Void
    let completeButtonAction: () -> Void

    var body: some View {
        HStack {
            Button("취소") {
                cancelButtonAction()
            }
            .font(.system(size: 17, weight: .regular))
            .foregroundStyle(.white)
            .frame(width: 56, alignment: .leading)
            .buttonStyle(.plain)

            Spacer()

            Text("사진 배치")
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(.white)

            Spacer()

            Button("완료") {
                completeButtonAction()
            }
            .font(.system(size: 17, weight: .semibold))
            .foregroundStyle(.white)
            .frame(width: 56, alignment: .trailing)
            .buttonStyle(.plain)
            .border(.red)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 18)
    }
}

#Preview {
    PhotoFramingTopBar(
        cancelButtonAction: {},
        completeButtonAction: {}
    )
    .background(Color.black)
}
