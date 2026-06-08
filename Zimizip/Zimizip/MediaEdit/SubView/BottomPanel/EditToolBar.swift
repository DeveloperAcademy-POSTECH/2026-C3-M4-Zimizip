import SwiftUI

struct EditToolBar: View {
    var body: some View {
        HStack(alignment: .top) {
            ForEach(Array(EditTool.allCases.enumerated()), id: \.element.id) { index, tool in
                EditToolButton(
                    title: tool.title,
                    imageName: tool.imageName,
                    action: {}
                )

                if index < EditTool.allCases.count - 1 {
                    Spacer(minLength: 0)
                }
            }
        }
        .padding(MainEditLayout.bottomToolBarPadding)
        .frame(maxWidth: .infinity)
        .frame(height: MainEditLayout.bottomToolBarHeight, alignment: .top)
        .background(Color(red: 0.23, green: 0.21, blue: 0.2).opacity(0.5))
    }
}

private struct EditToolButton: View {
    let title: String
    let imageName: String
    let action: () -> Void

    var body: some View {
        Button {
            action()
        } label: {
            VStack(spacing: 8) {
                Image(imageName)
                    .resizable()
                    .renderingMode(.template)
                    .scaledToFit()
                    .foregroundStyle(.white)
                    .frame(
                        width: MainEditLayout.toolIconSize,
                        height: MainEditLayout.toolIconSize
                    )

                Text(title)
                    .font(.custom("Pretendard", size: 16).weight(.bold))
                    .foregroundStyle(.white)
            }
            .frame(minWidth: 44)
        }
        .buttonStyle(.plain)
    }
}

private enum EditTool: CaseIterable, Identifiable {
    case filter
    case adjustment
    case text
    case sticker

    var id: Self { self }

    var title: String {
        switch self {
        case .filter:
            return "필터"
        case .adjustment:
            return "조정"
        case .text:
            return "텍스트"
        case .sticker:
            return "스티커"
        }
    }

    var imageName: String {
        switch self {
        case .filter:
            return "mingcute_color-filter-line"
        case .adjustment:
            return "exposure"
        case .text:
            return "format_size"
        case .sticker:
            return "sticker_add"
        }
    }
}

#Preview {
    EditToolBar()
}
