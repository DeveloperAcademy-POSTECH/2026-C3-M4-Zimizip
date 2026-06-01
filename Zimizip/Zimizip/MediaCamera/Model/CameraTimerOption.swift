enum CameraTimerOption: String, CaseIterable, Identifiable {
    case off
    case twoSeconds
    case fiveSeconds
    case tenSeconds

    var id: String { rawValue }

    var title: String {
        switch self {
        case .off:
            "Off"
        case .twoSeconds:
            "2"
        case .fiveSeconds:
            "5"
        case .tenSeconds:
            "10"
        }
    }

    var seconds: Int {
        switch self {
        case .off:
            0
        case .twoSeconds:
            2
        case .fiveSeconds:
            5
        case .tenSeconds:
            10
        }
    }

    var quickLabel: String {
        seconds == 0 ? "0" : "\(seconds)"
    }

    var shutterLabel: String {
        switch self {
        case .off:
            "바로 사용"
        case .twoSeconds:
            "2초 타이머"
        case .fiveSeconds:
            "5초 타이머"
        case .tenSeconds:
            "10초 타이머"
        }
    }
}
