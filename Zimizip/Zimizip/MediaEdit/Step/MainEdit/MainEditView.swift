import SwiftUI

struct MainEditView: View {
    let framingResult: PhotoFramingResult
    let backButtonAction: () -> Void
    let completeButtonAction: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            topBar

            GeometryReader { proxy in
                let frameSize = PhotoFramingLayout.frameSize(in: proxy.size)

                ZStack {
                    Color.black

                    RoundedRectangle(cornerRadius: PhotoFramingLayout.frameCornerRadius, style: .continuous)
                        .fill(framingResult.backgroundColor.color)
                        .frame(width: frameSize.width, height: frameSize.height)
                }
            }

            bottomToolArea
        }
        .background(Color.black)
    }
}

private extension MainEditView {
    var topBar: some View {
        HStack {
            Button {
                backButtonAction()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 32, weight: .medium))
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
            }
            .buttonStyle(.plain)

            Spacer()

            Text("사진 꾸미기")
                .font(.custom("Pretendard", size: 16).weight(.semibold))
                .foregroundStyle(.white)

            Spacer()

            Button {
                completeButtonAction()
            } label: {
                Text("완료")
                    .font(.custom("Pretendard", size: 16).weight(.bold))
                    .foregroundStyle(.white)
                    .frame(width: 56, height: 50)
                    .background(Color(.primary))
                    .clipShape(Capsule())
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 24)
        .padding(.top, 50)
        .padding(.bottom, 28)
        .background(Color.black)
    }

    var bottomToolArea: some View {
        Rectangle()
            .fill(Color(red: 0.23, green: 0.21, blue: 0.2).opacity(0.5))
            .frame(maxWidth: .infinity)
            .frame(height: 108)
    }
}

#Preview {
    MainEditView(
        framingResult: PhotoFramingResult(
            source: Data(),
            backgroundColor: .white,
            transformState: PhotoFramingTransformState(),
            sourcePreviewFrame: nil,
            isLandscapeCapture: false
        ),
        backButtonAction: {},
        completeButtonAction: {}
    )
}
