//
//  PaywallView.swift
//  EarlyRise
//
//  Created by Dorian Lopez on 3/25/26.
//

import SwiftUI
import StoreKit

struct PaywallView: View {
    @Environment(\.dismiss) var dismiss
    @State private var products: [Product] = []
    @State private var isPurchasing = false
    @State private var errorMessage: String?
    @State private var showError = false

    let productIDs = [
        "com.dorianlopez.earlyrise.premium.monthly",
        "com.dorianlopez.earlyrise.premium.annual"
    ]

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
                                            Text(product.description)
                                                .font(.caption)
                                                .foregroundStyle(.white.opacity(0.8))
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
                    Text("Subscriptions auto-renew unless cancelled. Cancel anytime in Settings.")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
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
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }
}

#Preview {
    PaywallView()
}
