import Foundation
import SwiftCSV

actor CSVParser {

    func parseFile(at url: URL) async throws -> SpreadsheetData {
        let csv = try CSV<Named>(url: url)

        var rows: [[String?]] = []
        var headerRow: [String?] = csv.header.map { Optional($0) }
        rows.append(headerRow)

        for row in csv.rows {
            var cells: [String?] = []
            for header in csv.header {
                cells.append(row[header] ?? "")
            }
            rows.append(cells)
        }

        let sheetData = SheetData(
            name: "CSV Data",
            rows: rows,
            columnCount: csv.header.count
        )

        return SpreadsheetData(
            sheets: [sheetData],
            fileName: url.lastPathComponent
        )
    }
}
