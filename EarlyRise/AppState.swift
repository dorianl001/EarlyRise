import SwiftUI
import ManagedSettings

@Observable
class AppState {
    var tasks: [EarnTask] = defaultTasks
    var scrollTimeEarned: Int = 0
    var scrollTimeUsed: Int = 0
    var tasksCompletedToday: Int = 0
    var currentStreak: Int = 0
    var bestStreak: Int = 0

    private let calendar = Calendar.current

    init() {
        loadStreakData()
        checkForMissedDay()
    }

    var timeReclaimed: Int {
        scrollTimeEarned - scrollTimeUsed
    }

    var totalTasks: Int {
        tasks.count
    }

    // MARK: - Complete Task
    func completeTask(_ task: EarnTask) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index].isCompleted = true
            scrollTimeEarned += task.minutesEarned
            tasksCompletedToday += 1
            updateStreak()
            scheduleUnlock(minutes: task.minutesEarned)
        }
    }

    // MARK: - Schedule Unlock
    func scheduleUnlock(minutes: Int) {
        let unlockExpiry = Date().addingTimeInterval(TimeInterval(minutes * 60))
        let sharedDefaults = UserDefaults(suiteName: "group.com.dorianlopez.earlyrise")
        sharedDefaults?.set(unlockExpiry, forKey: "unlockExpiry")

        // Remove shields immediately
        let store = ManagedSettingsStore()
        store.shield.applicationCategories = nil
        store.shield.webDomainCategories = nil
    }

    // MARK: - Streak Logic
    private func updateStreak() {
        let today = Date()
        let lastCompletedDate = UserDefaults.standard.object(forKey: "lastCompletedDate") as? Date

        if let lastDate = lastCompletedDate {
            if calendar.isDateInToday(lastDate) {
                return
            } else if calendar.isDateInYesterday(lastDate) {
                currentStreak += 1
            } else {
                currentStreak = 1
            }
        } else {
            currentStreak = 1
        }

        if currentStreak > bestStreak {
            bestStreak = currentStreak
        }

        UserDefaults.standard.set(today, forKey: "lastCompletedDate")
        saveStreakData()
    }

    // MARK: - Check for Missed Day on App Launch
    private func checkForMissedDay() {
        guard let lastDate = UserDefaults.standard.object(forKey: "lastCompletedDate") as? Date else {
            return
        }
        if !calendar.isDateInToday(lastDate) && !calendar.isDateInYesterday(lastDate) {
            currentStreak = 0
            saveStreakData()
        }
    }

    // MARK: - Persist Streak Data
    private func saveStreakData() {
        UserDefaults.standard.set(currentStreak, forKey: "currentStreak")
        UserDefaults.standard.set(bestStreak, forKey: "bestStreak")
    }

    private func loadStreakData() {
        currentStreak = UserDefaults.standard.integer(forKey: "currentStreak")
        bestStreak = UserDefaults.standard.integer(forKey: "bestStreak")
    }

    // MARK: - Reset Daily Tasks
    func resetDailyTasks() {
        for index in tasks.indices {
            tasks[index].isCompleted = false
        }
        tasksCompletedToday = 0
        scrollTimeEarned = 0
        scrollTimeUsed = 0
    }
}
