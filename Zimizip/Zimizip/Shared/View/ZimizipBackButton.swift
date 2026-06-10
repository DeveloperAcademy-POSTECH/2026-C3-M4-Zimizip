import SwiftUI

struct ZimizipBackButton: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        Button {
            dismiss()
        } label: {
            Image(systemName: "chevron.left")
                .font(.system(size: 24, weight: .medium))
                .foregroundStyle(.gray450)
                .frame(width: 38, height: 38)
                .background(.gray100)
                .clipShape(Circle())
        }
        .padding(.vertical, 13)
    }
}

#Preview {
    ZimizipBackButton()
}
