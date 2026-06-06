import SwiftUI

struct PhotoFramingGridGuide: View {
    var body: some View {
        GeometryReader { proxy in
            Path { path in
                let columnWidth = proxy.size.width / 3
                let rowHeight = proxy.size.height / 3

                for index in 1...2 {
                    let x = columnWidth * CGFloat(index)
                    path.move(to: CGPoint(x: x, y: 0))
                    path.addLine(to: CGPoint(x: x, y: proxy.size.height))

                    let y = rowHeight * CGFloat(index)
                    path.move(to: CGPoint(x: 0, y: y))
                    path.addLine(to: CGPoint(x: proxy.size.width, y: y))
                }
            }
            .stroke(Color.white.opacity(0.62), lineWidth: 1)
        }
    }
}

#Preview {
    PhotoFramingGridGuide()
        .frame(width: 297, height: 168)
        .background(Color.black)
}
