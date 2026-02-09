import SwiftUI
import NodePersonShared

/// A rich card representing a single wellness canvas on the home dashboard.
struct CanvasCardView: View {
    let canvas: WellnessCanvas
    let streakDays: Int
    let sessionsToday: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                // Canvas icon
                Image(systemName: canvas.iconName)
                    .font(.system(size: 28))
                    .foregroundStyle(.white)
                    .frame(width: 52, height: 52)
                    .background(
                        Circle()
                            .fill(.white.opacity(0.2))
                    )

                Spacer()

                // Streak badge
                if streakDays > 0 {
                    HStack(spacing: 4) {
                        Image(systemName: "flame.fill")
                            .font(.caption)
                        Text("\(streakDays)")
                            .font(.caption.bold())
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Capsule().fill(.white.opacity(0.2)))
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(canvas.title)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)

                Text(canvas.subtitle)
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.7))
            }

            Spacer(minLength: 0)

            // Bottom: today's sessions indicator
            HStack(spacing: 6) {
                ForEach(0..<3, id: \.self) { i in
                    Circle()
                        .fill(i < sessionsToday ? .white : .white.opacity(0.25))
                        .frame(width: 8, height: 8)
                }
                Spacer()
                Image(systemName: "arrow.right")
                    .font(.caption.bold())
                    .foregroundStyle(.white.opacity(0.6))
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, minHeight: 160, alignment: .leading)
        .background(
            LinearGradient(
                colors: [
                    Color(hex: canvas.accentColorHex),
                    Color(hex: canvas.gradientEndHex),
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: Color(hex: canvas.accentColorHex).opacity(0.3), radius: 12, y: 6)
    }
}
