import SwiftUI
import StoreKit

struct SettingsView: View {
    var appState: AppState
    @AppStorage("dailyScrollBudget") var dailyScrollBudget: Int = 30
    @AppStorage("notificationsEnabled") var notificationsEnabled: Bool = true
    @AppStorage("streakReminderEnabled") var streakReminderEnabled: Bool = true
    @AppStorage("morningNudgeEnabled") var morningNudgeEnabled: Bool = false
    @AppStorage("morningNudgeTime") var morningNudgeTime: Double = 8 * 3600
    private var screenTimeService = ScreenTimeService.shared
    @State private var showingResetAlert = false
    @State private var showingPaywall = false

    init(appState: AppState) {
        self.appState = appState
    }

    var body: some View {
        NavigationStack {
            List {

                // ── Premium ──────────────────────────────────────────────────────────
                if !appState.isPremium {
                    Section {
                        NavigationLink {
                            PaywallView(appState: appState)
                        } label: {
                            HStack {
                                Label("Upgrade to Premium", systemImage: "star.fill")
                                    .foregroundStyle(.orange)
                                Spacer()
                                Text("$2.99/mo")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    } header: {
                        Label("Premium", systemImage: "crown.fill")
                    } footer: {
                        Text("Unlock all features for $2.99/month or save with $19.99/year.")
                    }
                }

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
                    Toggle(isOn: Binding(
                        get: { morningNudgeEnabled },
                        set: { newValue in
                            if !appState.isPremium {
                                showingPaywall = true
                                return
                            }
                            morningNudgeEnabled = newValue
                            Task {
                                if newValue {
                                    let granted = await NotificationManager.shared.requestPermission()
                                    if granted {
                                        let time = Date(timeIntervalSince1970: morningNudgeTime)
                                        NotificationManager.shared.scheduleMorningNudge(
                                            streak: appState.currentStreak,
                                            tasksCompleted: appState.tasksCompletedToday,
                                            minutesReclaimed: appState.timeReclaimed,
                                            time: time
                                        )
                                    } else {
                                        morningNudgeEnabled = false
                                    }
                                } else {
                                    NotificationManager.shared.cancelMorningNudge()
                                }
                            }
                        }
                    )) {
                        VStack(alignment: .leading, spacing: 2) {
                            HStack {
                                Label("Morning Nudge", systemImage: "sunrise.fill")
                                if !appState.isPremium {
                                    Image(systemName: "lock.fill")
                                        .font(.caption)
                                        .foregroundStyle(.orange)
                                }
                            }
                            Text("Daily motivation with yesterday's stats")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .tint(.yellow)

                    if morningNudgeEnabled && appState.isPremium {
                        DatePicker(
                            "Nudge Time",
                            selection: Binding(
                                get: { Date(timeIntervalSince1970: morningNudgeTime) },
                                set: { newTime in
                                    morningNudgeTime = newTime.timeIntervalSince1970
                                    let time = Date(timeIntervalSince1970: morningNudgeTime)
                                    NotificationManager.shared.scheduleMorningNudge(
                                        streak: appState.currentStreak,
                                        tasksCompleted: appState.tasksCompletedToday,
                                        minutesReclaimed: appState.timeReclaimed,
                                        time: time
                                    )
                                }
                            ),
                            displayedComponents: .hourAndMinute
                        )
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

                // ── Locked Apps ──────────────────────────────────────────────────────
                Section {
                    NavigationLink {
                        LockedAppsView()
                    } label: {
                        Label("Locked Apps", systemImage: "lock.shield.fill")
                    }
                } header: {
                    Label("App Management", systemImage: "apps.iphone")
                } footer: {
                    Text("Choose which apps EarlyRise monitors when your scroll budget runs out.")
                }

                // ── Screen Time ──────────────────────────────────────────────────────
                Section {
                    if screenTimeService.isAuthorized {
                        if screenTimeService.isMonitoring {
                            Button(role: .destructive) {
                                screenTimeService.stopMonitoring()
                            } label: {
                                Label("Stop Monitoring", systemImage: "pause.circle.fill")
                            }
                        } else {
                            Button {
                                screenTimeService.startMonitoring()
                            } label: {
                                Label("Start Monitoring", systemImage: "play.circle.fill")
                            }
                        }
                    } else {
                        Button {
                            Task {
                                await screenTimeService.requestAuthorization()
                            }
                        } label: {
                            Label("Enable Screen Time", systemImage: "lock.shield.fill")
                        }
                    }
                } header: {
                    Label("Screen Time", systemImage: "hourglass")
                } footer: {
                    Text(screenTimeService.isAuthorized ? "EarlyRise will show a pause screen when you open social apps." : "Enable Screen Time access to activate the pause screen feature.")
                }

                // ── Reset ────────────────────────────────────────────────────────────
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
            .sheet(isPresented: $showingPaywall) {
                PaywallView(appState: appState)
            }
        }
    }
}

#Preview {
    SettingsView(appState: AppState())
}
