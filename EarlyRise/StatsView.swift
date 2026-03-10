//
//  StatsView.swift
//  EarlyRise
//
//  Created by Dorian Lopez on 3/9/26.
//

import SwiftUI

struct StatsView: View {
    var appState: AppState
    @State private var selectedTab = 0
    let tabs = ["Today", "Week", "Month", "Lifetime"]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {

                    // ── Hero Metric ──────────────────────────────────
                    heroMetric

                    // ── Tab Selector ─────────────────────────────────
                    tabSelector

                    // ── Stats Cards ──────────────────────────────────
                    statsCards

                    // ── Streak Section ───────────────────────────────
                    streakSection

                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Your Progress")
            .navigationBarTitleDisplayMode(.large)
        }
    }

    // MARK: - Hero Metric
    var heroMetric: some View {
        VStack(spacing: 8) {
            Text("⏱️")
                .font(.system(size: 56))
            Text(formatTime(appState.scrollTimeEarned))
                .font(.system(size: 48, weight: .bold, design: .rounded))
                .foregroundStyle(.blue)
            Text("reclaimed today")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .shadow(color: .black.opacity(0.05), radius: 8, y: 2)
    }

    // MARK: - Tab Selector
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

    // MARK: - Stats Cards
    var statsCards: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
            statCard(
                icon: "checkmark.circle.fill",
                value: "\(appState.tasksCompletedToday)",
                label: "Tasks Done",
                color: .green
            )
            statCard(
                icon: "clock.fill",
                value: "\(appState.scrollTimeEarned) min",
                label: "Scroll Earned",
                color: .blue
            )
            statCard(
                icon: "iphone.slash",
                value: "\(appState.scrollTimeUsed) min",
                label: "Scroll Used",
                color: .purple
            )
            statCard(
                icon: "heart.fill",
                value: formatTime(appState.timeReclaimed),
                label: "Reclaimed",
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

    // MARK: - Streak Section
    var streakSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Streak")
                    .font(.headline)
                Spacer()
            }

            HStack(spacing: 16) {
                streakCard(
                    value: appState.currentStreak,
                    label: "Current",
                    icon: "🔥"
                )
                streakCard(
                    value: appState.bestStreak,
                    label: "Best",
                    icon: "🏆"
                )
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

    // MARK: - Helper
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
}
