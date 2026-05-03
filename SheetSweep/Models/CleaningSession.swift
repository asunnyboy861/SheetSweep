import Foundation
import SwiftData

@Model
final class CleaningSession {
    var id: UUID = UUID()
    var fileName: String = ""
    var importDate: Date = Date()
    var rowCount: Int = 0
    var columnCount: Int = 0
    var sheetCount: Int = 0
    var issuesFound: Int = 0
    var issuesFixed: Int = 0
    var isCompleted: Bool = false
    var supplierName: String? = nil
    var templateName: String? = nil

    @Relationship(deleteRule: .cascade, inverse: \DataIssue.session)
    var issues: [DataIssue] = []

    @Relationship(deleteRule: .cascade, inverse: \CleaningRule.session)
    var rules: [CleaningRule] = []

    @Relationship(deleteRule: .cascade, inverse: \ColumnMapping.session)
    var columnMappings: [ColumnMapping] = []

    init(fileName: String) {
        self.id = UUID()
        self.fileName = fileName
        self.importDate = Date()
    }
}
