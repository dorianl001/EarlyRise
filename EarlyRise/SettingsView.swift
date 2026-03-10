//
//  SettingsView.swift
//  EarlyRise
//
//  Created by Dorian Lopez on 3/9/26.
//

import SwiftUI

struct SettingsView: View {
    var appState: AppState
    @AppStorage("dailyScrollBudget") var dailyScrollBudget: Int = 30
    @AppStorage("notificationsEnabled") var notificationsEnabled: Bool = true
    @AppStorage("streakReminderEnabled") var streakReminderEnabled: Bool = true
    @AppStorage("morningNudgeEnabled") var morningNudgeEnabled: Bool = false
    @State private var showingResetAlert = false

    var body: some View {
        NavigationStack {
            List {

                // ── Scroll Budget ────────────────────────────
                Section {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Daily Scroll Budget")
                                .font(.headline)
                            Spacer()
                            Text("\(dailyScrollBudget) min")
                                .fontWeight(.semibold)
                                .foregroundStyle(.blue)
                        }
                        Slider(value: Binding(
                            get: { Double(dailyScrollBudget) },
                            set: { dailyScrollBudget = Int($0) }
                        ), in: 10...120, step: 5)
                        .tint(.blue)
                        HStack {
                            Text("10 min")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Spacer()
                            Text("2 hours")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, 8)
                } header: {
                    Label("Scroll Budget", systemImage: "clock.badge.checkmark")
                } footer: {
                    Text("Complete tasks to earn time beyond your daily budget.")
                }

                // ── Notifications ────────────────────────────
                Section {
                    Toggle(isOn: $notificationsEnabled) {
                        Label("Enable Notifications", systemImage: "bell.fill")
                    }
                    .tint(.blue)

                    if notificationsEnabled {
                        Toggle(isOn: $streakReminderEnabled) {
                            VStack(alignment: .leading, spacing: 2) {
                                Label("Streak Reminder", systemImage: "flame.fill")
                                Text("Reminds you at 8PM if streak is at risk")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .tint(.orange)

                        Toggle(isOn: $morningNudgeEnabled) {
                            VStack(alignment: .leading, spacing: 2) {
                                Label("Morning Nudge", systemImage: "sunrise.fill")
                                Text("Daily 8AM motivation with yesterday's stats")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .tint(.yellow)
                    }
                } header: {
                    Label("Notifications", systemImage: "bell")
                }

                // ── Stats Summary ────────────────────────────
                Section {
                    HStack {
                        Label("Current Streak", systemImage: "flame.fill")
                            .foregroundStyle(.orange)
                        Spacer()
                        Text("\(appState.currentStreak) days")
                            .foregroundStyle(.secondary)
                    }
                    HStack {
                        Label("Best Streak", systemImage: "trophy.fill")
                            .foregroundStyle(.yellow)
                        Spacer()
                        Text("\(appState.bestStreak) days")
                            .foregroundStyle(.secondary)
                    }
                    HStack {
                        Label("Total Earned Today", systemImage: "clock.fill")
                            .foregroundStyle(.blue)
                        Spacer()
                        Text("\(appState.scrollTimeEarned) min")
                            .foregroundStyle(.secondary)
                    }
                } header: {
                    Label("Today's Summary", systemImage: "chart.bar")
                }

                // ── Reset ────────────────────────────────────
                Section {
                    Button(role: .destructive) {
                        showingResetAlert = true
                    } label: {
                        Label("Reset Today's Progress", systemImage: "arrow.counterclockwise")
                    }
                } header: {
                    Label("Reset", systemImage: "trash")
                } footer: {
                    Text("This resets today's tasks and scroll time. Your streak will not be affected.")
                }

            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .alert("Reset Today?", isPresented: $showingResetAlert) {
                Button("Reset", role: .destructive) {
                    appState.resetDailyTasks()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This will reset all tasks and scroll time earned today. Your streak will not be affected.")
            }
        }
    }
}

#Preview {
    SettingsView(appState: AppState())
}
