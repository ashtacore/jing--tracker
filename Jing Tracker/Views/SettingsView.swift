import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var allEvents: [WellnessEvent]
    
    @State private var showingClearConfirmation = false
    @State private var showingImportReplaceConfirmation = false
    @State private var showingExporter = false
    @State private var showingImporter = false
    @State private var importMode: ImportMode = .merge
    @State private var pendingImportURL: URL?
    @State private var alertMessage = ""
    @State private var showingAlert = false
    
    enum ImportMode {
        case replace, merge
    }
    
    var body: some View {
        NavigationStack {
            List {
                Section("Data Management") {
                    Button {
                        showingExporter = true
                    } label: {
                        Label("Export Data as CSV", systemImage: "square.and.arrow.up")
                    }
                    .foregroundStyle(Color.green)
                    
                    Button {
                        importMode = .merge
                        showingImporter = true
                    } label: {
                        Label("Import CSV (Add to Existing)", systemImage: "square.and.arrow.down")
                    }
                    
                    Button {
                        importMode = .replace
                        showingImporter = true
                    } label: {
                        Label("Import CSV (Replace All)", systemImage: "arrow.triangle.2.circlepath")
                    }
                    .foregroundStyle(Color.orange)
                    
                    Button(role: .destructive) {
                        showingClearConfirmation = true
                    } label: {
                        Label("Clear All Data", systemImage: "trash")
                    }
                    .foregroundStyle(Color.red)
                }
                
                Section("About") {
                    HStack {
                        Text("Events Tracked")
                        Spacer()
                        Text("\(allEvents.count)")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
            .confirmationDialog(
                "Clear All Data?",
                isPresented: $showingClearConfirmation,
                titleVisibility: .visible
            ) {
                Button("Clear All Data", role: .destructive) {
                    clearAllData()
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("This will permanently delete all tracked events. This action cannot be undone.")
            }
            .confirmationDialog(
                "Replace All Data?",
                isPresented: $showingImportReplaceConfirmation,
                titleVisibility: .visible
            ) {
                Button("Replace All Data", role: .destructive) {
                    if let url = pendingImportURL {
                        performImport(from: url, replacing: true)
                    }
                }
                Button("Cancel", role: .cancel) {
                    pendingImportURL = nil
                }
            } message: {
                Text("This will delete all existing data and replace it with the imported data. This action cannot be undone.")
            }
            .fileExporter(
                isPresented: $showingExporter,
                document: CSVDocument(events: allEvents),
                contentType: .commaSeparatedText,
                defaultFilename: "wellness_events_\(formattedDate()).csv"
            ) { result in
                switch result {
                case .success(let url):
                    alertMessage = "Data exported successfully to \(url.lastPathComponent)"
                    showingAlert = true
                case .failure(let error):
                    alertMessage = "Export failed: \(error.localizedDescription)"
                    showingAlert = true
                }
            }
            .fileImporter(
                isPresented: $showingImporter,
                allowedContentTypes: [.commaSeparatedText],
                allowsMultipleSelection: false
            ) { result in
                switch result {
                case .success(let urls):
                    guard let url = urls.first else { return }
                    if importMode == .replace {
                        pendingImportURL = url
                        showingImportReplaceConfirmation = true
                    } else {
                        performImport(from: url, replacing: false)
                    }
                case .failure(let error):
                    alertMessage = "Import failed: \(error.localizedDescription)"
                    showingAlert = true
                }
            }
            .alert("Data Operation", isPresented: $showingAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    private func formattedDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }
    
    private func clearAllData() {
        for event in allEvents {
            modelContext.delete(event)
        }
        try? modelContext.save()
        alertMessage = "All data has been cleared."
        showingAlert = true
    }
    
    private func performImport(from url: URL, replacing: Bool) {
        guard url.startAccessingSecurityScopedResource() else {
            alertMessage = "Could not access the selected file."
            showingAlert = true
            return
        }
        defer { url.stopAccessingSecurityScopedResource() }
        
        do {
            let content = try String(contentsOf: url, encoding: .utf8)
            let events = parseCSV(content)
            
            if replacing {
                for event in allEvents {
                    modelContext.delete(event)
                }
            }
            
            for event in events {
                modelContext.insert(event)
            }
            
            try modelContext.save()
            alertMessage = "Successfully imported \(events.count) events."
            showingAlert = true
        } catch {
            alertMessage = "Import failed: \(error.localizedDescription)"
            showingAlert = true
        }
        
        pendingImportURL = nil
    }
    
    private func parseCSV(_ content: String) -> [WellnessEvent] {
        var events: [WellnessEvent] = []
        let lines = content.components(separatedBy: .newlines)
        
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        let fallbackFormatter = ISO8601DateFormatter()
        fallbackFormatter.formatOptions = [.withInternetDateTime]
        
        for (index, line) in lines.enumerated() {
            // Skip header row and empty lines
            if index == 0 || line.trimmingCharacters(in: .whitespaces).isEmpty {
                continue
            }
            
            let columns = line.components(separatedBy: ",")
            guard columns.count >= 2 else { continue }
            
            let typeString = columns[0].trimmingCharacters(in: .whitespaces)
            let dateString = columns[1].trimmingCharacters(in: .whitespaces)
            
            guard let eventType = EventType(rawValue: typeString) else { continue }
            
            var date: Date?
            date = dateFormatter.date(from: dateString)
            if date == nil {
                date = fallbackFormatter.date(from: dateString)
            }
            
            guard let eventDate = date else { continue }
            
            let event = WellnessEvent(type: eventType, date: eventDate)
            events.append(event)
        }
        
        return events
    }
}

struct CSVDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.commaSeparatedText] }
    
    var content: String
    
    init(events: [WellnessEvent]) {
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        var csv = "type,date\n"
        for event in events.sorted(by: { $0.date < $1.date }) {
            csv += "\(event.type.rawValue),\(dateFormatter.string(from: event.date))\n"
        }
        self.content = csv
    }
    
    init(configuration: ReadConfiguration) throws {
        if let data = configuration.file.regularFileContents {
            content = String(data: data, encoding: .utf8) ?? ""
        } else {
            content = ""
        }
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let data = content.data(using: .utf8)!
        return FileWrapper(regularFileWithContents: data)
    }
}

#Preview {
    SettingsView()
        .modelContainer(MockDataGenerator.makeContainer())
}
