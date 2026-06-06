import SwiftUI

enum PhotoFramingBackgroundColor: CaseIterable, Identifiable {
    case white
    case red
    case orange
    case yellow
    case green

    var id: Self { self }

    var color: Color {
        switch self {
        case .white:
            return .white
        case .red:
            return Color(red: 1.0, green: 0.07, blue: 0.05)
        case .orange:
            return Color(red: 1.0, green: 0.48, blue: 0.05)
        case .yellow:
            return Color(red: 1.0, green: 0.88, blue: 0.0)
        case .green:
            return Color(red: 0.12, green: 1.0, blue: 0.34)
        }
    }

    var accessibilityLabel: String {
        switch self {
        case .white:
            return "흰색"
        case .red:
            return "빨간색"
        case .orange:
            return "주황색"
        case .yellow:
            return "노란색"
        case .green:
            return "초록색"
        }
    }
}
