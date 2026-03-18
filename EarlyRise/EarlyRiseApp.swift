import SwiftUI
import SwiftData

@main
struct EarlyRiseApp: App {
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding: Bool = false
    @Environment(\.scenePhase) var scenePhase

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
            let _ = print("🚀 EarlyRise app launched")
            if hasCompletedOnboarding {
                ContentView()
            } else {
                OnboardingView()
            }
        }
        .modelContainer(sharedModelContainer)
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                ScreenTimeService.shared.checkAuthorization()
            }
        }
    }
}
