import SwiftData

@Model
final class SurpriseProject {
    var name: String
    var content: Content
    var reactionContents: [ReactionContent]

    init(
        name: String,
        content: Content,
        reactionContents: [ReactionContent]
    ) {
        self.name = name
        self.content = content
        self.reactionContents = reactionContents
    }
}
