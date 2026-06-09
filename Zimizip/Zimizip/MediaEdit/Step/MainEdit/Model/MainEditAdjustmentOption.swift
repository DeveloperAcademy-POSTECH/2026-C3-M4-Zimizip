import Foundation

enum MainEditAdjustmentOption: CaseIterable, Hashable, Identifiable {
    case exposure
    case contrast
    case brightness
    case blackPoint
    case highlight
    case shadow
    case sharpness
    case vignette

    var id: Self { self }

    var title: String {
        switch self {
        case .exposure:
            return "노출"
        case .contrast:
            return "대비"
        case .brightness:
            return "밝기"
        case .blackPoint:
            return "블랙 포인트"
        case .highlight:
            return "하이라이트"
        case .shadow:
            return "그림자"
        case .sharpness:
            return "선명도"
        case .vignette:
            return "비네트"
        }
    }

    var iconAssetName: String? {
        switch self {
        case .exposure:
            return "exposurePanel"
        case .contrast:
            return "contrastPanel"
        case .brightness:
            return "brightnessPanel"
        case .blackPoint:
            return "blackpointPanel"
        case .highlight:
            return "highlightPanel"
        case .shadow:
            return "exposure"
        case .sharpness:
            return "wheelPanel"
        case .vignette:
            return "vignettePanel"
        }
    }
}
