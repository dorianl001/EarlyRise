import SwiftUI

struct ContentView: View {
    @Environment(AppState.self) var appState
    @State private var showingTasks = false
    @State private var selectedTab = 0
    @State private var showingPaywall = false

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
        .sheet(isPresented: $showingPaywall) {
            PaywallView(appState: appState)
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
            ZStack(alignment: .topTrailing) {
                statCard(
                    icon: "arrow.up.heart.fill",
                    value: appState.isTimeReclaimedAvailable ? "\(appState.timeReclaimed) min" : "🔒",
                    label: "Time Reclaimed",
                    color: .pink
                )
                .overlay {
                    if !appState.isTimeReclaimedAvailable {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(.ultraThinMaterial)
                        VStack(spacing: 4) {
                            Image(systemName: "lock.fill")
                                .foregroundStyle(.orange)
                            Text("Premium")
                                .font(.caption2)
                                .fontWeight(.semibold)
                                .foregroundStyle(.orange)
                        }
                        .onTapGesture {
                            showingPaywall = true
                        }
                    }
                }
                if appState.isTimeReclaimedAvailable {
                    Button {
                        shareTimeReclaimed()
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                            .font(.caption)
                            .foregroundStyle(.pink)
                            .padding(8)
                    }
                }
            }
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

    // MARK: - Share
    func shareTimeReclaimed() {
        let hours = appState.timeReclaimed / 60
        let minutes = appState.timeReclaimed % 60

        let timeString: String
        if hours > 0 && minutes > 0 {
            timeString = "\(hours)h \(minutes)m"
        } else if hours > 0 {
            timeString = "\(hours) hour\(hours == 1 ? "" : "s")"
        } else {
            timeString = "\(minutes) minute\(minutes == 1 ? "" : "s")"
        }

        let message = "I just reclaimed \(timeString) of my time using EarlyRise — the app that makes you EARN your scroll time 🌅 #EarlyRise #EarnYourScroll"

        let activityVC = UIActivityViewController(
            activityItems: [message],
            applicationActivities: nil
        )

        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first,
           let rootVC = window.rootViewController {
            rootVC.present(activityVC, animated: true)
        }
    }
}

#Preview {
    ContentView()
        .environment(AppState())
}
