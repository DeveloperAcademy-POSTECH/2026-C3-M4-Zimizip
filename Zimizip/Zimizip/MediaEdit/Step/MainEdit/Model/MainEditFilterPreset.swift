import Foundation

enum MainEditFilterPreset: CaseIterable, Hashable, Identifiable {
    case original
    case warm
    case cool
    case vivid
    case mono

    var id: Self { self }

    var title: String {
        switch self {
        case .original:
            return "원본"
        case .warm:
            return "따뜻한"
        case .cool:
            return "차가운"
        case .vivid:
            return "선명한"
        case .mono:
            return "모노"
        }
    }

    var ciFilterName: String? {
        switch self {
        case .original:
            return nil
        case .warm:
            return "CIPhotoEffectTransfer"
        case .cool:
            return "CIPhotoEffectProcess"
        case .vivid:
            return "CIPhotoEffectChrome"
        case .mono:
            return "CIPhotoEffectMono"
        }
    }
}
