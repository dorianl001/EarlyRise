import DeviceActivity
import ManagedSettings
import Foundation

class DeviceActivityMonitorExtension: DeviceActivityMonitor {

    let store = ManagedSettingsStore()
    let sharedDefaults = UserDefaults(suiteName: "group.com.dorianlopez.earlyrise")

    override func intervalDidStart(for activity: DeviceActivityName) {
        super.intervalDidStart(for: activity)
        checkAndApplyShields()
    }

    override func intervalDidEnd(for activity: DeviceActivityName) {
        super.intervalDidEnd(for: activity)
        store.shield.applicationCategories = nil
        store.shield.webDomainCategories = nil
    }

    override func eventDidReachThreshold(_ event: DeviceActivityEvent.Name, activity: DeviceActivityName) {
        super.eventDidReachThreshold(event, activity: activity)
        checkAndApplyShields()
    }

    // MARK: - Check Unlock Expiry
    private func checkAndApplyShields() {
        if let unlockExpiry = sharedDefaults?.object(forKey: "unlockExpiry") as? Date {
            if Date() < unlockExpiry {
                // Still within unlock window — don't shield
                store.shield.applicationCategories = nil
                store.shield.webDomainCategories = nil
            } else {
                // Unlock expired — apply shields
                applyShields()
            }
        } else {
            // No unlock set — apply shields
            applyShields()
        }
    }

    private func applyShields() {
        store.shield.applicationCategories = .all()
        store.shield.webDomainCategories = .all()
    }
}
