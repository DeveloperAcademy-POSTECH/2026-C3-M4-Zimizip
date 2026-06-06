import SwiftUI
import UIKit

struct PhotoFramingPhotoLayer: View {
    let image: UIImage
    let contentMode: ContentMode

    var body: some View {
        Image(uiImage: image)
            .resizable()
            .aspectRatio(contentMode: contentMode)
            .clipped()
    }
}
