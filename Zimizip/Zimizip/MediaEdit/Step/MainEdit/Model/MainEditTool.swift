import Foundation

enum MainEditTool: CaseIterable, Identifiable {
    case filter
    case adjustment
    case text
    case sticker

    var id: Self { self }

    var title: String {
        switch self {
        case .filter:
            return "필터"
        case .adjustment:
            return "조정"
        case .text:
            return "텍스트"
        case .sticker:
            return "스티커"
        }
    }

    var imageName: String {
        switch self {
        case .filter:
            return "mingcute_color-filter-line"
        case .adjustment:
            return "exposure"
        case .text:
            return "format_size"
        case .sticker:
            return "sticker_add"
        }
    }
}
