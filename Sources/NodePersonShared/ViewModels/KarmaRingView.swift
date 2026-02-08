import SwiftUI

/// Karma ring chart — 4 dimensions displayed as concentric rings.
/// Used on both watchOS and iOS.
struct KarmaRingView: View {
    let karma: KarmaScore
    var ringWidth: CGFloat = 8
    var size: CGFloat = 120

    var body: some View {
        ZStack {
            // Trust (outermost)
            RingSegment(progress: karma.trustScore / 100, color: .purple, width: ringWidth)
                .frame(width: size, height: size)

            // Community
            RingSegment(progress: karma.communityScore / 100, color: .blue, width: ringWidth)
                .frame(width: size - ringWidth * 2.5, height: size - ringWidth * 2.5)

            // Referral
            RingSegment(progress: karma.referralScore / 100, color: .orange, width: ringWidth)
                .frame(width: size - ringWidth * 5, height: size - ringWidth * 5)

            // Recycling (innermost)
            RingSegment(progress: karma.recyclingScore / 100, color: .green, width: ringWidth)
                .frame(width: size - ringWidth * 7.5, height: size - ringWidth * 7.5)

            // Center: total karma
            VStack(spacing: 2) {
                Text(karma.levelEmoji)
                    .font(.system(size: size * 0.15))
                Text(String(format: "%.0f", karma.totalKarma))
                    .font(.system(size: size * 0.18, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
            }
        }
    }
}

/// A single ring segment.
struct RingSegment: View {
    let progress: Double
    let color: Color
    let width: CGFloat

    var body: some View {
        Circle()
            .trim(from: 0, to: CGFloat(min(progress, 1.0)))
            .stroke(
                color.gradient,
                style: StrokeStyle(lineWidth: width, lineCap: .round)
            )
            .rotationEffect(.degrees(-90))
            .background(
                Circle()
                    .stroke(color.opacity(0.15), lineWidth: width)
            )
    }
}

/// Legend for the 4 Karma dimensions.
struct KarmaLegendView: View {
    let karma: KarmaScore

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            legendRow(color: .green, label: "回收", score: karma.recyclingScore, emoji: "♻️")
            legendRow(color: .orange, label: "轉介", score: karma.referralScore, emoji: "🤝")
            legendRow(color: .blue, label: "社區", score: karma.communityScore, emoji: "🏘️")
            legendRow(color: .purple, label: "信任", score: karma.trustScore, emoji: "💎")
        }
    }

    private func legendRow(color: Color, label: String, score: Double, emoji: String) -> some View {
        HStack(spacing: 8) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            Text("\(emoji) \(label)")
                .font(.caption)
                .foregroundColor(.secondary)
            Spacer()
            Text(String(format: "%.0f", score))
                .font(.caption.bold())
                .foregroundColor(.primary)
        }
    }
}

#if DEBUG
struct KarmaRingView_Previews: PreviewProvider {
    static var previews: some View {
        KarmaRingView(karma: KarmaScore(
            recyclingScore: 72,
            referralScore: 45,
            communityScore: 88,
            trustScore: 65,
            totalKarma: 67.5,
            weeklyDelta: 3.2,
            activeStreak: 5,
            level: 7
        ))
        .padding()
    }
}
#endif
