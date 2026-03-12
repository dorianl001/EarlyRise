import Foundation
import ActivityKit

// MARK: - Live Activity Attributes
struct EarlyRiseActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var unlockExpiryDate: Date
        var minutesEarned: Int
        var taskName: String
    }
    var appName: String
}

// MARK: - Live Activity Manager
@MainActor
class LiveActivityManager {

    static let shared = LiveActivityManager()
    private var currentActivity: Activity<EarlyRiseActivityAttributes>?

    // MARK: - Start Live Activity
    func startActivity(taskName: String, minutesEarned: Int) {
        let activityInfo = ActivityAuthorizationInfo()
        guard activityInfo.areActivitiesEnabled else {
            return
        }

        let unlockExpiry = Date().addingTimeInterval(TimeInterval(minutesEarned * 60))
        let attributes = EarlyRiseActivityAttributes(appName: "EarlyRise")
        let contentState = EarlyRiseActivityAttributes.ContentState(
            unlockExpiryDate: unlockExpiry,
            minutesEarned: minutesEarned,
            taskName: taskName
        )

        do {
            let content = ActivityContent(
                state: contentState,
                staleDate: unlockExpiry,
                relevanceScore: 100
            )
            currentActivity = try Activity.request(
                attributes: attributes,
                content: content
            )
        } catch {
            print("Error: \(error)")
        }
    }

    // MARK: - Stop Live Activity
    func stopActivity() async {
        guard let activity = currentActivity else { return }

        let finalState = EarlyRiseActivityAttributes.ContentState(
            unlockExpiryDate: Date(),
            minutesEarned: 0,
            taskName: "Time's up!"
        )

        let content = ActivityContent(state: finalState, staleDate: Date())
        await activity.end(content, dismissalPolicy: .immediate)
        currentActivity = nil
    }
}
