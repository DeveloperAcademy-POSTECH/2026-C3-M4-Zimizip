import Observation

@Observable
@MainActor
final class ArchiveViewModel {
    private let surpriseProjectStore: SurpriseProjectStore

    private(set) var surpriseProjects: [SurpriseProject] = []
    private(set) var errorMessage: String?

    init(surpriseProjectStore: SurpriseProjectStore) {
        self.surpriseProjectStore = surpriseProjectStore
    }

    func loadSurpriseProjects() {
        do {
            surpriseProjects = try surpriseProjectStore.fetchAll()
        } catch {
            errorMessage = "프로젝트를 불러오지 못했어요."
        }
    }

    func saveSurpriseProject(_ surpriseProject: SurpriseProject) {
        do {
            try surpriseProjectStore.save(surpriseProject)
            surpriseProjects = try surpriseProjectStore.fetchAll()
        } catch {
            errorMessage = "프로젝트를 저장하지 못했어요."
        }
    }
}
