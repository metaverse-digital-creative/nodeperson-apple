import SwiftUI
import NodePersonShared

/// Main tab-based navigation for the iOS app.
struct ContentView: View {
    var body: some View {
        TabView {
            NodePersonListView()
                .tabItem {
                    Label("節點人物", systemImage: "person.3.fill")
                }

            ScriptBrowserView()
                .tabItem {
                    Label("對話腳本", systemImage: "text.bubble.fill")
                }

            LeaderboardView()
                .tabItem {
                    Label("排行榜", systemImage: "trophy.fill")
                }
        }
        .tint(Color(hex: "#EC4899"))
    }
}

// MARK: - Color Extension

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
