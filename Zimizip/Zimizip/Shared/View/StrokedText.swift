import SwiftUI
import UIKit

struct StrokedText: UIViewRepresentable {
    let text: String
    let fontName: String
    let size: CGFloat
    let colorName: String
    let strokeWidth: CGFloat

    func makeUIView(context: Context) -> UILabel {
        let label = UILabel()
        label.backgroundColor = .clear
        label.textAlignment = .left
        label.adjustsFontForContentSizeCategory = false
        return label
    }

    func updateUIView(_ label: UILabel, context: Context) {
        let font = UIFont(name: fontName, size: size) ?? .systemFont(ofSize: size)
        let color = UIColor(named: colorName) ?? .orange
        let strokePercent = -(strokeWidth / size * 100)

        label.attributedText = NSAttributedString(
            string: text,
            attributes: [
                .font: font,
                .foregroundColor: color,
                .strokeColor: color,
                .strokeWidth: strokePercent
            ]
        )
    }
}
