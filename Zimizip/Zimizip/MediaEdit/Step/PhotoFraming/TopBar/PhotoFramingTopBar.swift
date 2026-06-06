import SwiftUI

struct PhotoFramingTopBar: View {
    let cancelButtonAction: () -> Void
    let completeButtonAction: () -> Void

    var body: some View {
        ZStack {
            Text("사진 배치")
                .font(.custom("Pretendard", size: 16).weight(.semibold))
                .foregroundStyle(.white)

            HStack {
                Button("취소") {
                    cancelButtonAction()
                }
                .font(.custom("Pretendard", size: 16).weight(.medium))
                .foregroundStyle(.white)
                .buttonStyle(.plain)

                Spacer()

                Button("완료") {
                    completeButtonAction()
                }
                .font(.custom("Pretendard", size: 16).weight(.semibold))
                .foregroundStyle(.white)
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 8)
        .frame(height: 48)
    }
}

#Preview {
    PhotoFramingTopBar(
        cancelButtonAction: {},
        completeButtonAction: {}
    )
    .frame(width: 402)
    .background(Color.black)
}
