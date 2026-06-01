//


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

    func deleteReactionContent(
        _ reactionContent: ReactionContent,
        from surpriseProject: SurpriseProject
    ) {
        do {
            try surpriseProjectStore.deleteReactionContent(
                reactionContent,
                from: surpriseProject
            )
            surpriseProjects = try surpriseProjectStore.fetchAll()
        } catch {
            errorMessage = "리액션 콘텐츠를 삭제하지 못했어요."
        }
    }

    func deleteSurpriseProject(_ surpriseProject: SurpriseProject) {
        do {
            try surpriseProjectStore.delete(surpriseProject)
            surpriseProjects = try surpriseProjectStore.fetchAll()
        } catch {
            errorMessage = "프로젝트를 삭제하지 못했어요."
        }
    }
}
