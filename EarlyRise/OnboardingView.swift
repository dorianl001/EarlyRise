import SwiftUI

struct OnboardingView: View {
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding: Bool = false
    @State private var currentPage = 0
    @State private var screenTimeService = ScreenTimeService.shared

    let pages: [OnboardingPage] = [
        OnboardingPage(
            icon: "🌅",
            title: "Welcome to EarlyRise",
            description: "Take back control of your time. EarlyRise helps you build real-world habits by earning your social media scroll time.",
            color: .blue
        ),
        OnboardingPage(
            icon: "💪",
            title: "Earn Your Scroll",
            description: "Before opening Instagram or TikTok, you'll see a quick check-in. Complete a micro-task like walking, stretching, or drinking water to unlock scroll time.",
            color: .orange
        ),
        OnboardingPage(
            icon: "🔥",
            title: "Build Your Streak",
            description: "Complete at least one task every day to build your streak. Watch your time reclaimed grow and feel the difference.",
            color: .green
        )
    ]

    var body: some View {
        VStack(spacing: 0) {

            // ── Page Content ─────────────────────────────────
            TabView(selection: $currentPage) {
                ForEach(pages.indices, id: \.self) { index in
                    OnboardingPageView(page: pages[index])
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.easeInOut, value: currentPage)

            // ── Page Indicators ──────────────────────────────
            HStack(spacing: 8) {
                ForEach(pages.indices, id: \.self) { index in
                    Circle()
                        .fill(currentPage == index ? Color.blue : Color.gray.opacity(0.3))
                        .frame(width: currentPage == index ? 10 : 8,
                               height: currentPage == index ? 10 : 8)
                        .animation(.easeInOut, value: currentPage)
                }
            }
            .padding(.bottom, 32)

            // ── Action Button ────────────────────────────────
            VStack(spacing: 12) {
                if currentPage < pages.count - 1 {
                    Button {
                        withAnimation {
                            currentPage += 1
                        }
                    } label: {
                        Text("Next")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(.blue)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                } else {
                    Button {
                        Task {
                            await screenTimeService.requestAuthorization()
                            hasCompletedOnboarding = true
                        }
                    } label: {
                        Text("Enable Screen Time & Get Started")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(.blue)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }

                    Button {
                        hasCompletedOnboarding = true
                    } label: {
                        Text("Skip for now")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 48)
        }
        .background(Color(.systemGroupedBackground))
    }
}

// MARK: - Onboarding Page Model
struct OnboardingPage {
    let icon: String
    let title: String
    let description: String
    let color: Color
}

// MARK: - Onboarding Page View
struct OnboardingPageView: View {
    let page: OnboardingPage

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            Text(page.icon)
                .font(.system(size: 100))

            VStack(spacing: 16) {
                Text(page.title)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)

                Text(page.description)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            Spacer()
        }
    }
}

// MARK: - Preview
#Preview {
    OnboardingView()
}
