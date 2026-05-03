import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct ImportView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var isImporting = false
    @State private var isProcessing = false
    @State private var processingProgress: Double = 0
    @State private var errorMessage: String?
    @State private var showError = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                Spacer()

                if isProcessing {
                    processingView
                } else {
                    importPromptView
                }

                Spacer()
            }
            .navigationTitle("Import File")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
            .fileImporter(
                isPresented: $isImporting,
                allowedContentTypes: [
                    UTType(filenameExtension: "xlsx") ?? .data,
                    UTType(filenameExtension: "csv") ?? .data
                ],
                allowsMultipleSelection: false
            ) { result in
                handleFileImport(result)
            }
            .alert("Import Error", isPresented: $showError) {
                Button("OK") {}
            } message: {
                Text(errorMessage ?? "An unknown error occurred.")
            }
        }
    }

    private var importPromptView: some View {
        VStack(spacing: 20) {
            Image(systemName: "arrow.down.doc.fill")
                .font(.system(size: 56))
                .foregroundStyle(.blue)

            Text("Select a spreadsheet file")
                .font(.title3)
                .foregroundStyle(.secondary)

            Button {
                isImporting = true
            } label: {
                Label("Browse Files", systemImage: "folder")
                    .font(.headline)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
            }
            .buttonStyle(.borderedProminent)

            Text(".xlsx and .csv supported")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
    }

    private var processingView: some View {
        VStack(spacing: 16) {
            ProgressView(value: processingProgress) {
                Text("Analyzing file...")
            }
            .progressViewStyle(.linear)
            .padding(.horizontal, 40)

            Text("\(Int(processingProgress * 100))%")
                .font(.title2.monospacedDigit())
                .foregroundStyle(.secondary)
        }
    }

    private func handleFileImport(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let url = urls.first else { return }
            Task {
                await processFile(at: url)
            }
        case .failure(let error):
            errorMessage = error.localizedDescription
            showError = true
        }
    }

    private func processFile(at url: URL) async {
        isProcessing = true
        processingProgress = 0.1

        let accessing = url.startAccessingSecurityScopedResource()
        defer {
            if accessing { url.stopAccessingSecurityScopedResource() }
        }

        do {
            let spreadsheetData: SpreadsheetData

            if url.pathExtension == "xlsx" {
                let parser = ExcelParser()
                spreadsheetData = try await parser.parseFile(at: url)
            } else if url.pathExtension == "csv" {
                let parser = CSVParser()
                spreadsheetData = try await parser.parseFile(at: url)
            } else {
                throw ParseError.unsupportedFormat
            }

            processingProgress = 0.5

            let session = CleaningSession(fileName: url.lastPathComponent)
            session.rowCount = spreadsheetData.sheets.reduce(0) { $0 + $1.dataRows.count }
            session.columnCount = spreadsheetData.sheets.first?.columnCount ?? 0
            session.sheetCount = spreadsheetData.sheets.count

            processingProgress = 0.7

            let scanner = IssueScanner()
            let issues = await scanner.scan(data: spreadsheetData)

            processingProgress = 0.9

            for issue in issues {
                session.issues.append(issue)
            }
            session.issuesFound = issues.count

            modelContext.insert(session)
            try modelContext.save()

            PurchaseManager.shared.incrementUsage()

            processingProgress = 1.0

            dismiss()
        } catch {
            errorMessage = error.localizedDescription
            showError = true
            isProcessing = false
        }
    }
}
