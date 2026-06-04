enum CameraManualControl: String, CaseIterable, Identifiable {
    case exposure
    case shutterSpeed
    case iso
    case whiteBalance

    var id: String { rawValue }

    var title: String {
        switch self {
        case .exposure:
            "Exp"
        case .shutterSpeed:
            "Sec"
        case .iso:
            "ISO"
        case .whiteBalance:
            "WB"
        }
    }

    static let defaultDisplayValues: [CameraManualControl: String] = [
        .exposure: "0.0",
        .shutterSpeed: "AUTO",
        .iso: "AUTO",
        .whiteBalance: "AWB"
    ]
}
