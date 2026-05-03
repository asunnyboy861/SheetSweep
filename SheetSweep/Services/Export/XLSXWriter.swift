import Foundation
import ZIPFoundation

actor XLSXWriter {

    func write(data: [[String?]], headers: [String], to url: URL) throws {
        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)

        defer { try? FileManager.default.removeItem(at: tempDir) }

        try FileManager.default.createDirectory(at: tempDir.appendingPathComponent("xl"), withIntermediateDirectories: true)
        try FileManager.default.createDirectory(at: tempDir.appendingPathComponent("xl/worksheets"), withIntermediateDirectories: true)
        try FileManager.default.createDirectory(at: tempDir.appendingPathComponent("_rels"), withIntermediateDirectories: true)
        try FileManager.default.createDirectory(at: tempDir.appendingPathComponent("xl/_rels"), withIntermediateDirectories: true)

        let contentTypes = """
        <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
        <Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">
            <Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>
            <Default Extension="xml" ContentType="application/xml"/>
            <Override PartName="/xl/workbook.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet.main+xml"/>
            <Override PartName="/xl/worksheets/sheet1.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml"/>
            <Override PartName="/xl/sharedStrings.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.sharedStrings+xml"/>
        </Types>
        """
        try contentTypes.write(to: tempDir.appendingPathComponent("[Content_Types].xml"), atomically: true, encoding: .utf8)

        let workbook = """
        <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
        <workbook xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships">
            <sheets>
                <sheet name="Sheet1" sheetId="1" r:id="rId1"/>
            </sheets>
        </workbook>
        """
        try workbook.write(to: tempDir.appendingPathComponent("xl/workbook.xml"), atomically: true, encoding: .utf8)

        let workbookRels = """
        <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
        <Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
            <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet" Target="worksheets/sheet1.xml"/>
            <Relationship Id="rId2" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/sharedStrings" Target="sharedStrings.xml"/>
        </Relationships>
        """
        try workbookRels.write(to: tempDir.appendingPathComponent("xl/_rels/workbook.xml.rels"), atomically: true, encoding: .utf8)

        let rootRels = """
        <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
        <Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
            <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="xl/workbook.xml"/>
        </Relationships>
        """
        try rootRels.write(to: tempDir.appendingPathComponent("_rels/.rels"), atomically: true, encoding: .utf8)

        var sharedStrings: [String: Int] = [:]
        var sharedStringsArray: [String] = []

        func getSharedStringIndex(_ s: String) -> Int {
            if let idx = sharedStrings[s] { return idx }
            sharedStrings[s] = sharedStringsArray.count
            sharedStringsArray.append(s)
            return sharedStringsArray.count - 1
        }

        var sheetXML = """
        <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
        <worksheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main">
        <sheetData>
        """

        for (rowIdx, row) in ([headers] + data).enumerated() {
            sheetXML += "<row r=\"\(rowIdx + 1)\">"
            for (colIdx, cell) in row.enumerated() {
                let colLetter = columnLetter(from: colIdx)
                let ref = "\(colLetter)\(rowIdx + 1)"
                if let value = cell, !value.isEmpty {
                    if let _ = Double(value) {
                        sheetXML += "<c r=\"\(ref)\"><v>\(value)</v></c>"
                    } else {
                        let idx = getSharedStringIndex(value)
                        sheetXML += "<c r=\"\(ref)\" t=\"s\"><v>\(idx)</v></c>"
                    }
                } else {
                    sheetXML += "<c r=\"\(ref)\"></c>"
                }
            }
            sheetXML += "</row>"
        }
        sheetXML += "</sheetData></worksheet>"
        try sheetXML.write(to: tempDir.appendingPathComponent("xl/worksheets/sheet1.xml"), atomically: true, encoding: .utf8)

        var ssXML = """
        <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
        <sst xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main" count="\(sharedStringsArray.count)" uniqueCount="\(sharedStringsArray.count)">
        """
        for s in sharedStringsArray {
            let escaped = s.replacingOccurrences(of: "&", with: "&amp;")
                         .replacingOccurrences(of: "<", with: "&lt;")
                         .replacingOccurrences(of: ">", with: "&gt;")
            ssXML += "<si><t>\(escaped)</t></si>"
        }
        ssXML += "</sst>"
        try ssXML.write(to: tempDir.appendingPathComponent("xl/sharedStrings.xml"), atomically: true, encoding: .utf8)

        if FileManager.default.fileExists(atPath: url.path) {
            try FileManager.default.removeItem(at: url)
        }
        try FileManager.default.zipItem(at: tempDir, to: url)
    }

    private func columnLetter(from index: Int) -> String {
        var result = ""
        var idx = index
        while idx >= 0 {
            result = String(UnicodeScalar(65 + (idx % 26))!) + result
            idx = (idx / 26) - 1
        }
        return result
    }
}
