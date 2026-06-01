enum CameraQuickSetting: String, CaseIterable, Identifiable {
    case aspectRatio
    case timer
    case grid

    var id: String { rawValue }
}
