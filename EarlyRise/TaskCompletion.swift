import Foundation
import SwiftData

@Model
class TaskCompletion {
    var taskName: String
    var minutesEarned: Int
    var completedAt: Date
    
    init(taskName: String, minutesEarned: Int, completedAt: Date = Date()) {
        self.taskName = taskName
        self.minutesEarned = minutesEarned
        self.completedAt = completedAt
    }
    
    // MARK: - Time Period Helpers
    static func totalMinutes(_ completions: [TaskCompletion]) -> Int {
        completions.reduce(0) { $0 + $1.minutesEarned }
    }
    
    static func filterToday(_ completions: [TaskCompletion]) -> [TaskCompletion] {
        let calendar = Calendar.current
        return completions.filter { calendar.isDateInToday($0.completedAt) }
    }
    
    static func filterThisWeek(_ completions: [TaskCompletion]) -> [TaskCompletion] {
        let calendar = Calendar.current
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: Date())?.start ?? Date()
        return completions.filter { $0.completedAt >= startOfWeek }
    }
    
    static func filterThisMonth(_ completions: [TaskCompletion]) -> [TaskCompletion] {
        let calendar = Calendar.current
        let startOfMonth = calendar.dateInterval(of: .month, for: Date())?.start ?? Date()
        return completions.filter { $0.completedAt >= startOfMonth }
    }
}
