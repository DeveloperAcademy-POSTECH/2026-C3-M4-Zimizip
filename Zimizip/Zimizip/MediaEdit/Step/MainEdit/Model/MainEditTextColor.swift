import SwiftUI
import UIKit

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

    var uiColor: UIColor {
        switch self {
        case .white:
            return .white
        case .red:
            return UIColor(red: 1.0, green: 0.08, blue: 0.08, alpha: 1)
        case .orange:
            return UIColor(red: 1.0, green: 0.49, blue: 0.04, alpha: 1)
        case .yellow:
            return UIColor(red: 1.0, green: 0.90, blue: 0.0, alpha: 1)
        case .green:
            return UIColor(red: 0.13, green: 1.0, blue: 0.34, alpha: 1)
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
