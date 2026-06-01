enum CameraGridMode: String, CaseIterable, Identifiable {
    case off
    case thirds
    case golden

    var id: String { rawValue }

    var title: String {
        switch self {
        case .off:
            "Off"
        case .thirds:
            "9 Grid"
        case .golden:
            "Golden"
        }
    }

    var statusValue: String {
        switch self {
        case .off:
            "Off"
        case .thirds:
            "9 Grid"
        case .golden:
            "Golden"
        }
    }
}
