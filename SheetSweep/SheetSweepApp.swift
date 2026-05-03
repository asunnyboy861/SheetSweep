import SwiftUI
import SwiftData

@main
struct SheetSweepApp: App {
    var body: some Scene {
        WindowGroup {
            HomeView()
        }
        .modelContainer(for: [CleaningSession.self, SupplierTemplate.self])
    }
}
