import SwiftUI

struct IssueDetailView: View {
    let issues: [DataIssue]
    let issueType: String

    var body: some View {
        List {
            ForEach(issues) { issue in
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text("Row \(issue.rowIndex + 2)")
                            .font(.caption.bold())
                            .foregroundStyle(.secondary)
                        Spacer()
                        if issue.isResolved {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(.green)
                                .font(.caption)
                        }
                    }

                    HStack {
                        Text("Original:")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(issue.originalValue)
                            .font(.caption)
                            .lineLimit(1)
                    }

                    HStack {
                        Text("Suggested:")
                            .font(.caption)
                            .foregroundStyle(.green)
                        Text(issue.suggestedFix)
                            .font(.caption)
                            .foregroundStyle(.green)
                            .lineLimit(1)
                    }
                }
                .padding(.vertical, 4)
            }
        }
        .navigationTitle(IssueType(rawValue: issueType)?.displayName ?? issueType)
    }
}
