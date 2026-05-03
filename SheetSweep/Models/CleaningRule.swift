import Foundation
import SwiftData

@Model
final class CleaningRule {
    var id: UUID = UUID()
    var ruleType: String = "trimSpaces"
    var columnName: String = ""
    var targetFormat: String = ""
    var isActive: Bool = true

    var session: CleaningSession?

    init(ruleType: String, columnName: String, targetFormat: String) {
        self.id = UUID()
        self.ruleType = ruleType
        self.columnName = columnName
        self.targetFormat = targetFormat
    }
}

enum RuleType: String, CaseIterable, Codable {
    case dateFormat = "dateFormat"
    case currencyFormat = "currencyFormat"
    case trimSpaces = "trimSpaces"
    case removeHiddenChars = "removeHiddenChars"
    case fillMissing = "fillMissing"
    case standardizeColumnName = "standardizeColumnName"
}
