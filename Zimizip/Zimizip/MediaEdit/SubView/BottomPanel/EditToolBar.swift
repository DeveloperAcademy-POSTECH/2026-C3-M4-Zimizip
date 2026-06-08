import SwiftUI

struct EditToolBar: View {
    @Binding var selectedTool: MainEditTool?

    var body: some View {
        HStack(alignment: .top) {
            ForEach(Array(MainEditTool.allCases.enumerated()), id: \.element.id) { index, tool in
                EditToolButton(
                    title: tool.title,
                    imageName: tool.imageName,
                    isSelected: selectedTool == tool,
                    action: {
                        select(tool)
                    }
                )

                if index < MainEditTool.allCases.count - 1 {
                    Spacer(minLength: 0)
                }
            }
        }
        .padding(MainEditLayout.bottomToolBarPadding)
        .frame(maxWidth: .infinity)
        .frame(height: MainEditLayout.bottomToolBarHeight, alignment: .top)
        .background(MainEditLayout.bottomPanelBackgroundColor)
    }

    private func select(_ tool: MainEditTool) {
        selectedTool = selectedTool == tool ? nil : tool
    }
}

private struct EditToolButton: View {
    let title: String
    let imageName: String
    let isSelected: Bool
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
                    .foregroundStyle(foregroundColor)
                    .frame(
                        width: MainEditLayout.toolIconSize,
                        height: MainEditLayout.toolIconSize
                    )

                Text(title)
                    .font(.custom("Pretendard", size: 16).weight(.bold))
                    .foregroundStyle(foregroundColor)
            }
            .frame(minWidth: 44)
        }
        .buttonStyle(.plain)
    }

    private var foregroundColor: Color {
        isSelected ? .brandPrimary : .white
    }
}

#Preview {
    @Previewable @State var selectedTool: MainEditTool?

    EditToolBar(selectedTool: $selectedTool)
}
