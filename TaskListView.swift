import SwiftUI

struct TaskListView: View {
    @Environment(\.dismiss) var dismiss
    var appState: AppState
    @Environment(\.modelContext) var modelContext
    @State private var showingCompletionAlert = false
    @State private var selectedTask: EarnTask?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    headerBanner
                    ForEach(appState.tasks) { task in
                        TaskCard(task: task) {
                            selectedTask = task
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
                Button("Claim \(selectedTask?.minutesEarned ?? 0) Minutes") {
                    if let task = selectedTask {
                        appState.completeTask(task, context: modelContext)
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("You earned \(selectedTask?.minutesEarned ?? 0) minutes of scroll time for completing \(selectedTask?.name ?? "")!")
            }
        }
    }

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
}

struct TaskCard: View {
    var task: EarnTask
    let onComplete: () -> Void

    var body: some View {
        HStack(spacing: 16) {
            Text(task.icon)
                .font(.system(size: 36))
                .frame(width: 56, height: 56)
                .background(task.isCompleted ? Color.green.opacity(0.15) : Color.blue.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))
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

#Preview {
    TaskListView(appState: AppState())
}
