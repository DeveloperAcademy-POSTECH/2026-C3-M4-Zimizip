import SwiftData
import UIKit

enum ArchivePreviewData {
    static func reactionDisplayItem() -> ArchiveDisplayItem {
        let project = surpriseProject()

        return ArchiveDisplayItem(
            surpriseProject: project,
            title: project.name,
            count: "동영상 \(project.reactionContents.count)개",
            thumbnail: .reaction(
                thumbnailData: project.reactionContents.compactMap(\.thumbnailData),
                overlayText: "+1"
            )
        )
    }

    static func surpriseCardDisplayItem() -> ArchiveDisplayItem {
        let project = surpriseProject()

        return ArchiveDisplayItem(
            surpriseProject: project,
            title: project.name,
            count: "동영상 \(project.reactionContents.count)개",
            thumbnail: .surpriseCard(coverImageName: "HomeSurpriseCardCenter")
        )
    }

    static func surpriseProject() -> SurpriseProject {
        SurpriseProject(
            name: "서프라이즈 프로젝트",
            content: Content(
                media: Media(source: imageData(color: .systemOrange)),
                box: "HomeSurpriseCardCenter"
            ),
            reactionContents: [
                ReactionContent(
                    videoURL: URL(fileURLWithPath: "/reaction-1.mov"),
                    thumbnailData: imageData(color: .systemBlue),
                    createdAt: Date(timeIntervalSince1970: 1_747_628_580)
                ),
                ReactionContent(
                    videoURL: URL(fileURLWithPath: "/reaction-2.mov"),
                    thumbnailData: imageData(color: .systemPink),
                    createdAt: Date(timeIntervalSince1970: 1_747_628_640)
                ),
                ReactionContent(
                    videoURL: URL(fileURLWithPath: "/reaction-3.mov"),
                    thumbnailData: imageData(color: .systemGreen),
                    createdAt: Date(timeIntervalSince1970: 1_747_628_700)
                )
            ]
        )
    }

    @MainActor
    static func modelContainer() -> ModelContainer {
        do {
            let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(
                for: SurpriseProject.self,
                Content.self,
                Media.self,
                ReactionContent.self,
                configurations: configuration
            )

            container.mainContext.insert(surpriseProject())
            return container
        } catch {
            fatalError("Failed to create archive preview model container: \(error)")
        }
    }

    static func imageData(color: UIColor) -> Data {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 240, height: 360))
        let image = renderer.image { context in
            color.setFill()
            context.fill(CGRect(x: 0, y: 0, width: 240, height: 360))
        }

        return image.jpegData(compressionQuality: 0.85) ?? Data()
    }
}
