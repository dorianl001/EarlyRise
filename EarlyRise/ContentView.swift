import SwiftUI

// MARK: - Data Model
struct DailyStats {
    var tasksCompleted: Int = 0
    var totalTasks: Int = 5
    var scrollTimeEarned: Int = 0
    var scrollTimeUsed: Int = 0
    var currentStreak: Int = 5
    var bestStreak: Int = 11
    
    var timeReclaimed: Int {
        scrollTimeEarned - scrollTimeUsed
    }
}

// MARK: - Home Dashboard View
struct ContentView: View {
    @State private var stats = DailyStats()
    @State private var showingTasks = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    
                    // ── Header ──────────────────────────────────────
                    headerSection
                    
                    // ── Streak Card ─────────────────────────────────
                    streakCard
                    
                    // ── Stats Grid ──────────────────────────────────
                    statsGrid
                    
                    // ── Earn Scroll Button ──────────────────────────
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
            // Streak flame icon
            VStack {
                Text("🔥")
                    .font(.system(size: 36))
                Text("\(stats.currentStreak) days")
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
            streakStat(value: stats.currentStreak, label: "Current Streak", color: .orange)
            Divider().frame(height: 40)
            streakStat(value: stats.bestStreak, label: "Best Streak", color: .blue)
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
                value: "\(stats.tasksCompleted)/\(stats.totalTasks)",
                label: "Tasks Completed",
                color: .green
            )
            statCard(
                icon: "clock.fill",
                value: "\(stats.scrollTimeEarned) min",
                label: "Scroll Earned",
                color: .blue
            )
            statCard(
                icon: "hourglass",
                value: "\(stats.scrollTimeUsed) min",
                label: "Scroll Used",
                color: .purple
            )
            statCard(
                icon: "arrow.up.heart.fill",
                value: "\(stats.timeReclaimed) min",
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

// MARK: - Preview
#Preview {
    ContentView()
}
