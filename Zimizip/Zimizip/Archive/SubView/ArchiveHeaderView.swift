import SwiftUI

struct ArchiveHeaderView: View {
    let selectedArchiveMode: ArchiveMode
    let onSelectArchiveMode: (ArchiveMode) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("보관함")
                .font(Font.custom("Pretendard-Bold", size: 32))
                .tracking(-1.28)
                .foregroundStyle(Color.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 82)

            HStack(spacing: 8) {
                modeButton(.reaction)
                modeButton(.surpriseCard)
            }
            .padding(.top, 20)
        }
    }

    private func modeButton(_ mode: ArchiveMode) -> some View {
        Button {
            onSelectArchiveMode(mode)
        } label: {
            ArchiveFilterChip(
                icon: mode.iconName(),
                title: mode.titleText(),
                isSelected: selectedArchiveMode == mode
            )
        }
        .buttonStyle(.plain)
        .disabled(selectedArchiveMode == mode)
    }
}

#Preview {
    ArchiveHeaderView(
        selectedArchiveMode: .reaction,
        onSelectArchiveMode: { _ in }
    )
    .padding(.horizontal, 20)
    .background(Color.backgroundPrimary)
}
