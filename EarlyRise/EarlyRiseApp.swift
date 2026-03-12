import SwiftUI
import SwiftData

@main
struct EarlyRiseApp: App {
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding: Bool = false

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([TaskCompletion.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            if hasCompletedOnboarding {
                ContentView()
            } else {
                OnboardingView()
            }
        }
        .modelContainer(sharedModelContainer)
    }
}
