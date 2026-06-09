import CoreImage
import ImageIO
import UIKit

struct MainEditAdjustmentRenderer {
    static let shared = MainEditAdjustmentRenderer()

    private let context: CIContext

    init(context: CIContext = CIContext()) {
        self.context = context
    }

    func image(
        applying adjustmentValues: [MainEditAdjustmentOption: Int],
        to image: UIImage
    ) -> UIImage {
        let normalizedValues = normalized(adjustmentValues)

        guard !normalizedValues.isEmpty,
              let inputImage = orientedCIImage(from: image) else {
            return image
        }

        let outputImage = MainEditAdjustmentOption.renderOrder.reduce(inputImage) { currentImage, option in
            guard let value = normalizedValues[option] else {
                return currentImage
            }

            return adjustedImage(currentImage, option: option, value: value)
        }

        guard let cgImage = context.createCGImage(
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
}

private extension MainEditAdjustmentRenderer {
    func normalized(
        _ adjustmentValues: [MainEditAdjustmentOption: Int]
    ) -> [MainEditAdjustmentOption: Double] {
        Dictionary(
            uniqueKeysWithValues: adjustmentValues.compactMap { option, value in
                let clampedValue = min(max(value, -100), 100)

                guard clampedValue != 0 else {
                    return nil
                }

                return (option, Double(clampedValue) / 100)
            }
        )
    }

    func adjustedImage(
        _ image: CIImage,
        option: MainEditAdjustmentOption,
        value: Double
    ) -> CIImage {
        switch option {
        case .exposure:
            return exposureAdjustedImage(image, value: value)
        case .contrast:
            return colorControlledImage(image, contrast: 1 + value * 0.45)
        case .brightness:
            return colorControlledImage(image, brightness: value * 0.18)
        case .blackPoint:
            return blackPointAdjustedImage(image, value: value)
        case .highlight:
            return highlightShadowAdjustedImage(image, highlightAmount: 1 - value * 0.55)
        case .shadow:
            return highlightShadowAdjustedImage(image, shadowAmount: 1 + value * 0.65)
        case .sharpness:
            return sharpnessAdjustedImage(image, value: value)
        case .vignette:
            return vignetteAdjustedImage(image, value: value)
        }
    }

    func exposureAdjustedImage(_ image: CIImage, value: Double) -> CIImage {
        guard let filter = CIFilter(name: "CIExposureAdjust") else {
            return image
        }

        filter.setValue(image, forKey: kCIInputImageKey)
        filter.setValue(value * 1.2, forKey: kCIInputEVKey)

        return filter.outputImage?.cropped(to: image.extent) ?? image
    }

    func colorControlledImage(
        _ image: CIImage,
        brightness: Double? = nil,
        contrast: Double? = nil
    ) -> CIImage {
        guard let filter = CIFilter(name: "CIColorControls") else {
            return image
        }

        filter.setValue(image, forKey: kCIInputImageKey)

        if let brightness {
            filter.setValue(brightness, forKey: kCIInputBrightnessKey)
        }

        if let contrast {
            filter.setValue(contrast, forKey: kCIInputContrastKey)
        }

        return filter.outputImage?.cropped(to: image.extent) ?? image
    }

    func blackPointAdjustedImage(_ image: CIImage, value: Double) -> CIImage {
        guard let filter = CIFilter(name: "CIToneCurve") else {
            return image
        }

        let blackDepth = max(value, 0) * 0.12
        let blackLift = abs(min(value, 0)) * 0.14
        let shadowLift = abs(min(value, 0)) * 0.08

        filter.setValue(image, forKey: kCIInputImageKey)
        filter.setValue(CIVector(x: 0, y: blackLift), forKey: "inputPoint0")
        filter.setValue(CIVector(x: 0.25, y: max(0, 0.25 - blackDepth + shadowLift)), forKey: "inputPoint1")
        filter.setValue(CIVector(x: 0.5, y: 0.5), forKey: "inputPoint2")
        filter.setValue(CIVector(x: 0.75, y: 0.75), forKey: "inputPoint3")
        filter.setValue(CIVector(x: 1, y: 1), forKey: "inputPoint4")

        return filter.outputImage?.cropped(to: image.extent) ?? image
    }

    func highlightShadowAdjustedImage(
        _ image: CIImage,
        highlightAmount: Double? = nil,
        shadowAmount: Double? = nil
    ) -> CIImage {
        guard let filter = CIFilter(name: "CIHighlightShadowAdjust") else {
            return image
        }

        filter.setValue(image, forKey: kCIInputImageKey)

        if let highlightAmount {
            filter.setValue(highlightAmount, forKey: "inputHighlightAmount")
        }

        if let shadowAmount {
            filter.setValue(shadowAmount, forKey: "inputShadowAmount")
        }

        return filter.outputImage?.cropped(to: image.extent) ?? image
    }

    func sharpnessAdjustedImage(_ image: CIImage, value: Double) -> CIImage {
        guard value > 0,
              let filter = CIFilter(name: "CISharpenLuminance") else {
            return image
        }

        filter.setValue(image, forKey: kCIInputImageKey)
        filter.setValue(value * 0.8, forKey: kCIInputSharpnessKey)

        return filter.outputImage?.cropped(to: image.extent) ?? image
    }

    func vignetteAdjustedImage(_ image: CIImage, value: Double) -> CIImage {
        guard value > 0,
              let filter = CIFilter(name: "CIVignette") else {
            return image
        }

        let radius = min(image.extent.width, image.extent.height) * (0.25 + value * 0.45)

        filter.setValue(image, forKey: kCIInputImageKey)
        filter.setValue(value * 1.6, forKey: kCIInputIntensityKey)
        filter.setValue(radius, forKey: kCIInputRadiusKey)

        return filter.outputImage?.cropped(to: image.extent) ?? image
    }

    func orientedCIImage(from image: UIImage) -> CIImage? {
        if let cgImage = image.cgImage {
            return CIImage(cgImage: cgImage)
                .oriented(image.imageOrientation.adjustmentCGImagePropertyOrientation)
        }

        return image.ciImage
    }
}

private extension MainEditAdjustmentOption {
    static var renderOrder: [MainEditAdjustmentOption] {
        [
            .exposure,
            .brightness,
            .contrast,
            .blackPoint,
            .highlight,
            .shadow,
            .sharpness,
            .vignette
        ]
    }
}

private extension UIImage.Orientation {
    var adjustmentCGImagePropertyOrientation: CGImagePropertyOrientation {
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
