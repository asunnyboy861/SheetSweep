import Foundation
import SwiftData

@Model
final class SupplierTemplate {
    var id: UUID = UUID()
    var supplierName: String = ""
    var createdAt: Date = Date()
    var lastUsed: Date = Date()
    var useCount: Int = 0
    var columnMappingsData: Data = Data()

    init(supplierName: String) {
        self.id = UUID()
        self.supplierName = supplierName
        self.createdAt = Date()
        self.lastUsed = Date()
    }
}
