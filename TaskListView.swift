import SwiftUI
import SwiftData

struct TaskListView: View {
    @Environment(\.dismiss) var dismiss
    var appState: AppState
    @Environment(\.modelContext) var modelContext
    @State private var showingCompletionAlert = false
    @State private var selectedTask: EarnTask?
    @State private var showingPaywall = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    headerBanner
                    ForEach(Array(appState.tasks.enumerated()), id: \.element.id) { index, task in
                        let isLocked = !appState.isPremium && index >= 3
                        TaskCard(task: task, isLocked: isLocked) {
                            if isLocked {
                                showingPaywall = true
                            } else {
                                selectedTask = task
                                showingCompletionAlert = true
                            }
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
                        print("completeTask being called")
                        appState.completeTask(task, context: modelContext)
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("You earned \(selectedTask?.minutesEarned ?? 0) minutes of scroll time for completing \(selectedTask?.name ?? "")!")
            }
            .sheet(isPresented: $showingPaywall) {
                PaywallView(appState: appState)
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
            if !appState.isPremium {
                Text("3 of 6 free")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.orange)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.orange.opacity(0.1))
                    .clipShape(Capsule())
            }
        }
        .padding()
        .background(.blue.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

struct TaskCard: View {
    var task: EarnTask
    var isLocked: Bool
    let onComplete: () -> Void

    var body: some View {
        HStack(spacing: 16) {
            Text(task.icon)
                .font(.system(size: 36))
                .frame(width: 56, height: 56)
                .background(isLocked ? Color.gray.opacity(0.1) : (task.isCompleted ? Color.green.opacity(0.15) : Color.blue.opacity(0.1)))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            VStack(alignment: .leading, spacing: 4) {
                Text(task.name)
                    .font(.headline)
                    .strikethrough(task.isCompleted)
                    .foregroundStyle(isLocked ? .secondary : (task.isCompleted ? .secondary : .primary))
                Text(task.description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(isLocked ? "Premium only" : "+\(task.minutesEarned) min scroll")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(isLocked ? .orange : .blue)
            }
            Spacer()
            Button {
                onComplete()
            } label: {
                Image(systemName: isLocked ? "lock.fill" : (task.isCompleted ? "checkmark.circle.fill" : "circle"))
                    .font(.title2)
                    .foregroundStyle(isLocked ? .orange : (task.isCompleted ? .green : .blue))
            }
            .disabled(task.isCompleted && !isLocked)
        }
        .padding()
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 8, y: 2)
        .opacity(isLocked ? 0.6 : (task.isCompleted ? 0.7 : 1.0))
    }
}

#Preview {
    TaskListView(appState: AppState())
}
