import SwiftUI
import UIKit

struct PhotoFramingFrame: View {
    let image: UIImage?
    let backgroundColor: Color
    let frameSize: CGSize
    let photoSize: CGSize?

    var body: some View {
        ZStack {
            backgroundColor

            if let image, let photoSize {
                PhotoFramingPhotoLayer(
                    image: image,
                    contentMode: .fill
                )
                .frame(width: photoSize.width, height: photoSize.height)

                PhotoFramingGridGuide()
                    .frame(width: photoSize.width, height: photoSize.height)
            }
        }
        .frame(width: frameSize.width, height: frameSize.height)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

#Preview {
    PhotoFramingFrame(
        image: nil,
        backgroundColor: .white,
        frameSize: CGSize(width: 297, height: 446),
        photoSize: nil
    )
    .background(Color.black)
}
