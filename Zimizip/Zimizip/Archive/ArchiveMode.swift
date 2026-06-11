import CoreGraphics

enum ArchiveMode {
    case reaction
    case surpriseCard

    func iconName() -> String {
        switch self {
        case .reaction:
            return "play.square.fill"
        case .surpriseCard:
            return "square.stack.3d.up.fill"
        }
    }

    func titleText() -> String {
        switch self {
        case .reaction:
            return "리액션"
        case .surpriseCard:
            return "서프라이즈 카드"
        }
    }

    func gridSpacingValue() -> CGFloat {
        switch self {
        case .reaction:
            return 36
        case .surpriseCard:
            return 38
        }
    }
}
