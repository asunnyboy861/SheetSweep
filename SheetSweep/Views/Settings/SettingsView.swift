import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showPaywall = false

    var body: some View {
        List {
            if !PurchaseManager.shared.isPremiumUser {
                Section {
                    Button {
                        showPaywall = true
                    } label: {
                        HStack {
                            Image(systemName: "crown.fill")
                                .foregroundStyle(.yellow)
                            Text("Upgrade to Pro")
                                .font(.headline)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }

            Section {
                HStack {
                    Text("Free usage this month")
                    Spacer()
                    Text("\(PurchaseManager.shared.freeUsageCount)/\(PurchaseManager.shared.maxFreeUsage)")
                        .foregroundStyle(.secondary)
                }
            } header: {
                Text("Usage")
            }

            Section {
                Button {
                    Task {
                        await PurchaseManager.shared.restorePurchases()
                    }
                } label: {
                    Text("Restore Purchases")
                }
            }

            Section {
                NavigationLink {
                    ContactSupportView()
                } label: {
                    Label("Contact Support", systemImage: "envelope")
                }

                Link(destination: URL(string: "https://asunnyboy861.github.io/SheetSweep/support.html")!) {
                    Label("Support Page", systemImage: "questionmark.circle")
                }

                Link(destination: URL(string: "https://asunnyboy861.github.io/SheetSweep/privacy.html")!) {
                    Label("Privacy Policy", systemImage: "hand.raised")
                }

                Link(destination: URL(string: "https://asunnyboy861.github.io/SheetSweep/terms.html")!) {
                    Label("Terms of Use", systemImage: "doc.text")
                }
            } header: {
                Text("Legal & Support")
            }

            Section {
                HStack {
                    Text("Version")
                    Spacer()
                    Text("1.0.0")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .navigationTitle("Settings")
        .sheet(isPresented: $showPaywall) {
            PaywallView()
        }
    }
}
