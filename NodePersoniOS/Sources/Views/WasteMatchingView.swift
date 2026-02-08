import SwiftUI

/// Waste matching view — camera → classify → match buyers → accept.
struct WasteMatchingView: View {
    @State private var posts: [WastePost] = []
    @State private var isLoading = true
    @State private var showClassifySheet = false
    @State private var stats: WasteStats?

    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    ProgressView("載入媒合資料...")
                } else {
                    List {
                        // Stats section
                        if let stats = stats {
                            Section("媒合統計") {
                                HStack {
                                    StatItem(value: "\(stats.totalPosts)", label: "總發布", icon: "doc.fill", color: .blue)
                                    StatItem(value: "\(stats.matched)", label: "已媒合", icon: "checkmark.circle.fill", color: .green)
                                    StatItem(value: "\(stats.completed)", label: "已完成", icon: "star.fill", color: .orange)
                                }
                                .listRowInsets(EdgeInsets())
                                .padding()

                                if stats.totalCommunityFund > 0 {
                                    HStack {
                                        Image(systemName: "banknote.fill")
                                            .foregroundColor(.green)
                                        Text("社區基金累計")
                                            .font(.subheadline)
                                        Spacer()
                                        Text("NT$\(String(format: "%.0f", stats.totalCommunityFund))")
                                            .font(.subheadline.bold())
                                            .foregroundColor(.green)
                                    }
                                }
                            }
                        }

                        // Posts section
                        Section("廢料發布") {
                            if posts.isEmpty {
                                VStack(spacing: 12) {
                                    Image(systemName: "camera.fill")
                                        .font(.title)
                                        .foregroundColor(.secondary)
                                    Text("拍照辨識廢料，一鍵媒合買家")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                            } else {
                                ForEach(posts) { post in
                                    NavigationLink(destination: WastePostDetailView(postId: post.id)) {
                                        WastePostRow(post: post)
                                    }
                                }
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("一鍵媒合 ♻️")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showClassifySheet = true }) {
                        Label("拍照辨識", systemImage: "camera.fill")
                    }
                }
            }
            .sheet(isPresented: $showClassifySheet) {
                ClassifySheet()
            }
            .task {
                await loadData()
            }
            .refreshable {
                await loadData()
            }
        }
    }

    private func loadData() async {
        isLoading = true
        defer { isLoading = false }

        async let postsTask: Void = loadPosts()
        async let statsTask: Void = loadStats()
        _ = await (postsTask, statsTask)
    }

    private func loadPosts() async {
        guard let url = APIEndpoint.listWastePosts().url() else { return }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            posts = try JSONDecoder().decode([WastePost].self, from: data)
        } catch {
            print("Failed to load waste posts: \(error)")
        }
    }

    private func loadStats() async {
        guard let url = APIEndpoint.wasteStats.url() else { return }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            stats = try JSONDecoder().decode(WasteStats.self, from: data)
        } catch {
            print("Failed to load waste stats: \(error)")
        }
    }
}

struct StatItem: View {
    let value: String
    let label: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.title3)
            Text(value)
                .font(.title3.bold())
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct WastePostRow: View {
    let post: WastePost

    var body: some View {
        HStack(spacing: 12) {
            Text(post.categoryEmoji)
                .font(.title)
                .frame(width: 44, height: 44)
                .background(Color(.systemGray6))
                .cornerRadius(10)

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(post.categoryLabel)
                        .font(.headline)
                    if let weight = post.weightKg {
                        Text("\(String(format: "%.1f", weight)) kg")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                HStack {
                    Text(post.statusLabel)
                        .font(.caption)
                        .foregroundColor(post.status == "completed" ? .green : .blue)
                    if let matchCount = post.matches?.count, matchCount > 0 {
                        Text("• \(matchCount) 位買家")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }

            Spacer()

            Text("\(Int(post.aiConfidence * 100))%")
                .font(.caption.bold())
                .foregroundColor(.green)
        }
        .padding(.vertical, 4)
    }
}

struct WastePostDetailView: View {
    let postId: String
    @State private var post: WastePost?
    @State private var isLoading = true

    var body: some View {
        ScrollView {
            if isLoading {
                ProgressView()
                    .padding(40)
            } else if let post = post {
                VStack(alignment: .leading, spacing: 16) {
                    // Category header
                    HStack {
                        Text(post.categoryEmoji)
                            .font(.largeTitle)
                        VStack(alignment: .leading) {
                            Text(post.categoryLabel)
                                .font(.title2.bold())
                            Text("AI 準確度：\(Int(post.aiConfidence * 100))%")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Text(post.statusLabel)
                            .font(.caption)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(8)
                    }
                    .padding(.horizontal)

                    // Buyer matches
                    if let matches = post.matches, !matches.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("買家媒合")
                                .font(.headline)
                                .padding(.horizontal)

                            ForEach(matches) { match in
                                HStack {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(match.buyerName)
                                            .font(.subheadline.bold())
                                        Text(match.statusLabel)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    Spacer()
                                    if let price = match.offeredPrice {
                                        Text("NT$\(String(format: "%.0f", price))")
                                            .font(.subheadline.bold())
                                            .foregroundColor(.green)
                                    }
                                }
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                                .padding(.horizontal)
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("媒合詳情")
        .task {
            await loadPost()
        }
    }

    private func loadPost() async {
        isLoading = true
        defer { isLoading = false }
        guard let url = APIEndpoint.getWastePost(id: postId).url() else { return }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            post = try JSONDecoder().decode(WastePost.self, from: data)
        } catch {
            print("Failed to load waste post: \(error)")
        }
    }
}

struct ClassifySheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var photoUrl = ""
    @State private var result: WasteClassification?
    @State private var isClassifying = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Image(systemName: "camera.viewfinder")
                    .font(.system(size: 80))
                    .foregroundColor(.green.opacity(0.6))
                    .padding()

                Text("拍照或輸入圖片URL")
                    .font(.headline)

                TextField("圖片 URL", text: $photoUrl)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal)

                if isClassifying {
                    ProgressView("AI 辨識中...")
                } else if let result = result {
                    VStack(spacing: 8) {
                        Text("辨識結果")
                            .font(.headline)
                        HStack {
                            Text("類別：\(result.category)")
                                .font(.body)
                            Spacer()
                            Text("\(Int(result.confidence * 100))%")
                                .font(.body.bold())
                                .foregroundColor(.green)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)
                }

                Button("開始辨識") {
                    Task { await classify() }
                }
                .buttonStyle(.borderedProminent)
                .tint(.green)
                .disabled(photoUrl.isEmpty || isClassifying)

                Spacer()
            }
            .navigationTitle("AI 廢料辨識")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("關閉") { dismiss() }
                }
            }
        }
    }

    private func classify() async {
        isClassifying = true
        defer { isClassifying = false }
        guard let url = APIEndpoint.classifyWaste.url() else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body = ["photoUrl": photoUrl]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            result = try JSONDecoder().decode(WasteClassification.self, from: data)
        } catch {
            print("Failed to classify: \(error)")
        }
    }
}
