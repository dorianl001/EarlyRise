import SwiftUI
import StoreKit

struct PaywallView: View {
    @Environment(\.dismiss) var dismiss
    var appState: AppState
    @State private var products: [Product] = []
    @State private var isPurchasing = false
    @State private var errorMessage: String?
    @State private var showError = false

    let productIDs = [
        "com.dorianlopez.earlyrise.premium.monthly",
        "com.dorianlopez.earlyrise.premium.annual"
    ]

    let privacyURL = URL(string: "https://www.notion.so/EarlyRise-Privacy-Policy-32278f7f3b85801dad83d3e6a202dd15")!
    let termsURL = URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {

                    // ── Header ────────────────────────────
                    VStack(spacing: 12) {
                        Image(systemName: "sunrise.fill")
                            .font(.system(size: 60))
                            .foregroundStyle(.orange)

                        Text("EarlyRise Premium")
                            .font(.largeTitle)
                            .fontWeight(.bold)

                        Text("Earn your scroll time. Every day.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 32)

                    // ── Features ──────────────────────────
                    VStack(alignment: .leading, spacing: 16) {
                        featureRow(icon: "lock.shield.fill", color: .blue,
                            title: "Custom App Locking",
                            description: "Choose exactly which apps to monitor")
                        featureRow(icon: "chart.bar.fill", color: .green,
                            title: "Advanced Stats",
                            description: "Track your progress over time")
                        featureRow(icon: "sunrise.fill", color: .orange,
                            title: "Morning Nudge",
                            description: "Daily motivation with your stats")
                        featureRow(icon: "clock.badge.checkmark", color: .purple,
                            title: "Custom Scroll Budget",
                            description: "Set your own daily scroll limit")
                        featureRow(icon: "heart.fill", color: .pink,
                            title: "Time Reclaimed",
                            description: "See how much time you've taken back")
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .padding(.horizontal)

                    // ── Pricing ───────────────────────────
                    if products.isEmpty {
                        ProgressView()
                            .padding()
                    } else {
                        VStack(spacing: 12) {
                            ForEach(products.sorted(by: { $0.price < $1.price }), id: \.id) { product in
                                Button {
                                    Task { await purchase(product) }
                                } label: {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(product.displayName)
                                                .font(.headline)
                                                .foregroundStyle(.white)
                                            Text(subscriptionLength(for: product))
                                                .font(.caption)
                                                .foregroundStyle(.white.opacity(0.9))
                                            Text(product.description)
                                                .font(.caption2)
                                                .foregroundStyle(.white.opacity(0.7))
                                        }
                                        Spacer()
                                        Text(product.displayPrice)
                                            .font(.title3)
                                            .fontWeight(.bold)
                                            .foregroundStyle(.white)
                                    }
                                    .padding()
                                    .background(product.id.contains("annual") ? Color.orange : Color.blue)
                                    .clipShape(RoundedRectangle(cornerRadius: 14))
                                }
                                .disabled(isPurchasing)
                            }
                        }
                        .padding(.horizontal)
                    }

                    // ── Restore Purchases ─────────────────
                    Button {
                        Task { await restorePurchases() }
                    } label: {
                        Text("Restore Purchases")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }

                    // ── Legal ─────────────────────────────
                    VStack(spacing: 8) {
                        Text("Subscriptions auto-renew unless cancelled at least 24 hours before the end of the current period. Cancel anytime in your iPhone Settings.")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)

                        HStack(spacing: 16) {
                            Link("Privacy Policy", destination: privacyURL)
                                .font(.caption2)
                                .foregroundStyle(.blue)
                            Text("·")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                            Link("Terms of Use", destination: termsURL)
                                .font(.caption2)
                                .foregroundStyle(.blue)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 32)
                }
            }
            .navigationTitle("Go Premium")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close") { dismiss() }
                }
            }
            .task { await loadProducts() }
            .alert("Purchase Error", isPresented: $showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage ?? "Something went wrong.")
            }
        }
    }

    // MARK: - Subscription Length
    func subscriptionLength(for product: Product) -> String {
        if product.id.contains("monthly") {
            return "1 month · auto-renews at \(product.displayPrice)/month"
        } else {
            return "1 year · auto-renews at \(product.displayPrice)/year"
        }
    }

    // MARK: - Feature Row
    func featureRow(icon: String, color: Color, title: String, description: String) -> some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
                .frame(width: 32)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
    }

    // MARK: - Load Products
    func loadProducts() async {
        do {
            products = try await Product.products(for: productIDs)
        } catch {
            print("Failed to load products: \(error)")
        }
    }

    // MARK: - Purchase
    func purchase(_ product: Product) async {
        isPurchasing = true
        do {
            let result = try await product.purchase()
            switch result {
            case .success:
                await appState.checkSubscriptionStatus()
                dismiss()
            case .userCancelled:
                break
            case .pending:
                break
            @unknown default:
                break
            }
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
        isPurchasing = false
    }

    // MARK: - Restore Purchases
    func restorePurchases() async {
        do {
            try await AppStore.sync()
            await appState.checkSubscriptionStatus()
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }
}

#Preview {
    PaywallView(appState: AppState())
}
