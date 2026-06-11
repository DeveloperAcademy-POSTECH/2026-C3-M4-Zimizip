import SwiftUI

struct ArchiveReactionDetailAddCell: View {
    let width: CGFloat

    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.gray50)
                    .frame(width: 120, height: 166)

                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(Color.brandPrimary, style: StrokeStyle(lineWidth: 2, dash: [8, 6]))
                    .frame(width: 112, height: 158)

                Image(systemName: "plus")
                    .font(.system(size: 26, weight: .regular))
                    .foregroundStyle(Color.baseWhite)
                    .frame(width: 40, height: 40)
                    .background(Color.brandPrimary)
                    .clipShape(Circle())
            }
            .frame(width: width, height: 180)

            Color.clear
                .frame(height: 42)
        }
        .frame(width: width, alignment: .center)
    }
}

#Preview {
    ArchiveReactionDetailAddCell(width: 171)
        .padding()
        .background(Color.backgroundPrimary)
}
