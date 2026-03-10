import Foundation
import FamilyControls
import DeviceActivity
import ManagedSettings

@Observable
@MainActor
class ScreenTimeService {
    
    static let shared = ScreenTimeService()
    
    var isAuthorized = false
    var isMonitoring = false
    
    private let center = AuthorizationCenter.shared
    private let deviceActivityCenter = DeviceActivityCenter()
    private let store = ManagedSettingsStore()
    
    // MARK: - Request Authorization
    func requestAuthorization() async {
        do {
            try await center.requestAuthorization(for: .individual)
            isAuthorized = true
            print("Family Controls authorized!")
        } catch {
            print("Authorization failed: \(error)")
            isAuthorized = false
        }
    }
    
    // MARK: - Start Monitoring
    func startMonitoring() {
        let schedule = DeviceActivitySchedule(
            intervalStart: DateComponents(hour: 0, minute: 0),
            intervalEnd: DateComponents(hour: 23, minute: 59),
            repeats: true
        )
        
        do {
            try deviceActivityCenter.startMonitoring(
                .daily,
                during: schedule
            )
            isMonitoring = true
            print("Monitoring started!")
        } catch {
            print("Failed to start monitoring: \(error)")
        }
    }
    
    // MARK: - Stop Monitoring
    func stopMonitoring() {
        deviceActivityCenter.stopMonitoring([.daily])
        store.shield.applicationCategories = nil
        store.shield.webDomainCategories = nil
        isMonitoring = false
        print("Monitoring stopped!")
    }
    
    // MARK: - Unlock Apps
    func unlockApps() {
        store.shield.applicationCategories = nil
        store.shield.webDomainCategories = nil
    }
    
    // MARK: - Lock Apps
    func lockApps() {
        store.shield.applicationCategories = .all()
        store.shield.webDomainCategories = .all()
    }
}

// MARK: - DeviceActivityName Extension
extension DeviceActivityName {
    static let daily = Self("daily")
}
