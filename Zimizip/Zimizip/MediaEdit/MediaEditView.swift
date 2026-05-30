import SwiftUI
import UIKit

struct MediaEditView: View {
    @Environment(\.dismiss) private var dismiss

    let media: Data

    var body: some View {
        VStack(spacing: 0) {
            TopBar(
                title: "사진 편집",
                nextButtonTitle: "다음",
                backButtonAction: {
                    dismiss()
                },
                nextButtonAction: {}
            )

            Spacer(minLength: 0)

            mediaPreview

            Spacer(minLength: 0)

            editToolBar
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 24)
        .background(Color.white)
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
    }

    private var mediaPreview: some View {
        Group {
            if let image = UIImage(data: media) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 374, maxHeight: 504)
            } else {
                Text("사진을 불러올 수 없어요")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: 374, minHeight: 374)
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var editToolBar: some View {
        HStack {
            ForEach(EditTool.allCases) { tool in
                Button {
                } label: {
                    VStack {
                        Image(systemName: tool.systemImageName)
                            .font(.system(size: 34, weight: .regular))
                            .frame(width: 44, height: 44)

                        Text(tool.title)
                            .font(.system(size: 16, weight: .regular))
                            .foregroundStyle(.black)
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.plain)
            }
        }
        .frame(height: 104)
    }
}

private enum EditTool: CaseIterable, Identifiable {
    case filter
    case crop
    case detail
    case text
    case sticker
    case ratio

    var id: Self { self }

    var title: String {
        switch self {
        case .filter:
            return "필터"
        case .crop:
            return "자르기"
        case .detail:
            return "세밀 보정"
        case .text:
            return "텍스트"
        case .sticker:
            return "스티커"
        case .ratio:
            return "비율"
        }
    }

    var systemImageName: String {
        switch self {
        case .filter:
            return "circle.lefthalf.filled"
        case .crop:
            return "crop"
        case .detail:
            return "sparkles"
        case .text:
            return "textformat"
        case .sticker:
            return "face.smiling"
        case .ratio:
            return "aspectratio"
        }
    }
}

#Preview {
    MediaEditView(media: Data())
}
