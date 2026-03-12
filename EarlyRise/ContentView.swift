import SwiftUI
import ActivityKit

struct ContentView: View {
    @State private var appState = AppState()
    @State private var showingTasks = false
    @State private var selectedTab = 0
    @State private var showActivityAlert: String? = nil

    var body: some View {
        TabView(selection: $selectedTab) {
            homeTab
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(0)

            StatsView(appState: appState)
                .tabItem {
                    Label("Stats", systemImage: "chart.bar.fill")
                }
                .tag(1)

            SettingsView(appState: appState)
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
                .tag(2)
        }
        .sheet(isPresented: $showingTasks) {
            TaskListView(appState: appState)
        }
    }

    // MARK: - Home Tab
    var homeTab: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    headerSection
                    streakCard
                    statsGrid
                    testLiveActivityButton
                    earnButton
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarHidden(true)
        }
    }

    // MARK: - Header
    var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("EarlyRise")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(.blue)
                Text(Date().formatted(date: .long, time: .omitted))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            VStack {
                Text("🔥")
                    .font(.system(size: 36))
                Text("\(appState.currentStreak) days")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.orange)
            }
        }
        .padding()
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 8, y: 2)
    }

    // MARK: - Streak Card
    var streakCard: some View {
        HStack(spacing: 16) {
            streakStat(value: appState.currentStreak, label: "Current Streak", color: .orange)
            Divider().frame(height: 40)
            streakStat(value: appState.bestStreak, label: "Best Streak", color: .blue)
        }
        .padding()
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 8, y: 2)
    }

    func streakStat(value: Int, label: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Text("\(value)")
                .font(.title)
                .fontWeight(.bold)
                .foregroundStyle(color)
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Stats Grid
    var statsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
            statCard(
                icon: "checkmark.circle.fill",
                value: "\(appState.tasksCompletedToday)/\(appState.totalTasks)",
                label: "Tasks Completed",
                color: .green
            )
            statCard(
                icon: "clock.fill",
                value: "\(appState.scrollTimeEarned) min",
                label: "Scroll Earned",
                color: .blue
            )
            statCard(
                icon: "hourglass",
                value: "\(appState.scrollTimeUsed) min",
                label: "Scroll Used",
                color: .purple
            )
            statCard(
                icon: "arrow.up.heart.fill",
                value: "\(appState.timeReclaimed) min",
                label: "Time Reclaimed",
                color: .pink
            )
        }
    }

    func statCard(icon: String, value: String, label: String, color: Color) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 8, y: 2)
    }

    // MARK: - Test Live Activity Button (Temporary)
    var testLiveActivityButton: some View {
        Button {
            let enabled = ActivityAuthorizationInfo().areActivitiesEnabled
            showActivityAlert = enabled ? "✅ Enabled - starting..." : "❌ Not enabled"
            if enabled {
                LiveActivityManager.shared.startActivity(
                    taskName: "Test Task",
                    minutesEarned: 10
                )
            }
        } label: {
            HStack {
                Image(systemName: "bolt.fill")
                    .font(.title3)
                Text("Test Live Activity")
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(.orange)
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .alert("Live Activity Status", isPresented: .constant(showActivityAlert != nil)) {
            Button("OK") { showActivityAlert = nil }
        } message: {
            Text(showActivityAlert ?? "")
        }
    }

    // MARK: - Earn Button
    var earnButton: some View {
        Button {
            showingTasks = true
        } label: {
            HStack {
                Image(systemName: "plus.circle.fill")
                    .font(.title3)
                Text("Earn Scroll Time")
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(.blue)
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .shadow(color: .blue.opacity(0.3), radius: 8, y: 4)
    }
}

#Preview {
    ContentView()
}
