import SwiftUI
import NodePersonShared

/// Prominent card reminding operators of the core principle.
/// Displayed at the top of NodePerson lists.
struct WorryPromptCard: View {
    var body: some View {
        VStack(spacing: 10) {
            Text("👉 對話核心原則")
                .font(.subheadline.bold())

            VStack(spacing: 6) {
                Text("❌ 你有沒有東西要賣？")
                    .font(.footnote)
                    .foregroundStyle(.red)
                    .strikethrough()

                Text("✅ 最近有沒有誰在煩惱怎麼處理？")
                    .font(.footnote.bold())
                    .foregroundStyle(.green)
            }

            Text("問的是煩惱，不是商品")
                .font(.caption)
                .foregroundStyle(Color(hex: "#EC4899"))
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            LinearGradient(
                colors: [Color(hex: "#EC4899").opacity(0.08), Color.clear],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(hex: "#EC4899").opacity(0.2), lineWidth: 1)
        )
    }
}

/// Color-coded chip showing node type.
struct NodeTypeChip: View {
    let type: NodeType

    var body: some View {
        Label(type.label, systemImage: type.iconName)
            .font(.caption)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(Color(hex: type.colorHex).opacity(0.15))
            .foregroundStyle(Color(hex: type.colorHex))
            .clipShape(Capsule())
    }
}

/// Circular gauge for influence score (0-100).
struct InfluenceGauge: View {
    let score: Double
    let size: CGFloat

    init(score: Double, size: CGFloat = 60) {
        self.score = score
        self.size = size
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.gray.opacity(0.2), lineWidth: size * 0.1)

            Circle()
                .trim(from: 0, to: CGFloat(min(score / 100, 1)))
                .stroke(
                    gaugeColor,
                    style: StrokeStyle(lineWidth: size * 0.1, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.spring(duration: 0.8), value: score)

            VStack(spacing: 0) {
                Text("\(Int(score))")
                    .font(.system(size: size * 0.28, weight: .bold, design: .rounded))
                Text("影響力")
                    .font(.system(size: size * 0.12))
                    .foregroundStyle(.secondary)
            }
        }
        .frame(width: size, height: size)
    }

    private var gaugeColor: Color {
        switch score {
        case 80...: return .green
        case 60..<80: return .blue
        case 40..<60: return .orange
        default: return .gray
        }
    }
}
