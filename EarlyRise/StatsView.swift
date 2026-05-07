import SwiftUI
import SwiftData

struct StatsView: View {
    var appState: AppState
    @Query private var allCompletions: [TaskCompletion]
    @State private var selectedTab = 0
    @State private var showingPaywall = false
    let tabs = ["Today", "Week", "Month", "Lifetime"]

    var todayCompletions: [TaskCompletion] { TaskCompletion.filterToday(allCompletions) }
    var weekCompletions: [TaskCompletion] { TaskCompletion.filterThisWeek(allCompletions) }
    var monthCompletions: [TaskCompletion] { TaskCompletion.filterThisMonth(allCompletions) }

    var currentCompletions: [TaskCompletion] {
        switch selectedTab {
        case 0: return todayCompletions
        case 1: return weekCompletions
        case 2: return monthCompletions
        default: return allCompletions
        }
    }

    var currentMinutes: Int { TaskCompletion.totalMinutes(currentCompletions) }
    var currentTaskCount: Int { currentCompletions.count }

    var body: some View {
        NavigationStack {
            if !appState.isPremium {
                ScrollView {
                    VStack(spacing: 24) {
                        VStack(spacing: 16) {
                            Image(systemName: "chart.bar.fill")
                                .font(.system(size: 60))
                                .foregroundStyle(.blue.opacity(0.3))
                            Text("Advanced Stats")
                                .font(.title2)
                                .fontWeight(.bold)
                            Text("Track your progress over time with weekly, monthly, and lifetime stats.")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        .padding(.top, 60)

                        Button {
                            showingPaywall = true
                        } label: {
                            HStack {
                                Image(systemName: "crown.fill")
                                Text("Unlock with Premium")
                                    .fontWeight(.semibold)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(.blue)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                        .padding(.horizontal)
                    }
                }
                .background(Color(.systemGroupedBackground))
                .navigationTitle("Your Progress")
                .navigationBarTitleDisplayMode(.large)
                .sheet(isPresented: $showingPaywall) {
                    PaywallView(appState: appState)
                }
            } else {
                ScrollView {
                    VStack(spacing: 24) {
                        heroMetric
                        tabSelector
                        statsCards
                        streakSection
                    }
                    .padding()
                }
                .background(Color(.systemGroupedBackground))
                .navigationTitle("Your Progress")
                .navigationBarTitleDisplayMode(.large)
            }
        }
    }

    var heroMetric: some View {
        VStack(spacing: 8) {
            Text("⏱️")
                .font(.system(size: 56))
            Text(formatTime(currentMinutes))
                .font(.system(size: 48, weight: .bold, design: .rounded))
                .foregroundStyle(.blue)
            Text("reclaimed \(tabLabel)")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .shadow(color: .black.opacity(0.05), radius: 8, y: 2)
    }

    var tabLabel: String {
        switch selectedTab {
        case 0: return "today"
        case 1: return "this week"
        case 2: return "this month"
        default: return "lifetime"
        }
    }

    var tabSelector: some View {
        HStack(spacing: 0) {
            ForEach(tabs.indices, id: \.self) { index in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedTab = index
                    }
                } label: {
                    Text(tabs[index])
                        .font(.subheadline)
                        .fontWeight(selectedTab == index ? .semibold : .regular)
                        .foregroundStyle(selectedTab == index ? .white : .secondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(selectedTab == index ? Color.blue : Color.clear)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
        }
        .padding(4)
        .background(Color(.systemGray5))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    var statsCards: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
            statCard(icon: "checkmark.circle.fill", value: "\(currentTaskCount)", label: "Tasks Done", color: .green)
            statCard(icon: "clock.fill", value: "\(currentMinutes) min", label: "Scroll Earned", color: .blue)
            statCard(icon: "heart.fill", value: formatTime(currentMinutes), label: "Reclaimed", color: .pink)
            statCard(icon: "trophy.fill", value: "\(appState.bestStreak) days", label: "Best Streak", color: .orange)
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

    var streakSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Streak")
                    .font(.headline)
                Spacer()
            }
            HStack(spacing: 16) {
                streakCard(value: appState.currentStreak, label: "Current", icon: "🔥")
                streakCard(value: appState.bestStreak, label: "Best", icon: "🏆")
            }
        }
    }

    func streakCard(value: Int, label: String, icon: String) -> some View {
        VStack(spacing: 8) {
            Text(icon)
                .font(.system(size: 32))
            Text("\(value)")
                .font(.title)
                .fontWeight(.bold)
            Text("\(label) Streak")
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value == 1 ? "day" : "days")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 8, y: 2)
    }

    func formatTime(_ minutes: Int) -> String {
        if minutes < 60 {
            return "\(minutes)m"
        } else {
            let hours = minutes / 60
            let mins = minutes % 60
            return mins == 0 ? "\(hours)h" : "\(hours)h \(mins)m"
        }
    }
}

#Preview {
    StatsView(appState: AppState())
        .modelContainer(for: TaskCompletion.self, inMemory: true)
}
