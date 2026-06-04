import SwiftData
import SwiftUI

@main
struct ZimizipApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(
            for: [
                SurpriseProject.self,
                Content.self,
                Media.self,
                ReactionContent.self
            ]
        )
    }
}
