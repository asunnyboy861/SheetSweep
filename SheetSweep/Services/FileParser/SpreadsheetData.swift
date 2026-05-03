import Foundation

struct SpreadsheetData: Identifiable {
    let id = UUID()
    let sheets: [SheetData]
    let fileName: String
}

struct SheetData: Identifiable {
    let id = UUID()
    let name: String
    var rows: [[String?]]
    let columnCount: Int
    var headers: [String] {
        rows.first?.map { $0 ?? "" } ?? []
    }
    var dataRows: [[String?]] {
        Array(rows.dropFirst())
    }
}
