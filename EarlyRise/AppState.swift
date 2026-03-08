//
//  AppState.swift
//  EarlyRise
//
//  Created by Dorian Lopez on 3/8/26.
//

import SwiftUI

@Observable
class AppState {
    var tasks: [EarnTask] = defaultTasks
    var scrollTimeEarned: Int = 0
    var scrollTimeUsed: Int = 0
    var tasksCompletedToday: Int = 0
    var currentStreak: Int = 5
    var bestStreak: Int = 11
    
    var timeReclaimed: Int {
        scrollTimeEarned - scrollTimeUsed
    }
    
    var totalTasks: Int {
        tasks.count
    }
    
    func completeTask(_ task: EarnTask) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index].isCompleted = true
            scrollTimeEarned += task.minutesEarned
            tasksCompletedToday += 1
        }
    }
    
    func resetDailyTasks() {
        for index in tasks.indices {
            tasks[index].isCompleted = false
        }
        tasksCompletedToday = 0
        scrollTimeEarned = 0
        scrollTimeUsed = 0
    }
}
