import SwiftUI
import NodePersonShared

/// Animated breathing circle — the core visual for all wellness canvases.
struct BreathingCircleView: View {
    let pattern: BreathingPattern
    let phase: BreathingPhase
    let progress: Double          // 0…1 within current phase
    let scale: Double             // 0.5…1.0 breathing scale
    let accentHex: String
    let gradientEndHex: String

    var body: some View {
        ZStack {
            // Outer glow ring
            Circle()
                .stroke(
                    AngularGradient(
                        colors: [
                            Color(hex: accentHex).opacity(0.3),
                            Color(hex: gradientEndHex).opacity(0.6),
                            Color(hex: accentHex).opacity(0.3),
                        ],
                        center: .center
                    ),
                    lineWidth: 4
                )
                .frame(width: 260, height: 260)
                .scaleEffect(scale * 1.1)
                .opacity(0.5)

            // Mid ring — progress indicator
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    Color(hex: accentHex),
                    style: StrokeStyle(lineWidth: 3, lineCap: .round)
                )
                .frame(width: 240, height: 240)
                .rotationEffect(.degrees(-90))
                .scaleEffect(scale * 1.05)

            // Main breathing sphere
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color(hex: accentHex).opacity(0.8),
                            Color(hex: gradientEndHex).opacity(0.4),
                            Color(hex: accentHex).opacity(0.1),
                        ],
                        center: .center,
                        startRadius: 10,
                        endRadius: 110
                    )
                )
                .frame(width: 220, height: 220)
                .scaleEffect(scale)
                .shadow(color: Color(hex: accentHex).opacity(0.4), radius: 30)

            // Inner core
            Circle()
                .fill(Color(hex: accentHex).opacity(0.3))
                .frame(width: 60, height: 60)
                .scaleEffect(scale)

            // Phase label
            VStack(spacing: 6) {
                Text(phase.label)
                    .font(.system(size: 28, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
                Text(phase.englishLabel)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.7))
            }
        }
        .animation(.easeInOut(duration: 0.15), value: scale)
        .animation(.easeInOut(duration: 0.1), value: progress)
    }
}
