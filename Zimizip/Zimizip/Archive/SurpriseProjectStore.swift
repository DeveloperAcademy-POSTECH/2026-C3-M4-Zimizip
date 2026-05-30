import SwiftData

@MainActor
protocol SurpriseProjectStore {
    func save(_ surpriseProject: SurpriseProject) throws
    func fetchAll() throws -> [SurpriseProject]
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
}
