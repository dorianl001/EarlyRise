import Foundation
import UserNotifications

@MainActor
class NotificationManager {
    
    static let shared = NotificationManager()
    
    // MARK: - Request Permission
    func requestPermission() async -> Bool {
        do {
            let granted = try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .sound, .badge])
            print("Notification permission granted: \(granted)")
            return granted
        } catch {
            print("Notification permission error: \(error)")
            return false
        }
    }
    
    // MARK: - Schedule Morning Nudge
    func scheduleMorningNudge(streak: Int, tasksCompleted: Int, minutesReclaimed: Int) {
        let center = UNUserNotificationCenter.current()
        
        // Remove any existing morning nudge
        center.removePendingNotificationRequests(withIdentifiers: ["morningNudge"])
        
        // Build the message
        let messages = [
            "🌅 Rise and earn! Yesterday you reclaimed \(minutesReclaimed) min. Keep your \(streak)-day streak alive!",
            "🌅 Good morning! You completed \(tasksCompleted) task\(tasksCompleted == 1 ? "" : "s") yesterday. Today's a new chance to earn your scroll.",
            "🌅 Your \(streak)-day streak is waiting. Complete a task before you scroll today!",
            "🌅 Yesterday: \(minutesReclaimed) min reclaimed, \(tasksCompleted) task\(tasksCompleted == 1 ? "" : "s") done. Today: let's beat it. 💪",
        ]
        
        let message = messages[streak % messages.count]
        
        // Build notification content
        let content = UNMutableNotificationContent()
        content.title = "EarlyRise"
        content.body = message
        content.sound = .default
        
        // Schedule for 8AM daily
        var dateComponents = DateComponents()
        dateComponents.hour = 8
        dateComponents.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: dateComponents,
            repeats: true
        )
        
        let request = UNNotificationRequest(
            identifier: "morningNudge",
            content: content,
            trigger: trigger
        )
        
        center.add(request) { error in
            if let error = error {
                print("Failed to schedule morning nudge: \(error)")
            } else {
                print("Morning nudge scheduled for 8AM daily!")
            }
        }
    }
    
    // MARK: - Cancel Morning Nudge
    func cancelMorningNudge() {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: ["morningNudge"])
        print("Morning nudge cancelled.")
    }
}
