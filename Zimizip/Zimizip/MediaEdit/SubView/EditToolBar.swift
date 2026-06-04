import SwiftUI

struct EditToolBar: View {

    var body: some View {
        HStack(spacing: 22) {
            ForEach(EditTool.allCases) { tool in
                EditToolButton(
                    title: tool.title,
                    systemImageName: tool.systemImageName,
                    action: {}
                )
            }
        }
        .padding(.horizontal, 22)
    }
}

private struct EditToolButton: View {
    let title: String
    let systemImageName: String
    let action: () -> Void

    var body: some View {
        Button {
            action()
        } label: {
            VStack {
                Image(systemName: systemImageName)
                    .font(.system(size: 30, weight: .regular))
                    .frame(width: 36, height: 36)

                Spacer()
                    .frame(height: 26)

                Text(title)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundStyle(.black)
            }
        }
        .buttonStyle(.plain)
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
    EditToolBar()
}
