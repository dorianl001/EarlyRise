import SwiftUI
import FamilyControls

struct LockedAppsView: View {
    var appState: AppState
    @State private var appSelection = AppSelectionManager.shared
    @State private var isPickerPresented = false
    @State private var showingLimitAlert = false
    @State private var showingPaywall = false
    @State private var previousSelection = FamilyActivitySelection()

    var body: some View {
        NavigationStack {
            List {
                // MARK: - Current Selection Status
                Section {
                    if appSelection.hasSelectedApps {
                        HStack {
                            Image(systemName: "lock.shield.fill")
                                .foregroundStyle(.blue)
                            Text("Apps selected")
                                .foregroundStyle(.primary)
                            Spacer()
                            Text("Tap 'Edit' to change")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    } else {
                        VStack(spacing: 12) {
                            Image(systemName: "lock.open.fill")
                                .font(.system(size: 40))
                                .foregroundStyle(.secondary)
                            Text("No apps selected")
                                .font(.headline)
                                .foregroundStyle(.secondary)
                            Text("Tap 'Add Apps' to choose which apps EarlyRise will monitor.")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                    }
                } header: {
                    Label("Monitored Apps", systemImage: "lock.shield.fill")
                } footer: {
                    Text(appState.isPremium ? "EarlyRise will show the pause screen when you open these apps after your scroll budget runs out." : "Free users can monitor up to 2 apps. Upgrade to Premium for unlimited.")
                }

                // MARK: - Add / Edit / Clear Buttons
                Section {
                    Button {
                        isPickerPresented = true
                    } label: {
                        Label(
                            appSelection.hasSelectedApps ? "Edit Apps" : "Add Apps",
                            systemImage: appSelection.hasSelectedApps ? "pencil.circle.fill" : "plus.circle.fill"
                        )
                        .foregroundStyle(.blue)
                    }

                    if appSelection.hasSelectedApps {
                        Button(role: .destructive) {
                            appSelection.activitySelection = FamilyActivitySelection()
                            appSelection.removeShields()
                        } label: {
                            Label("Remove All Apps", systemImage: "trash.fill")
                        }
                    }
                }
            }
            .navigationTitle("Locked Apps")
            .navigationBarTitleDisplayMode(.large)
            .familyActivityPicker(
                isPresented: $isPickerPresented,
                selection: $appSelection.activitySelection
            )
            .onChange(of: appSelection.activitySelection) { _, newValue in
                if !appState.isPremium {
                    let count = newValue.applications.count + newValue.categories.count
                    if count > 2 {
                        appSelection.activitySelection = previousSelection
                        showingLimitAlert = true
                    } else {
                        previousSelection = newValue
                    }
                } else {
                    previousSelection = newValue
                }
            }
            .alert("Free Plan Limit", isPresented: $showingLimitAlert) {
                Button("Upgrade to Premium") { showingPaywall = true }
                Button("OK", role: .cancel) {}
            } message: {
                Text("Free users can monitor up to 2 apps. Upgrade to Premium to monitor unlimited apps.")
            }
            .sheet(isPresented: $showingPaywall) {
                PaywallView(appState: appState)
            }
        }
    }
}

#Preview {
    LockedAppsView(appState: AppState())
}
