//
//  TaskListView.swift
//  EarlyRise
//
//  Created by Dorian Lopez on 3/7/26.
//

import SwiftUI

// MARK: - Task Model
struct EarnTask: Identifiable {
    let id = UUID()
    let name: String
    let description: String
    let minutesEarned: Int
    let icon: String
    var isCompleted: Bool = false
}

// MARK: - Task List View
struct TaskListView: View {
    @Environment(\.dismiss) var dismiss
    @State private var tasks = defaultTasks
    @State private var showingCompletionAlert = false
    @State private var completedTask: EarnTask?
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    
                    // ── Header Info ─────────────────────────────────
                    headerBanner
                    
                    // ── Task Cards ──────────────────────────────────
                    ForEach($tasks) { $task in
                        TaskCard(task: $task) {
                            completedTask = task
                            showingCompletionAlert = true
                        }
                    }
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Earn Scroll Time")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
            .alert("Task Complete! 🎉", isPresented: $showingCompletionAlert) {
                Button("Claim \(completedTask?.minutesEarned ?? 0) Minutes") {
                    markTaskComplete()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("You earned \(completedTask?.minutesEarned ?? 0) minutes of scroll time for completing \(completedTask?.name ?? "")!")
            }
        }
    }
    
    // MARK: - Header Banner
    var headerBanner: some View {
        HStack(spacing: 12) {
            Image(systemName: "bolt.fill")
                .font(.title2)
                .foregroundStyle(.yellow)
            VStack(alignment: .leading, spacing: 2) {
                Text("Complete a task")
                    .font(.headline)
                Text("Earn scroll time for real-world actions")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding()
        .background(.blue.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    // MARK: - Mark Task Complete
    func markTaskComplete() {
        guard let completed = completedTask else { return }
        if let index = tasks.firstIndex(where: { $0.id == completed.id }) {
            tasks[index].isCompleted = true
        }
    }
}

// MARK: - Task Card
struct TaskCard: View {
    @Binding var task: EarnTask
    let onComplete: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            
            // Icon
            Text(task.icon)
                .font(.system(size: 36))
                .frame(width: 56, height: 56)
                .background(task.isCompleted ? Color.green.opacity(0.15) : Color.blue.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            
            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(task.name)
                    .font(.headline)
                    .strikethrough(task.isCompleted)
                    .foregroundStyle(task.isCompleted ? .secondary : .primary)
                Text(task.description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text("+\(task.minutesEarned) min scroll")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.blue)
            }
            
            Spacer()
            
            // Action Button
            Button {
                onComplete()
            } label: {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundStyle(task.isCompleted ? .green : .blue)
            }
            .disabled(task.isCompleted)
        }
        .padding()
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 8, y: 2)
        .opacity(task.isCompleted ? 0.7 : 1.0)
    }
}

// MARK: - Default Tasks
let defaultTasks: [EarnTask] = [
    EarnTask(name: "Walk 5 Minutes", description: "Step outside for a quick walk", minutesEarned: 10, icon: "🚶"),
    EarnTask(name: "Drink Water", description: "Drink a full glass of water", minutesEarned: 5, icon: "💧"),
    EarnTask(name: "Stretch", description: "Stretch for 2 minutes", minutesEarned: 10, icon: "🧘"),
    EarnTask(name: "Read", description: "Read for 5 minutes", minutesEarned: 10, icon: "📖"),
    EarnTask(name: "Clean Something", description: "Tidy up your space", minutesEarned: 10, icon: "🧹"),
    EarnTask(name: "Deep Breaths", description: "Take 10 slow deep breaths", minutesEarned: 5, icon: "🌬️")
]

// MARK: - Preview
#Preview {
    TaskListView()
}
