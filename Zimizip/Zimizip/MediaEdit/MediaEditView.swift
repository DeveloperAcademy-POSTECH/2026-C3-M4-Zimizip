import SwiftUI
import UIKit

struct MediaEditView: View {
    let media: Data

    var body: some View {
        VStack {
            if let image = UIImage(data: media) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
            } else {
                Text("사진을 불러올 수 없어요")
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .padding(24)
    }
}

#Preview {
    MediaEditView(media: Data())
}
