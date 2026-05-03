import Foundation
import SwiftData

@Model
final class DataIssue {
    var id: UUID = UUID()
    var issueType: String = "duplicateRow"
    var severity: String = "warning"
    var sheetName: String = ""
    var rowIndex: Int = 0
    var columnIndex: Int = 0
    var originalValue: String = ""
    var suggestedFix: String = ""
    var isResolved: Bool = false

    var session: CleaningSession?

    init(issueType: String, severity: String, sheetName: String, rowIndex: Int, columnIndex: Int, originalValue: String, suggestedFix: String) {
        self.id = UUID()
        self.issueType = issueType
        self.severity = severity
        self.sheetName = sheetName
        self.rowIndex = rowIndex
        self.columnIndex = columnIndex
        self.originalValue = originalValue
        self.suggestedFix = suggestedFix
    }
}

enum IssueType: String, CaseIterable, Codable {
    case duplicateRow = "duplicateRow"
    case inconsistentDateFormat = "inconsistentDateFormat"
    case inconsistentCurrency = "inconsistentCurrency"
    case mergedCell = "mergedCell"
    case extraSpaces = "extraSpaces"
    case hiddenCharacters = "hiddenCharacters"
    case missingValue = "missingValue"
    case inconsistentColumnName = "inconsistentColumnName"
    case invalidNumber = "invalidNumber"

    var displayName: String {
        switch self {
        case .duplicateRow: return "Duplicate Rows"
        case .inconsistentDateFormat: return "Date Format Issues"
        case .inconsistentCurrency: return "Mixed Currencies"
        case .mergedCell: return "Merged Cells"
        case .extraSpaces: return "Extra Spaces"
        case .hiddenCharacters: return "Hidden Characters"
        case .missingValue: return "Missing Values"
        case .inconsistentColumnName: return "Column Name Issues"
        case .invalidNumber: return "Invalid Numbers"
        }
    }

    var icon: String {
        switch self {
        case .duplicateRow: return "doc.on.doc.fill"
        case .inconsistentDateFormat: return "calendar.badge.exclamationmark"
        case .inconsistentCurrency: return "dollarsign.circle.fill"
        case .mergedCell: return "square.on.square.intersection.dashed"
        case .extraSpaces: return "text.append"
        case .hiddenCharacters: return "eye.slash.fill"
        case .missingValue: return "questionmark.square.dashed"
        case .inconsistentColumnName: return "textformat.abc.dashedunderline"
        case .invalidNumber: return "number.circle.fill"
        }
    }
}

enum IssueSeverity: String, CaseIterable, Codable {
    case critical = "critical"
    case warning = "warning"
    case info = "info"

    var color: String {
        switch self {
        case .critical: return "red"
        case .warning: return "orange"
        case .info: return "blue"
        }
    }
}
