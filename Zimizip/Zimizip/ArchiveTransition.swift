import SwiftUI

extension Animation {
    static let archiveMode = Animation.easeInOut(duration: 0.28)
}

extension AnyTransition {
    static let archiveMode = AnyTransition.opacity
        .combined(with: .scale(scale: 0.985, anchor: .center))
}
