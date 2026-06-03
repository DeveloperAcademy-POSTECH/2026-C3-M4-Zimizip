import SwiftUI
import UIKit

struct CapturedPhotoConfirmationView: View {
    let photoData: Data

    private let designWidth: CGFloat = 402
    private let designImageHeight: CGFloat = 226
    private let bottomBarHeight: CGFloat = 108

    var body: some View {
        GeometryReader { proxy in
            let imageHeight = proxy.size.width * designImageHeight / designWidth

            ZStack {
                Color.black
                    .ignoresSafeArea()

                capturedPhoto
                    .frame(width: proxy.size.width, height: imageHeight)
                    .clipped()
                    .position(x: proxy.size.width / 2, y: proxy.size.height / 2)

                VStack {
                    Spacer()

                    HStack {
                        Color.clear
                            .frame(width: 72, height: 44)
                        Spacer()
                        Color.clear
                            .frame(width: 72, height: 44)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                    .frame(width: proxy.size.width, height: bottomBarHeight, alignment: .center)
                    .background(Color(red: 0.23, green: 0.21, blue: 0.2).opacity(0.5))
                }
                .ignoresSafeArea(edges: .bottom)
            }
        }
        .background(Color.black)
    }

    @ViewBuilder
    private var capturedPhoto: some View {
        if let image = UIImage(data: photoData) {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fill)
        } else {
            Text("사진을 불러올 수 없어요")
                .font(.custom("Pretendard", size: 16).weight(.bold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.white.opacity(0.08))
        }
    }
}

#Preview {
    CapturedPhotoConfirmationView(photoData: Data())
}
