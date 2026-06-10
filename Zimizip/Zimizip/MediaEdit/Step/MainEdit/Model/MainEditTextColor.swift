import SwiftUI

enum MainEditTextColor: String, CaseIterable, Codable, Equatable, Hashable, Identifiable {
    case white
    case red
    case orange
    case yellow
    case green

    var id: Self {
        self
    }

    var color: Color {
        switch self {
        case .white:
            return .white
        case .red:
            return Color(red: 1.0, green: 0.08, blue: 0.08)
        case .orange:
            return Color(red: 1.0, green: 0.49, blue: 0.04)
        case .yellow:
            return Color(red: 1.0, green: 0.90, blue: 0.0)
        case .green:
            return Color(red: 0.13, green: 1.0, blue: 0.34)
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
