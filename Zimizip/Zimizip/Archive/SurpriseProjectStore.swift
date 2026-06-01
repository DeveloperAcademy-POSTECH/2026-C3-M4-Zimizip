//


import SwiftData

@MainActor
protocol SurpriseProjectStore {
    func save(_ surpriseProject: SurpriseProject) throws
    func fetchAll() throws -> [SurpriseProject]
    func deleteReactionContent(
        _ reactionContent: ReactionContent,
        from surpriseProject: SurpriseProject
    ) throws
    func delete(_ surpriseProject: SurpriseProject) throws
}

@MainActor
final class SwiftDataSurpriseProjectStore: SurpriseProjectStore {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func save(_ surpriseProject: SurpriseProject) throws {
        modelContext.insert(surpriseProject)
        try modelContext.save()
    }

    func fetchAll() throws -> [SurpriseProject] {
        try modelContext.fetch(FetchDescriptor<SurpriseProject>())
    }

    func deleteReactionContent(
        _ reactionContent: ReactionContent,
        from surpriseProject: SurpriseProject
    ) throws {
        surpriseProject.reactionContents.removeAll { $0 === reactionContent }
        modelContext.delete(reactionContent)
        try modelContext.save()
    }

    func delete(_ surpriseProject: SurpriseProject) throws {
        modelContext.delete(surpriseProject)
        try modelContext.save()
    }
}
