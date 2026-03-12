import ActivityKit
import WidgetKit
import SwiftUI

// MARK: - Live Activity Attributes
struct EarlyRiseActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var unlockExpiryDate: Date
        var minutesEarned: Int
        var taskName: String
    }
    var appName: String
}

// MARK: - Live Activity Widget
struct EarlyRiseLiveActivityLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: EarlyRiseActivityAttributes.self) { context in

            // ── Lock Screen / Banner UI ──────────────────────
            HStack(spacing: 16) {
                Text("🌅")
                    .font(.system(size: 32))
                VStack(alignment: .leading, spacing: 4) {
                    Text("Scroll Time Active")
                        .font(.headline)
                        .foregroundStyle(.white)
                    Text("\(context.state.taskName) completed")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.8))
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                    Text(timerInterval: Date()...context.state.unlockExpiryDate, countsDown: true)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                        .monospacedDigit()
                    Text("remaining")
                        .font(.caption2)
                        .foregroundStyle(.white.opacity(0.8))
                }
            }
            .padding()
            .background(
                LinearGradient(
                    colors: [Color.blue, Color.blue.opacity(0.7)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .activityBackgroundTint(Color.blue)

        } dynamicIsland: { context in
            DynamicIsland {
                // ── Expanded UI ──────────────────────────────
                DynamicIslandExpandedRegion(.leading) {
                    HStack {
                        Text("🌅")
                            .font(.title2)
                        Text("EarlyRise")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(.secondary)
                    }
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text(timerInterval: Date()...context.state.unlockExpiryDate, countsDown: true)
                        .font(.title2)
                        .fontWeight(.bold)
                        .monospacedDigit()
                        .foregroundStyle(.blue)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    HStack {
                        Text("✅ \(context.state.taskName)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text("\(context.state.minutesEarned) min earned")
                            .font(.caption)
                            .foregroundStyle(.blue)
                    }
                    .padding(.top, 4)
                }
            } compactLeading: {
                Text("🌅")
                    .font(.caption)
            } compactTrailing: {
                Text(timerInterval: Date()...context.state.unlockExpiryDate, countsDown: true)
                    .font(.caption)
                    .fontWeight(.bold)
                    .monospacedDigit()
                    .foregroundStyle(.blue)
                    .frame(width: 48)
            } minimal: {
                Text("🌅")
            }
            .widgetURL(URL(string: "earlyrise://home"))
            .keylineTint(Color.blue)
        }
    }
}
