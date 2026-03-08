//
//  EarnTask.swift
//  EarlyRise
//
//  Created by Dorian Lopez on 3/8/26.
//

import Foundation

struct EarnTask: Identifiable {
    let id = UUID()
    let name: String
    let description: String
    let minutesEarned: Int
    let icon: String
    var isCompleted: Bool = false
}

let defaultTasks: [EarnTask] = [
    EarnTask(name: "Walk 5 Minutes", description: "Step outside for a quick walk", minutesEarned: 10, icon: "🚶"),
    EarnTask(name: "Drink Water", description: "Drink a full glass of water", minutesEarned: 5, icon: "💧"),
    EarnTask(name: "Stretch", description: "Stretch for 2 minutes", minutesEarned: 10, icon: "🧘"),
    EarnTask(name: "Read", description: "Read for 5 minutes", minutesEarned: 10, icon: "📖"),
    EarnTask(name: "Clean Something", description: "Tidy up your space", minutesEarned: 10, icon: "🧹"),
    EarnTask(name: "Deep Breaths", description: "Take 10 slow deep breaths", minutesEarned: 5, icon: "🌬️")
]
