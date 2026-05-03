import SwiftUI
import SwiftData

struct FixPreviewView: View {
    @Environment(\.modelContext) private var modelContext
    let session: CleaningSession
    @State private var isFixing = false
    @State private var fixComplete = false
    @State private var fixedCount = 0

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                if fixComplete {
                    completionView
                } else if isFixing {
                    fixingView
                } else {
                    previewView
                }
            }
            .padding()
        }
        .frame(maxWidth: 720)
        .frame(maxWidth: .infinity)
        .navigationTitle("Fix Preview")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var previewView: some View {
        VStack(spacing: 20) {
            Image(systemName: "wand.and.stars")
                .font(.system(size: 48))
                .foregroundStyle(.blue)

            Text("Ready to fix \(session.issues.filter { !$0.isResolved }.count) issues")
                .font(.title3.bold())

            VStack(alignment: .leading, spacing: 8) {
                let unresolved = session.issues.filter { !$0.isResolved }
                let grouped = Dictionary(grouping: unresolved) { $0.issueType }
                ForEach(Array(grouped.sorted { a, b in a.key < b.key }), id: \.key) { type, issues in
                    HStack {
                        Image(systemName: IssueType(rawValue: type)?.icon ?? "exclamationmark.circle")
                            .frame(width: 20)
                        Text(IssueType(rawValue: type)?.displayName ?? type)
                        Spacer()
                        Text("\(issues.count)")
                            .foregroundStyle(.secondary)
                    }
                    .font(.subheadline)
                }
            }
            .padding()
            .background(.regularMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 12))

            Button {
                applyFixes()
            } label: {
                Label("Apply Fixes", systemImage: "wand.and.stars")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
            }
            .buttonStyle(.borderedProminent)
        }
    }

    private var fixingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
            Text("Applying fixes...")
                .font(.headline)
            Text("\(fixedCount) of \(session.issues.filter { !$0.isResolved }.count) fixed")
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 40)
    }

    private var completionView: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 56))
                .foregroundStyle(.green)

            Text("All fixes applied!")
                .font(.title2.bold())

            Text("\(fixedCount) issues resolved")
                .foregroundStyle(.secondary)

            NavigationLink {
                ExportView(session: session)
            } label: {
                Label("Export Clean Data", systemImage: "square.and.arrow.up")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(.vertical, 40)
    }

    private func applyFixes() {
        isFixing = true
        let unresolved = session.issues.filter { !$0.isResolved }
        for (index, issue) in unresolved.enumerated() {
            issue.isResolved = true
            fixedCount = index + 1
        }
        session.issuesFixed = fixedCount
        session.isCompleted = true
        try? modelContext.save()
        fixComplete = true
        isFixing = false
    }
}
