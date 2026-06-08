import CoreImage
import ImageIO
import UIKit

struct MainEditFilterRenderer {
    static let shared = MainEditFilterRenderer()

    private let context: CIContext

    init(context: CIContext = CIContext()) {
        self.context = context
    }

    func image(
        applying preset: MainEditFilterPreset,
        to image: UIImage
    ) -> UIImage {
        guard let filterName = preset.ciFilterName,
              let inputImage = orientedCIImage(from: image),
              let outputImage = outputImage(
                from: inputImage,
                filterName: filterName
              ),
              let cgImage = context.createCGImage(
                outputImage,
                from: outputImage.extent
              ) else {
            return image
        }

        return UIImage(
            cgImage: cgImage,
            scale: image.scale,
            orientation: .up
        )
    }

    private func outputImage(
        from inputImage: CIImage,
        filterName: String
    ) -> CIImage? {
        guard let filter = CIFilter(name: filterName) else {
            return nil
        }

        filter.setValue(inputImage, forKey: kCIInputImageKey)

        return filter.outputImage?.cropped(to: inputImage.extent)
    }

    private func orientedCIImage(from image: UIImage) -> CIImage? {
        if let cgImage = image.cgImage {
            return CIImage(cgImage: cgImage)
                .oriented(image.imageOrientation.cgImagePropertyOrientation)
        }

        return image.ciImage
    }
}

private extension UIImage.Orientation {
    var cgImagePropertyOrientation: CGImagePropertyOrientation {
        switch self {
        case .up:
            return .up
        case .upMirrored:
            return .upMirrored
        case .down:
            return .down
        case .downMirrored:
            return .downMirrored
        case .left:
            return .left
        case .leftMirrored:
            return .leftMirrored
        case .right:
            return .right
        case .rightMirrored:
            return .rightMirrored
        @unknown default:
            return .up
        }
    }
}
