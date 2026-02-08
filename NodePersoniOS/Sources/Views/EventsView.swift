import SwiftUI

/// Events list and management view — tea party system.
struct EventsView: View {
    @State private var events: [CommunityEvent] = []
    @State private var isLoading = true
    @State private var showCreateSheet = false
    @State private var selectedRegion: String?

    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    ProgressView("載入活動...")
                } else if events.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "cup.and.saucer.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.brown.opacity(0.5))
                        Text("還沒有社區茶會")
                            .font(.title3)
                            .foregroundColor(.secondary)
                        Text("發起一場茶會，連結你的社區！")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Button("發起茶會 ☕") {
                            showCreateSheet = true
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.brown)
                    }
                } else {
                    List(events) { event in
                        NavigationLink(destination: EventDetailView(eventId: event.id)) {
                            EventRow(event: event)
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("社區茶會 ☕")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showCreateSheet = true }) {
                        Image(systemName: "plus.circle.fill")
                    }
                }
            }
            .sheet(isPresented: $showCreateSheet) {
                CreateEventSheet()
            }
            .task {
                await loadEvents()
            }
            .refreshable {
                await loadEvents()
            }
        }
    }

    private func loadEvents() async {
        isLoading = true
        defer { isLoading = false }
        guard let url = APIEndpoint.listEvents(region: selectedRegion).url() else { return }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            events = try JSONDecoder().decode([CommunityEvent].self, from: data)
        } catch {
            print("Failed to load events: \(error)")
        }
    }
}

struct EventRow: View {
    let event: CommunityEvent

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(event.title)
                    .font(.headline)
                Spacer()
                Text(event.statusLabel)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(statusColor.opacity(0.15))
                    .foregroundColor(statusColor)
                    .cornerRadius(6)
            }

            HStack(spacing: 12) {
                Label(event.location, systemImage: "mappin.and.ellipse")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)

                Spacer()

                Label("\(event.attendeeCount)/\(event.maxCapacity)", systemImage: "person.2.fill")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            if let host = event.hostNodePerson {
                HStack(spacing: 4) {
                    Image(systemName: "person.fill")
                        .font(.caption2)
                    Text("主辦：\(host.name)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.vertical, 4)
    }

    private var statusColor: Color {
        switch event.status {
        case "upcoming": return .blue
        case "active": return .green
        case "completed": return .gray
        case "cancelled": return .red
        default: return .gray
        }
    }
}

struct EventDetailView: View {
    let eventId: String
    @State private var event: CommunityEvent?
    @State private var isLoading = true

    var body: some View {
        ScrollView {
            if isLoading {
                ProgressView()
                    .padding(40)
            } else if let event = event {
                VStack(alignment: .leading, spacing: 16) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text(event.title)
                            .font(.largeTitle.bold())
                        Text(event.statusLabel)
                            .font(.subheadline)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(8)
                    }
                    .padding(.horizontal)

                    // Location
                    Label(event.location, systemImage: "mappin.and.ellipse")
                        .font(.body)
                        .padding(.horizontal)

                    // Capacity
                    Label("\(event.attendeeCount) / \(event.maxCapacity) 人", systemImage: "person.2.fill")
                        .font(.body)
                        .padding(.horizontal)

                    // QR Code section
                    if let qrCode = event.qrCode {
                        VStack(spacing: 8) {
                            Text("掃碼簽到")
                                .font(.headline)
                            Text(qrCode)
                                .font(.system(.caption, design: .monospaced))
                                .padding(12)
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(16)
                        .padding(.horizontal)
                    }
                }
            }
        }
        .navigationTitle("活動詳情")
        .task {
            await loadEvent()
        }
    }

    private func loadEvent() async {
        isLoading = true
        defer { isLoading = false }
        guard let url = APIEndpoint.getEvent(id: eventId).url() else { return }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            event = try JSONDecoder().decode(CommunityEvent.self, from: data)
        } catch {
            print("Failed to load event: \(error)")
        }
    }
}

struct CreateEventSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    @State private var location = ""
    @State private var description = ""
    @State private var date = Date().addingTimeInterval(86400) // tomorrow
    @State private var maxCapacity = 50

    var body: some View {
        NavigationStack {
            Form {
                Section("活動資訊") {
                    TextField("活動名稱", text: $title)
                    TextField("地點", text: $location)
                    TextField("描述（選填）", text: $description)
                }
                Section("時間與容量") {
                    DatePicker("日期時間", selection: $date)
                    Stepper("最大人數：\(maxCapacity)", value: $maxCapacity, in: 5...500, step: 5)
                }
            }
            .navigationTitle("發起茶會 ☕")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("建立") {
                        // TODO: Call createEvent API
                        dismiss()
                    }
                    .disabled(title.isEmpty || location.isEmpty)
                }
            }
        }
    }
}
