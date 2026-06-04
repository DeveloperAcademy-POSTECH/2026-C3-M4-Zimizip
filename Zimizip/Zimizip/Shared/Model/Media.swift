import Foundation
import SwiftData

@Model
final class Media {
    var source: Data

    init(source: Data) {
        self.source = source
    }
}
