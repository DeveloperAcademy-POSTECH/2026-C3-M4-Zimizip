import SwiftUI

enum CameraColorPreset: String, CaseIterable, Identifiable {
    case original
    case warm
    case cool
    case vivid
    case mono

    var id: String { rawValue }

    var title: String {
        switch self {
        case .original:
            "기본"
        case .warm:
            "Warm"
        case .cool:
            "Cool"
        case .vivid:
            "Vivid"
        case .mono:
            "Mono"
        }
    }

    var previewColors: [Color] {
        switch self {
        case .original:
            [Color.white.opacity(0.95), Color.gray.opacity(0.45)]
        case .warm:
            [Color.orange.opacity(0.9), Color.yellow.opacity(0.65)]
        case .cool:
            [Color.cyan.opacity(0.85), Color.blue.opacity(0.7)]
        case .vivid:
            [Color.pink.opacity(0.9), Color.orange.opacity(0.85)]
        case .mono:
            [Color.white.opacity(0.9), Color.black.opacity(0.75)]
        }
    }

    var saturation: Double {
        switch self {
        case .original:
            1.0
        case .warm:
            1.08
        case .cool:
            1.03
        case .vivid:
            1.28
        case .mono:
            0.0
        }
    }

    var contrast: Double {
        switch self {
        case .original:
            1.0
        case .warm:
            1.02
        case .cool:
            1.04
        case .vivid:
            1.14
        case .mono:
            1.05
        }
    }

    var brightness: Double {
        switch self {
        case .original:
            0.0
        case .warm:
            0.01
        case .cool:
            0.0
        case .vivid:
            0.02
        case .mono:
            0.0
        }
    }

    var colorMultiply: Color {
        switch self {
        case .original:
            .white
        case .warm:
            Color(red: 1.0, green: 0.94, blue: 0.84)
        case .cool:
            Color(red: 0.86, green: 0.93, blue: 1.0)
        case .vivid:
            Color(red: 1.0, green: 0.95, blue: 0.9)
        case .mono:
            .white
        }
    }
}
