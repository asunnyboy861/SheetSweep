import Foundation
import CoreXLSX

actor ExcelParser {

    func parseFile(at url: URL) async throws -> SpreadsheetData {
        guard let spreadsheet = XLSXFile(filepath: url.path) else {
            throw ParseError.invalidFile
        }

        var sheets: [SheetData] = []

        for wbk in try spreadsheet.parseWorkbooks() {
            for (name, path) in try spreadsheet.parseWorksheetPathsAndNames(workbook: wbk) {
                guard let worksheet = try? spreadsheet.parseWorksheet(at: path) else { continue }

                var rows: [[String?]] = []
                let sharedStrings = try? spreadsheet.parseSharedStrings()

                for row in worksheet.data?.rows ?? [] {
                    var cells: [String?] = []
                    for cell in row.cells {
                        let value: String? = {
                            if let ss = sharedStrings {
                                return cell.stringValue(ss)
                            }
                            return cell.value
                        }()
                        cells.append(value)
                    }
                    rows.append(cells)
                }

                sheets.append(SheetData(
                    name: name ?? "Sheet",
                    rows: rows,
                    columnCount: rows.first?.count ?? 0
                ))
            }
        }

        return SpreadsheetData(sheets: sheets, fileName: url.lastPathComponent)
    }
}

enum ParseError: LocalizedError {
    case invalidFile
    case unsupportedFormat
    case parsingFailed(String)

    var errorDescription: String? {
        switch self {
        case .invalidFile: return "The file could not be opened. It may be corrupted or in an unsupported format."
        case .unsupportedFormat: return "This file format is not supported. Please use .xlsx or .csv files."
        case .parsingFailed(let msg): return "Parsing failed: \(msg)"
        }
    }
}
