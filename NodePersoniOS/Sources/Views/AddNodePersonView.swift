import SwiftUI
import NodePersonShared

/// Form to create a new NodePerson.
struct AddNodePersonView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var phone = ""
    @State private var selectedType: NodeType = .factoryMaster
    @State private var district = ""
    @State private var region = ""
    @State private var notes = ""
    @State private var isSaving = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            Form {
                Section("基本資料") {
                    TextField("姓名", text: $name)
                    TextField("電話", text: $phone)
                        .keyboardType(.phonePad)
                }

                Section("節點類型") {
                    Picker("類型", selection: $selectedType) {
                        ForEach(NodeType.allCases) { type in
                            Label(type.label, systemImage: type.iconName)
                                .tag(type)
                        }
                    }
                    .pickerStyle(.navigationLink)

                    if let type = NodeType(rawValue: selectedType.rawValue) {
                        HStack {
                            Image(systemName: "info.circle")
                                .foregroundStyle(.blue)
                            Text(type.whyCritical)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                Section("地區") {
                    TextField("行政區 (例: 屏東市)", text: $district)
                    TextField("地區 (例: 屏東)", text: $region)
                }

                Section("備註") {
                    TextEditor(text: $notes)
                        .frame(minHeight: 80)
                }

                if let error = errorMessage {
                    Section {
                        Text(error)
                            .foregroundStyle(.red)
                            .font(.caption)
                    }
                }
            }
            .navigationTitle("新增節點人物")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("儲存") {
                        Task { await save() }
                    }
                    .disabled(name.isEmpty || isSaving)
                }
            }
        }
    }

    private func save() async {
        isSaving = true
        errorMessage = nil

        struct CreateBody: Encodable {
            let name: String
            let phone: String?
            let nodeType: String
            let district: String?
            let region: String?
            let notes: String?
        }

        let body = CreateBody(
            name: name,
            phone: phone.isEmpty ? nil : phone,
            nodeType: selectedType.rawValue,
            district: district.isEmpty ? nil : district,
            region: region.isEmpty ? nil : region,
            notes: notes.isEmpty ? nil : notes
        )

        do {
            let _: NodePerson = try await APIClient.shared.request(
                .createNodePerson,
                body: body
            )
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }

        isSaving = false
    }
}
