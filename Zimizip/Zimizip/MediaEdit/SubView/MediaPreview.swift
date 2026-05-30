import SwiftUI
import UIKit

struct MediaPreview: View {
    let media: Data

    var body: some View {
        Group {
            if let image = UIImage(data: media) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
            } else {
                Text("사진을 불러올 수 없어요")
            }
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    MediaPreview(media: Data())
}
