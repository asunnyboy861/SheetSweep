import SwiftUI
import StoreKit

struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedPlan: PlanType = .yearly
    @State private var isPurchasing = false

    enum PlanType: String, CaseIterable {
        case monthly = "Monthly"
        case yearly = "Yearly"
        case lifetime = "Lifetime"
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    headerSection

                    planSelector

                    featureList

                    purchaseButton

                    restoreButton

                    disclaimer
                }
                .padding()
            }
            .frame(maxWidth: 720)
            .frame(maxWidth: .infinity)
            .navigationTitle("Upgrade")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }

    private var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "crown.fill")
                .font(.system(size: 48))
                .foregroundStyle(.yellow)

            Text("Unlock SheetSweep Pro")
                .font(.title.bold())

            Text("Unlimited cleaning, advanced dedup, and more")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
    }

    private var planSelector: some View {
        VStack(spacing: 12) {
            planCard(.monthly, price: "$4.99/mo", subtitle: nil, badge: nil)
            planCard(.yearly, price: "$39.99/yr", subtitle: "Save 33%", badge: "Best Value")
            planCard(.lifetime, price: "$79.99", subtitle: "One-time purchase", badge: nil)
        }
    }

    private func planCard(_ plan: PlanType, price: String, subtitle: String?, badge: String?) -> some View {
        Button {
            selectedPlan = plan
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(plan.rawValue)
                            .font(.headline)
                        if let badge {
                            Text(badge)
                                .font(.caption2.bold())
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(.blue)
                                .foregroundStyle(.white)
                                .clipShape(Capsule())
                        }
                    }
                    Text(price)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    if let subtitle {
                        Text(subtitle)
                            .font(.caption)
                            .foregroundStyle(.green)
                    }
                }

                Spacer()

                Image(systemName: selectedPlan == plan ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(selectedPlan == plan ? .blue : .secondary)
                    .font(.title3)
            }
            .padding()
            .background(selectedPlan == plan ? Color.blue.opacity(0.1) : Color.clear)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(selectedPlan == plan ? Color.blue : Color.gray.opacity(0.3), lineWidth: selectedPlan == plan ? 2 : 1)
            )
        }
        .foregroundStyle(.primary)
    }

    private var featureList: some View {
        VStack(alignment: .leading, spacing: 12) {
            featureRow("Unlimited file cleaning", icon: "infinity")
            featureRow("Fuzzy duplicate detection", icon: "doc.on.doc.fill")
            featureRow("Date format standardization", icon: "calendar.badge.checkmark")
            featureRow("Currency format unification", icon: "dollarsign.circle.fill")
            featureRow("Column name normalization", icon: "textformat.abc")
            featureRow("XLSX + CSV export", icon: "square.and.arrow.up")
            featureRow("Supplier template memory", icon: "bookmark.fill")
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func featureRow(_ text: String, icon: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(.blue)
                .frame(width: 20)
            Text(text)
                .font(.subheadline)
        }
    }

    private var purchaseButton: some View {
        Button {
            purchaseSelectedPlan()
        } label: {
            if isPurchasing {
                ProgressView()
                    .tint(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
            } else {
                Text("Subscribe")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
            }
        }
        .buttonStyle(.borderedProminent)
        .disabled(isPurchasing)
    }

    private var restoreButton: some View {
        Button {
            Task {
                await PurchaseManager.shared.restorePurchases()
                if PurchaseManager.shared.isPremiumUser {
                    dismiss()
                }
            }
        } label: {
            Text("Restore Purchases")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    private var disclaimer: some View {
        Text("Payment will be charged to your Apple ID account at confirmation of purchase. Subscription automatically renews unless cancelled at least 24 hours before the end of the current period.")
            .font(.caption2)
            .foregroundStyle(.tertiary)
            .multilineTextAlignment(.center)
    }

    private func purchaseSelectedPlan() {
        isPurchasing = true
        Task {
            let productID: String
            switch selectedPlan {
            case .monthly: productID = "com.zzoutuo.SheetSweep.monthly"
            case .yearly: productID = "com.zzoutuo.SheetSweep.yearly"
            case .lifetime: productID = "com.zzoutuo.SheetSweep.lifetime"
            }

            if let product = PurchaseManager.shared.products.first(where: { $0.id == productID }) {
                let success = await PurchaseManager.shared.purchase(product)
                if success {
                    dismiss()
                }
            }
            isPurchasing = false
        }
    }
}
