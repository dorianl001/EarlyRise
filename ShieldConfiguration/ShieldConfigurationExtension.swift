import ManagedSettings
import ManagedSettingsUI
import UIKit

class ShieldConfigurationExtension: ShieldConfigurationDataSource {

    override func configuration(shielding application: Application) -> ShieldConfiguration {
        return pauseScreenConfiguration(appName: application.localizedDisplayName ?? "this app")
    }

    override func configuration(shielding application: Application, in category: ActivityCategory) -> ShieldConfiguration {
        return pauseScreenConfiguration(appName: application.localizedDisplayName ?? "this app")
    }

    override func configuration(shielding webDomain: WebDomain) -> ShieldConfiguration {
        return pauseScreenConfiguration(appName: webDomain.domain ?? "this site")
    }

    override func configuration(shielding webDomain: WebDomain, in category: ActivityCategory) -> ShieldConfiguration {
        return pauseScreenConfiguration(appName: webDomain.domain ?? "this site")
    }

    // MARK: - Pause Screen UI
    private func pauseScreenConfiguration(appName: String) -> ShieldConfiguration {
        return ShieldConfiguration(
            backgroundBlurStyle: .systemUltraThinMaterialDark,
            backgroundColor: UIColor.systemBackground,
            icon: UIImage(systemName: "hourglass"),
            title: ShieldConfiguration.Label(
                text: "Hey, quick check-in ✋",
                color: .label
            ),
            subtitle: ShieldConfiguration.Label(
                text: "Take a breath before opening \(appName). Want to earn your scroll time first?",
                color: .secondaryLabel
            ),
            primaryButtonLabel: ShieldConfiguration.Label(
                text: "Earn Scroll Time 💪",
                color: .white
            ),
            primaryButtonBackgroundColor: .systemBlue,
            secondaryButtonLabel: ShieldConfiguration.Label(
                text: "Continue Anyway",
                color: .secondaryLabel
            )
        )
    }
}
