import SwiftUI

struct CameraGridOverlay: View {
    let gridMode: CameraGridMode

    var body: some View {
        GeometryReader { geometry in
            let frame = CGRect(origin: .zero, size: geometry.size)
            Path { path in
                switch gridMode {
                case .off:
                    break
                case .thirds:
                    let divisions = 3
                    let stepWidth = frame.width / CGFloat(divisions)
                    let stepHeight = frame.height / CGFloat(divisions)

                    for index in 1..<divisions {
                        let x = frame.minX + stepWidth * CGFloat(index)
                        path.move(to: CGPoint(x: x, y: frame.minY))
                        path.addLine(to: CGPoint(x: x, y: frame.maxY))
                    }

                    for index in 1..<divisions {
                        let y = frame.minY + stepHeight * CGFloat(index)
                        path.move(to: CGPoint(x: frame.minX, y: y))
                        path.addLine(to: CGPoint(x: frame.maxX, y: y))
                    }
                case .golden:
                    let firstX = frame.minX + frame.width * 0.382
                    let secondX = frame.minX + frame.width * 0.618
                    let firstY = frame.minY + frame.height * 0.382
                    let secondY = frame.minY + frame.height * 0.618

                    path.move(to: CGPoint(x: firstX, y: frame.minY))
                    path.addLine(to: CGPoint(x: firstX, y: frame.maxY))
                    path.move(to: CGPoint(x: secondX, y: frame.minY))
                    path.addLine(to: CGPoint(x: secondX, y: frame.maxY))
                    path.move(to: CGPoint(x: frame.minX, y: firstY))
                    path.addLine(to: CGPoint(x: frame.maxX, y: firstY))
                    path.move(to: CGPoint(x: frame.minX, y: secondY))
                    path.addLine(to: CGPoint(x: frame.maxX, y: secondY))
                }
            }
            .stroke(Color.white.opacity(0.58), lineWidth: 0.9)
        }
        .allowsHitTesting(false)
    }
}
