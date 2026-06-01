import CoreGraphics

enum CameraAspectRatioOption: String, CaseIterable, Identifiable {
    case sixteenByNine
    case threeByTwo
    case threeByFour
    case oneByOne

    var id: String { rawValue }

    var title: String {
        switch self {
        case .sixteenByNine:
            "16:9"
        case .threeByTwo:
            "3:2"
        case .threeByFour:
            "4:3"
        case .oneByOne:
            "1:1"
        }
    }

    var previewRatio: CGFloat {
        switch self {
        case .sixteenByNine:
            9.0 / 16.0
        case .threeByTwo:
            2.0 / 3.0
        case .threeByFour:
            3.0 / 4.0
        case .oneByOne:
            1.0
        }
    }

    func frame(in size: CGSize) -> CGRect {
        let previewRatio = previewRatio
        let containerRatio = size.width / size.height

        if containerRatio > previewRatio {
            let height = size.height
            let width = height * previewRatio
            return CGRect(
                x: (size.width - width) / 2,
                y: 0,
                width: width,
                height: height
            )
        } else {
            let width = size.width
            let height = width / previewRatio
            return CGRect(
                x: 0,
                y: (size.height - height) / 2,
                width: width,
                height: height
            )
        }
    }

    func frame(in rect: CGRect) -> CGRect {
        let innerFrame = frame(in: rect.size)
        return innerFrame.offsetBy(dx: rect.minX, dy: rect.minY)
    }

    func cropRect(in size: CGSize) -> CGRect {
        frame(in: size).integral
    }

    func topAnchoredFrame(in rect: CGRect) -> CGRect {
        let width = rect.width
        let height = width / previewRatio

        if height <= rect.height {
            return CGRect(
                x: rect.minX,
                y: rect.minY,
                width: width,
                height: height
            )
        }

        let fittedHeight = rect.height
        let fittedWidth = fittedHeight * previewRatio
        return CGRect(
            x: rect.minX + (rect.width - fittedWidth) / 2,
            y: rect.minY,
            width: fittedWidth,
            height: fittedHeight
        )
    }
}
