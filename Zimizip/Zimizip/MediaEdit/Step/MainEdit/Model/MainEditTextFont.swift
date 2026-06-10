import Foundation

struct MainEditTextFont: Codable, Equatable, Hashable, Identifiable {
    let id: String
    let displayTitle: String
    let fontName: String
    let fileName: String

    static let `default` = MainEditTextFont(
        id: "pretendard-regular",
        displayTitle: "기본",
        fontName: "Pretendard-Regular",
        fileName: "Pretendard-Regular.otf"
    )

    static let pretendardFonts: [MainEditTextFont] = [
        .default,
        MainEditTextFont(
            id: "pretendard-black",
            displayTitle: "Black",
            fontName: "Pretendard-Black",
            fileName: "Pretendard-Black.otf"
        ),
        MainEditTextFont(
            id: "pretendard-bold",
            displayTitle: "Bold",
            fontName: "Pretendard-Bold",
            fileName: "Pretendard-Bold.otf"
        ),
        MainEditTextFont(
            id: "pretendard-semibold",
            displayTitle: "SemiBold",
            fontName: "Pretendard-SemiBold",
            fileName: "Pretendard-SemiBold.otf"
        ),
        MainEditTextFont(
            id: "pretendard-medium",
            displayTitle: "Medium",
            fontName: "Pretendard-Medium",
            fileName: "Pretendard-Medium.otf"
        ),
        MainEditTextFont(
            id: "pretendard-light",
            displayTitle: "Light",
            fontName: "Pretendard-Light",
            fileName: "Pretendard-Light.otf"
        )
    ]
}
