import SwiftUI

enum CameraWhiteBalancePreset: String, CaseIterable, Identifiable {
    case auto
    case incandescent
    case fluorescent
    case daylight
    case cloudy

    var id: String { rawValue }

    var shortLabel: String {
        switch self {
        case .auto:
            "AWB"
        case .incandescent:
            "텅스텐"
        case .fluorescent:
            "형광등"
        case .daylight:
            "태양광"
        case .cloudy:
            "흐림"
        }
    }

    var iconSystemName: String {
        switch self {
        case .auto:
            "camera.aperture"
        case .incandescent:
            "lightbulb.fill"
        case .fluorescent:
            "lamp.desk.fill"
        case .daylight:
            "sun.max.fill"
        case .cloudy:
            "cloud.fill"
        }
    }

    var iconColor: Color {
        switch self {
        case .auto:
            CameraUIConstants.accentColor
        case .incandescent:
            Color.orange
        case .fluorescent:
            Color.cyan
        case .daylight:
            Color.yellow
        case .cloudy:
            Color.blue.opacity(0.85)
        }
    }

    var temperature: Float? {
        switch self {
        case .auto:
            nil
        case .incandescent:
            3000
        case .fluorescent:
            4200
        case .daylight:
            5200
        case .cloudy:
            6500
        }
    }
}
