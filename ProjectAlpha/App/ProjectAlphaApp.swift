import SwiftUI
import SwiftData

@main
struct ProjectAlphaApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        // This line tells the app to set up storage for our MoodEntry model
        .modelContainer(for: MoodEntry.self)
    }
}
