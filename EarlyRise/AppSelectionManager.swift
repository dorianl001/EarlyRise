import Foundation
import FamilyControls
import ManagedSettings
import DeviceActivity

@Observable
@MainActor
class AppSelectionManager {
    
    static let shared = AppSelectionManager()
    
    var activitySelection = FamilyActivitySelection() {
        didSet {
            saveSelection()
        }
    }
    
    var hasSelectedApps: Bool {
        !activitySelection.applicationTokens.isEmpty ||
        !activitySelection.categoryTokens.isEmpty
    }
    
    private let store = ManagedSettingsStore()
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    private let defaults = UserDefaults(suiteName: "group.com.dorianlopez.earlyrise")
    
    init() {
        loadSelection()
    }
    
    // MARK: - Apply Shields
    func applyShields() {
        let appTokens = activitySelection.applicationTokens
        let categoryTokens = activitySelection.categoryTokens
        
        store.shield.applications = appTokens.isEmpty ? nil : appTokens
        store.shield.applicationCategories = categoryTokens.isEmpty ? nil : .specific(categoryTokens)
    }
    
    // MARK: - Remove Shields
    func removeShields() {
        store.shield.applications = nil
        store.shield.applicationCategories = nil
    }
    
    // MARK: - Persist Selection
    private func saveSelection() {
        if let encoded = try? encoder.encode(activitySelection) {
            defaults?.set(encoded, forKey: "selectedApps")
        }
    }
    
    private func loadSelection() {
        if let data = defaults?.data(forKey: "selectedApps"),
           let decoded = try? decoder.decode(FamilyActivitySelection.self, from: data) {
            activitySelection = decoded
        }
    }
}
