import SwiftUI

struct ExportView: View {
    let session: CleaningSession
    @State private var exportFormat: ExportFormat = .xlsx
    @State private var isExporting = false
    @State private var showShareSheet = false
    @State private var exportedFileURL: URL?
    @State private var errorMessage: String?

    enum ExportFormat: String, CaseIterable {
        case xlsx = "XLSX"
        case csv = "CSV"
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Image(systemName: "square.and.arrow.up")
                    .font(.system(size: 48))
                    .foregroundStyle(.blue)

                Text("Export Clean Data")
                    .font(.title2.bold())

                VStack(spacing: 12) {
                    ForEach(ExportFormat.allCases, id: \.self) { format in
                        Button {
                            exportFormat = format
                        } label: {
                            HStack {
                                Image(systemName: format == .xlsx ? "doc.fill" : "doc.text.fill")
                                    .frame(width: 24)
                                Text(format.rawValue)
                                    .font(.headline)
                                Spacer()
                                if exportFormat == format {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(.blue)
                                }
                            }
                            .padding()
                            .background(exportFormat == format ? Color.blue.opacity(0.1) : Color.clear)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(exportFormat == format ? Color.blue : Color.gray.opacity(0.3), lineWidth: 1)
                            )
                        }
                        .foregroundStyle(.primary)
                    }
                }

                Button {
                    exportFile()
                } label: {
                    if isExporting {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Label("Export", systemImage: "square.and.arrow.up")
                    }
                }
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .buttonStyle(.borderedProminent)
                .disabled(isExporting)

                if let error = errorMessage {
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(.red)
                }
            }
            .padding()
        }
        .frame(maxWidth: 720)
        .frame(maxWidth: .infinity)
        .navigationTitle("Export")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showShareSheet) {
            if let url = exportedFileURL {
                ShareSheetView(activityItems: [url])
            }
        }
    }

    private func exportFile() {
        isExporting = true
        errorMessage = nil

        Task {
            do {
                let tempDir = FileManager.default.temporaryDirectory
                let baseName = session.fileName.components(separatedBy: ".").dropLast().joined(separator: ".")
                let cleanedName = "\(baseName)_cleaned"

                let url: URL
                if exportFormat == .xlsx {
                    url = tempDir.appendingPathComponent("\(cleanedName).xlsx")
                    let writer = XLSXWriter()
                    let sampleData: [[String?]] = [["Sample cleaned data"]]
                    try await writer.write(data: sampleData, headers: ["Result"], to: url)
                } else {
                    url = tempDir.appendingPathComponent("\(cleanedName).csv")
                    let writer = CSVWriter()
                    let sampleData: [[String?]] = [["Sample cleaned data"]]
                    try await writer.write(data: sampleData, headers: ["Result"], to: url)
                }

                exportedFileURL = url
                isExporting = false
                showShareSheet = true
            } catch {
                errorMessage = error.localizedDescription
                isExporting = false
            }
        }
    }
}

struct ShareSheetView: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
