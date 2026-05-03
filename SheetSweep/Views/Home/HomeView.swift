import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \CleaningSession.importDate, order: .reverse) private var sessions: [CleaningSession]
    @State private var showImport = false
    @State private var showSettings = false
    @State private var showPaywall = false

    var body: some View {
        NavigationStack {
            Group {
                if sessions.isEmpty {
                    emptyStateView
                } else {
                    sessionListView
                }
            }
            .navigationTitle("SheetSweep")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "gearshape")
                    }
                }
                ToolbarItem(placement: .bottomBar) {
                    Button {
                        if PurchaseManager.shared.canUseFree {
                            showImport = true
                        } else {
                            showPaywall = true
                        }
                    } label: {
                        Label("New File", systemImage: "plus.circle.fill")
                            .font(.headline)
                    }
                }
            }
            .sheet(isPresented: $showImport) {
                ImportView()
            }
            .sheet(isPresented: $showSettings) {
                NavigationStack {
                    SettingsView()
                }
            }
            .sheet(isPresented: $showPaywall) {
                PaywallView()
            }
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 64))
                .foregroundStyle(.blue.opacity(0.6))

            Text("Drop your spreadsheet here to get started")
                .font(.title3)
                .foregroundStyle(.secondary)

            Text("Supports .xlsx and .csv files")
                .font(.subheadline)
                .foregroundStyle(.tertiary)

            Button {
                if PurchaseManager.shared.canUseFree {
                    showImport = true
                } else {
                    showPaywall = true
                }
            } label: {
                Label("Import File", systemImage: "plus.circle.fill")
                    .font(.headline)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
            }
            .buttonStyle(.borderedProminent)

            Spacer()
        }
        .frame(maxWidth: 720)
        .frame(maxWidth: .infinity)
    }

    private var sessionListView: some View {
        List {
            ForEach(sessions) { session in
                NavigationLink(value: session) {
                    SessionRowView(session: session)
                }
            }
            .onDelete(perform: deleteSessions)
        }
        .navigationDestination(for: CleaningSession.self) { session in
            ScanResultsView(session: session)
        }
    }

    private func deleteSessions(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(sessions[index])
            }
        }
    }
}

struct SessionRowView: View {
    let session: CleaningSession

    var body: some View {
        HStack {
            Image(systemName: "doc.fill")
                .foregroundStyle(.blue)
                .font(.title3)

            VStack(alignment: .leading, spacing: 4) {
                Text(session.fileName)
                    .font(.headline)
                    .lineLimit(1)

                HStack {
                    Text("\(session.rowCount) rows")
                    Text("\u{00B7}")
                    Text("\(session.columnCount) columns")
                    Text("\u{00B7}")
                    Text(session.isCompleted ? "Fixed" : "Pending")
                        .foregroundStyle(session.isCompleted ? .green : .orange)
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }

            Spacer()

            if !session.isCompleted {
                Circle()
                    .fill(.orange)
                    .frame(width: 8, height: 8)
            }
        }
        .padding(.vertical, 4)
    }
}
