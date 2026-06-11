import SwiftData

@Model
final class SurpriseProject {
    var name: String
    @Relationship(deleteRule: .cascade)
    var content: Content
    @Relationship(deleteRule: .cascade)
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
