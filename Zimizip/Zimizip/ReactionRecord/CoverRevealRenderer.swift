import CoreImage
import UIKit

struct CoverRevealRenderer {
    private let context = CIContext()

    func render(
        bottomImage: UIImage,
        coverImage: UIImage,
        revealPoints: [CGPoint],
        outputSize: CGSize,
        brushRadius: CGFloat
    ) -> UIImage? {
        guard outputSize.width > 0,
              outputSize.height > 0 else {
            return nil
        }

        let bottomImage = image(bottomImage, resizedTo: outputSize)
        let coverImage = image(coverImage, resizedTo: outputSize)
        let maskImage = coverVisibleMask(
            size: outputSize,
            revealPoints: revealPoints,
            brushRadius: brushRadius
        )

        guard let bottomCIImage = CIImage(image: bottomImage),
              let coverCIImage = CIImage(image: coverImage),
              let maskCIImage = CIImage(image: maskImage) else {
            return nil
        }

        let outputImage = coverCIImage
            .applyingFilter(
                "CIBlendWithMask",
                parameters: [
                    kCIInputBackgroundImageKey: bottomCIImage,
                    kCIInputMaskImageKey: maskCIImage
                ]
            )

        guard let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else {
            return nil
        }

        return UIImage(cgImage: cgImage)
    }

    func revealedRatio(
        outputSize: CGSize,
        revealPoints: [CGPoint],
        brushRadius: CGFloat
    ) -> Double {
        guard outputSize.width > 0,
              outputSize.height > 0,
              !revealPoints.isEmpty else {
            return 0
        }

        let maskImage = coverVisibleMask(
            size: outputSize,
            revealPoints: revealPoints,
            brushRadius: brushRadius
        )

        return blackPixelRatio(in: maskImage)
    }
}

private extension CoverRevealRenderer {
    func image(_ image: UIImage, resizedTo size: CGSize) -> UIImage {
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1

        return UIGraphicsImageRenderer(size: size, format: format).image { _ in
            image.draw(in: CGRect(origin: .zero, size: size))
        }
    }

    func coverVisibleMask(
        size: CGSize,
        revealPoints: [CGPoint],
        brushRadius: CGFloat
    ) -> UIImage {
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1

        return UIGraphicsImageRenderer(size: size, format: format).image { context in
            UIColor.white.setFill()
            context.cgContext.fill(CGRect(origin: .zero, size: size))

            guard !revealPoints.isEmpty else {
                return
            }

            let cgContext = context.cgContext
            cgContext.setStrokeColor(UIColor.black.cgColor)
            cgContext.setFillColor(UIColor.black.cgColor)
            cgContext.setLineWidth(brushRadius * 2)
            cgContext.setLineCap(.round)
            cgContext.setLineJoin(.round)

            if revealPoints.count == 1,
               let point = revealPoints.first {
                cgContext.fillEllipse(
                    in: CGRect(
                        x: point.x - brushRadius,
                        y: point.y - brushRadius,
                        width: brushRadius * 2,
                        height: brushRadius * 2
                    )
                )
                return
            }

            cgContext.beginPath()
            cgContext.move(to: revealPoints[0])

            for point in revealPoints.dropFirst() {
                cgContext.addLine(to: point)
            }

            cgContext.strokePath()
        }
    }

    func blackPixelRatio(in image: UIImage) -> Double {
        guard let cgImage = image.cgImage else {
            return 0
        }

        let width = cgImage.width
        let height = cgImage.height
        let bytesPerPixel = 4
        let bytesPerRow = width * bytesPerPixel
        var pixels = [UInt8](repeating: 0, count: height * bytesPerRow)

        guard let context = CGContext(
            data: &pixels,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: bytesPerRow,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else {
            return 0
        }

        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))

        let pixelCount = width * height
        var blackPixelCount = 0

        for pixelIndex in 0..<pixelCount {
            let offset = pixelIndex * bytesPerPixel
            let red = pixels[offset]
            let green = pixels[offset + 1]
            let blue = pixels[offset + 2]

            if red < 128, green < 128, blue < 128 {
                blackPixelCount += 1
            }
        }

        return Double(blackPixelCount) / Double(pixelCount)
    }
}
