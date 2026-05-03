import Foundation
import SwiftData

@Model
final class ColumnMapping {
    var id: UUID = UUID()
    var originalName: String = ""
    var standardName: String = ""
    var confidence: Double = 0.0

    var session: CleaningSession?

    init(originalName: String, standardName: String, confidence: Double) {
        self.id = UUID()
        self.originalName = originalName
        self.standardName = standardName
        self.confidence = confidence
    }
}
