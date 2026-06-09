import SwiftUI
import UIKit
import ImageIO

struct AnimatedImage: UIViewRepresentable {
    let name: String
    var speed: Double = 1
    var repeatCount: Int = 0
    var contentMode: UIView.ContentMode = .scaleAspectFit

    static func animationDuration(name: String, speed: Double = 1) -> TimeInterval? {
        UIImage.animationAsset(named: "\(name)Data", speed: speed)?.duration
    }

    func makeUIView(context: Context) -> UIView {
        let containerView = UIView()
        containerView.clipsToBounds = true

        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = contentMode
        imageView.clipsToBounds = true
        imageView.tag = 1

        containerView.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            imageView.topAnchor.constraint(equalTo: containerView.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])

        configure(imageView)
        return containerView
    }

    func updateUIView(_ containerView: UIView, context: Context) {
        guard let imageView = containerView.viewWithTag(1) as? UIImageView else {
            return
        }

        imageView.contentMode = contentMode
        configure(imageView)
    }

    private func configure(_ imageView: UIImageView) {
        if let animation = UIImage.animationAsset(named: "\(name)Data", speed: speed) {
            imageView.image = animation.frames.first
            imageView.animationImages = animation.frames
            imageView.animationDuration = animation.duration
            imageView.animationRepeatCount = repeatCount
            imageView.startAnimating()
        } else {
            imageView.image = UIImage(named: name)
            imageView.animationImages = nil
            imageView.stopAnimating()
        }
    }
}

private extension UIImage {
    struct AnimationAsset {
        let frames: [UIImage]
        let duration: TimeInterval
    }

    static func animationAsset(named name: String, speed: Double) -> AnimationAsset? {
        guard
            let dataAsset = NSDataAsset(name: name),
            let source = CGImageSourceCreateWithData(dataAsset.data as CFData, nil)
        else {
            return nil
        }

        let frameCount = CGImageSourceGetCount(source)
        guard frameCount > 1 else {
            return nil
        }

        var frames: [UIImage] = []
        var duration: TimeInterval = 0

        for index in 0..<frameCount {
            guard let cgImage = CGImageSourceCreateImageAtIndex(source, index, nil) else {
                continue
            }

            frames.append(UIImage(cgImage: cgImage))
            duration += frameDuration(at: index, source: source)
        }

        guard !frames.isEmpty else {
            return nil
        }

        let playbackSpeed = max(speed, 0.01)
        return AnimationAsset(frames: frames, duration: max(duration / playbackSpeed, 0.1))
    }

    static func frameDuration(at index: Int, source: CGImageSource) -> TimeInterval {
        guard let properties = CGImageSourceCopyPropertiesAtIndex(source, index, nil) as? [CFString: Any] else {
            return 0.1
        }

        if
            let gifProperties = properties[kCGImagePropertyGIFDictionary] as? [CFString: Any],
            let gifDelay = gifProperties[kCGImagePropertyGIFUnclampedDelayTime] as? TimeInterval
                ?? gifProperties[kCGImagePropertyGIFDelayTime] as? TimeInterval
        {
            return max(gifDelay, 0.02)
        }

        if
            let pngProperties = properties[kCGImagePropertyPNGDictionary] as? [CFString: Any],
            let pngDelay = pngProperties[kCGImagePropertyAPNGUnclampedDelayTime] as? TimeInterval
                ?? pngProperties[kCGImagePropertyAPNGDelayTime] as? TimeInterval
        {
            return max(pngDelay, 0.02)
        }

        return 0.1
    }
}
