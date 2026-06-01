import SwiftUI

struct CameraMoreButton: View {
    let isExpanded: Bool
    let action: () -> Void

    var body: some View {
        Button {
            action()
        } label: {
            Image(systemName: "ellipsis")
                .rotationEffect(.degrees(90))
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(isExpanded ? CameraUIConstants.accentColor : .white)
                .frame(width: 34, height: 34)
        }
        .buttonStyle(.plain)
    }
}
