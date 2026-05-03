import Foundation

actor CSVWriter {

    func write(data: [[String?]], headers: [String], to url: URL) throws {
        var csvContent = ""

        let escapedHeaders = headers.map { escapeCSV($0) }
        csvContent += escapedHeaders.joined(separator: ",") + "\n"

        for row in data {
            let escapedRow = row.map { cell -> String in
                if let value = cell {
                    return escapeCSV(value)
                }
                return ""
            }
            csvContent += escapedRow.joined(separator: ",") + "\n"
        }

        if FileManager.default.fileExists(atPath: url.path) {
            try FileManager.default.removeItem(at: url)
        }
        try csvContent.write(to: url, atomically: true, encoding: .utf8)
    }

    private func escapeCSV(_ value: String) -> String {
        if value.contains(",") || value.contains("\"") || value.contains("\n") || value.contains("\r") {
            return "\"" + value.replacingOccurrences(of: "\"", with: "\"\"") + "\""
        }
        return value
    }
}
