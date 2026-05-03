import SwiftUI
import SwiftData

struct ScanResultsView: View {
    @Environment(\.modelContext) private var modelContext
    let session: CleaningSession
    @State private var showFixPreview = false
    @State private var groupedIssues: [(type: String, issues: [DataIssue])] = []

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                summaryCard

                if groupedIssues.isEmpty {
                    noIssuesView
                } else {
                    issuesByCategory
                }
            }
            .padding()
        }
        .frame(maxWidth: 720)
        .frame(maxWidth: .infinity)
        .navigationTitle(session.fileName)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if !session.isCompleted && !groupedIssues.isEmpty {
                    Button("Fix All") {
                        showFixPreview = true
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
        }
        .navigationDestination(isPresented: $showFixPreview) {
            FixPreviewView(session: session)
        }
        .onAppear {
            groupIssues()
        }
    }

    private var summaryCard: some View {
        VStack(spacing: 12) {
            HStack {
                Text("\(session.issuesFound) Issues Found")
                    .font(.title2.bold())
                Spacer()
            }

            HStack(spacing: 16) {
                Label("\(session.rowCount) rows", systemImage: "tablecells")
                Label("\(session.columnCount) cols", systemImage: "square.split.2x1")
                Label("\(session.sheetCount) sheets", systemImage: "doc.on.doc")
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)

            if session.issuesFound > 0 {
                let hours = Double(session.issuesFound) * 0.02
                HStack {
                    Image(systemName: "clock.fill")
                        .foregroundStyle(.green)
                    Text("Estimated save: \(String(format: "%.1f", hours)) hours")
                        .font(.subheadline)
                        .foregroundStyle(.green)
                    Spacer()
                }
            }
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var noIssuesView: some View {
        VStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 48))
                .foregroundStyle(.green)
            Text("No issues found!")
                .font(.title3.bold())
            Text("Your data looks clean.")
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 40)
    }

    private var issuesByCategory: some View {
        VStack(spacing: 16) {
            let criticalIssues = groupedIssues.filter { $0.issues.first?.severity == "critical" }
            let warningIssues = groupedIssues.filter { $0.issues.first?.severity == "warning" }
            let infoIssues = groupedIssues.filter { $0.issues.first?.severity == "info" }

            if !criticalIssues.isEmpty {
                issueSection(title: "Critical", items: criticalIssues, color: .red)
            }

            if !warningIssues.isEmpty {
                issueSection(title: "Warnings", items: warningIssues, color: .orange)
            }

            if !infoIssues.isEmpty {
                issueSection(title: "Info", items: infoIssues, color: .blue)
            }
        }
    }

    private func issueSection(title: String, items: [(type: String, issues: [DataIssue])], color: Color) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundStyle(color)

            ForEach(items, id: \.type) { group in
                NavigationLink {
                    IssueDetailView(issues: group.issues, issueType: group.type)
                } label: {
                    HStack {
                        Image(systemName: IssueType(rawValue: group.type)?.icon ?? "exclamationmark.circle")
                            .foregroundStyle(color)
                            .frame(width: 24)

                        Text(IssueType(rawValue: group.type)?.displayName ?? group.type)
                            .font(.subheadline)

                        Spacer()

                        Text("\(group.issues.count)")
                            .font(.subheadline.bold())
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(.background.secondary)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
        }
    }

    private func groupIssues() {
        let issues = session.issues.filter { !$0.isResolved }
        let grouped = Dictionary(grouping: issues) { $0.issueType }
        groupedIssues = grouped.map { (type, issues) in
            (type: type, issues: issues.sorted { $0.rowIndex < $1.rowIndex })
        }.sorted { a, b in
            let order = ["critical", "warning", "info"]
            let aOrder = order.firstIndex(of: a.issues.first?.severity ?? "info") ?? 2
            let bOrder = order.firstIndex(of: b.issues.first?.severity ?? "info") ?? 2
            return aOrder < bOrder
        }
    }
}
