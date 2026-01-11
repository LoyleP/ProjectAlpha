import SwiftUI
import SwiftData

@main
struct ProjectAlphaApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: MoodEntry.self)
    }
}
