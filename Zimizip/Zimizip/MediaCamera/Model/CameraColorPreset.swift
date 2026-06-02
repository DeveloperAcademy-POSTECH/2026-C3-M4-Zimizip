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
}
