import ManagedSettings
import UIKit

class ShieldActionExtension: ShieldActionDelegate {

    let store = ManagedSettingsStore()

    override func handle(action: ShieldAction, for application: ApplicationToken, completionHandler: @escaping (ShieldActionResponse) -> Void) {
        switch action {
        case .primaryButtonPressed:
            // "Earn Scroll Time" — close shield, user opens EarlyRise manually
            completionHandler(.close)
        case .secondaryButtonPressed:
            // "Continue Anyway" — remove shields and close
            store.shield.applicationCategories = nil
            store.shield.webDomainCategories = nil
            completionHandler(.close)
        @unknown default:
            completionHandler(.close)
        }
    }

    override func handle(action: ShieldAction, for webDomain: WebDomainToken, completionHandler: @escaping (ShieldActionResponse) -> Void) {
        switch action {
        case .primaryButtonPressed:
            completionHandler(.close)
        case .secondaryButtonPressed:
            store.shield.applicationCategories = nil
            store.shield.webDomainCategories = nil
            completionHandler(.close)
        @unknown default:
            completionHandler(.close)
        }
    }

    override func handle(action: ShieldAction, for category: ActivityCategoryToken, completionHandler: @escaping (ShieldActionResponse) -> Void) {
        switch action {
        case .primaryButtonPressed:
            completionHandler(.close)
        case .secondaryButtonPressed:
            store.shield.applicationCategories = nil
            store.shield.webDomainCategories = nil
            completionHandler(.close)
        @unknown default:
            completionHandler(.close)
        }
    }
}
