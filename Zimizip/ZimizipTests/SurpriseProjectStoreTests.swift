import Foundation
import SwiftData
import Testing
@testable import Zimizip

@MainActor
struct SurpriseProjectStoreTests {
    @Test("서프라이즈 프로젝트를 저장하고 전체 조회할 수 있다")
    func saveAndFetchAllProjects() throws {
        // Given
        let testStore = try makeTestStore()
        let birthdayProject = makeProject(name: "생일")
        let graduationProject = makeProject(name: "졸업")

        // When
        try testStore.store.save(birthdayProject)
        try testStore.store.save(graduationProject)
        let savedProjects = try testStore.store.fetchAll()

        // Then
        #expect(savedProjects.count == 2)
        #expect(Set(savedProjects.map(\.name)) == ["생일", "졸업"])
    }

    @Test("프로젝트에서 리액션 콘텐츠 하나를 삭제할 수 있다")
    func deleteReactionContent() throws {
        // Given
        let testStore = try makeTestStore()
        let project = makeProject(name: "생일")
        try testStore.store.save(project)
        #expect(project.reactionContents.count == 2)

        // When
        let reactionToDelete = try #require(project.reactionContents.first)
        try testStore.store.deleteReactionContent(reactionToDelete, from: project)

        // Then
        let savedProjects = try testStore.store.fetchAll()
        let savedReactionContents = try testStore.context.fetch(
            FetchDescriptor<ReactionContent>()
        )
        #expect(savedProjects.count == 1)
        #expect(savedProjects[0].reactionContents.count == 1)
        #expect(savedReactionContents.count == 1)
    }

    @Test("특정 서프라이즈 프로젝트와 하위 데이터를 삭제할 수 있다")
    func deleteSurpriseProject() throws {
        // Given
        let testStore = try makeTestStore()
        let projectToDelete = makeProject(name: "삭제할 프로젝트")
        let projectToKeep = makeProject(name: "남길 프로젝트")
        try testStore.store.save(projectToDelete)
        try testStore.store.save(projectToKeep)

        // When
        try testStore.store.delete(projectToDelete)

        // Then
        let savedProjects = try testStore.store.fetchAll()
        let savedReactionContents = try testStore.context.fetch(
            FetchDescriptor<ReactionContent>()
        )
        let savedContents = try testStore.context.fetch(FetchDescriptor<Content>())
        let savedMedia = try testStore.context.fetch(FetchDescriptor<Media>())

        #expect(savedProjects.map(\.name) == ["남길 프로젝트"])
        #expect(savedReactionContents.count == 2)
        #expect(savedContents.count == 1)
        #expect(savedMedia.count == 1)
    }

    private func makeTestStore() throws -> TestStore {
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(
            for: SurpriseProject.self,
            Content.self,
            Media.self,
            ReactionContent.self,
            configurations: configuration
        )
        let context = container.mainContext

        return TestStore(
            container: container,
            context: context,
            store: SwiftDataSurpriseProjectStore(modelContext: context)
        )
    }

    private func makeProject(name: String) -> SurpriseProject {
        SurpriseProject(
            name: name,
            content: Content(
                media: Media(source: Data([1, 2, 3])),
                box: "선물 상자"
            ),
            reactionContents: [
                ReactionContent(videoURL: URL(fileURLWithPath: "/reaction-1.mov")),
                ReactionContent(videoURL: URL(fileURLWithPath: "/reaction-2.mov"))
            ]
        )
    }
}

private struct TestStore {
    let container: ModelContainer
    let context: ModelContext
    let store: SwiftDataSurpriseProjectStore
}
