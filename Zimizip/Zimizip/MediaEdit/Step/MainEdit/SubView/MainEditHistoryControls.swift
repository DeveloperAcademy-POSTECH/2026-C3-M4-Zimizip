import SwiftUI

struct MainEditHistoryControls: View {
    let canUndo: Bool
    let canRedo: Bool
    let undoAction: () -> Void
    let redoAction: () -> Void

    var body: some View {
        HStack(spacing: MainEditLayout.historyControlSpacing) {
            historyButton(
                imageName: MainEditLayout.historyUndoIconName,
                isEnabled: canUndo,
                action: undoAction
            )

            historyButton(
                imageName: MainEditLayout.historyRedoIconName,
                isEnabled: canRedo,
                action: redoAction
            )
        }
    }
}

private extension MainEditHistoryControls {
    func historyButton(
        imageName: String,
        isEnabled: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Image(imageName)
                .resizable()
                .renderingMode(.template)
                .scaledToFit()
                .foregroundStyle(isEnabled ? Color.baseWhite : Color.tabColorSub)
                .frame(
                    width: MainEditLayout.historyControlIconSize,
                    height: MainEditLayout.historyControlIconSize
                )
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
    }
}

#Preview {
    VStack(spacing: 12) {
        MainEditHistoryControls(
            canUndo: true,
            canRedo: false,
            undoAction: {},
            redoAction: {}
        )

        MainEditHistoryControls(
            canUndo: false,
            canRedo: true,
            undoAction: {},
            redoAction: {}
        )
    }
    .padding()
    .background(Color.black)
}
