import Foundation

actor IssueScanner {
    private let dedupEngine = DeduplicationEngine()
    private let formatStandardizer = FormatStandardizer()
    private let columnNormalizer = ColumnNameNormalizer()

    func scan(data: SpreadsheetData) async -> [DataIssue] {
        var issues: [DataIssue] = []

        for sheet in data.sheets {
            let dataRows = sheet.dataRows
            guard !dataRows.isEmpty else { continue }

            let duplicateGroups = await dedupEngine.findExactDuplicates(in: dataRows, columns: Array(0..<sheet.columnCount))
            for group in duplicateGroups {
                for idx in group.rowIndices where idx != group.suggestedKeep {
                    issues.append(DataIssue(
                        issueType: IssueType.duplicateRow.rawValue,
                        severity: IssueSeverity.critical.rawValue,
                        sheetName: sheet.name,
                        rowIndex: idx,
                        columnIndex: 0,
                        originalValue: "Row \(idx + 2)",
                        suggestedFix: "Remove duplicate (keep row \(group.suggestedKeep + 2))"
                    ))
                }
            }

            for (rowIdx, row) in dataRows.enumerated() {
                for (colIdx, cell) in row.enumerated() {
                    let value = cell ?? ""

                    if !value.isEmpty {
                        let trimmed = value.trimmingCharacters(in: .whitespaces)
                        if trimmed != value && !trimmed.isEmpty {
                            issues.append(DataIssue(
                                issueType: IssueType.extraSpaces.rawValue,
                                severity: IssueSeverity.info.rawValue,
                                sheetName: sheet.name,
                                rowIndex: rowIdx,
                                columnIndex: colIdx,
                                originalValue: "\"\(value)\"",
                                suggestedFix: "\"\(trimmed)\""
                            ))
                        }

                        let hasHidden = value.unicodeScalars.contains { scalar in
                            !CharacterSet.whitespacesAndNewlines.contains(scalar) &&
                            !CharacterSet.alphanumerics.contains(scalar) &&
                            !CharacterSet.punctuationCharacters.contains(scalar) &&
                            !CharacterSet.symbols.contains(scalar) &&
                            !CharacterSet.newlines.contains(scalar)
                        }
                        if hasHidden {
                            issues.append(DataIssue(
                                issueType: IssueType.hiddenCharacters.rawValue,
                                severity: IssueSeverity.warning.rawValue,
                                sheetName: sheet.name,
                                rowIndex: rowIdx,
                                columnIndex: colIdx,
                                originalValue: "\"\(value)\"",
                                suggestedFix: "Remove hidden characters"
                            ))
                        }

                        let dateFormats = ["MM/dd/yyyy", "dd/MM/yyyy", "MM-dd-yyyy", "dd-MM-yyyy", "MMM dd, yyyy", "MM/dd/yy", "dd/MM/yy"]
                        let dateFormatter = DateFormatter()
                        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
                        for format in dateFormats where format != "yyyy-MM-dd" {
                            dateFormatter.dateFormat = format
                            if let _ = dateFormatter.date(from: trimmed) {
                                if let standardized = await formatStandardizer.standardizeDate(trimmed) {
                                    issues.append(DataIssue(
                                        issueType: IssueType.inconsistentDateFormat.rawValue,
                                        severity: IssueSeverity.warning.rawValue,
                                        sheetName: sheet.name,
                                        rowIndex: rowIdx,
                                        columnIndex: colIdx,
                                        originalValue: trimmed,
                                        suggestedFix: standardized
                                    ))
                                }
                                break
                            }
                        }

                        let currencySymbols = ["$", "\u{20AC}", "\u{00A3}", "\u{00A5}"]
                        if currencySymbols.contains(where: { trimmed.contains($0) }) {
                            let (amount, currency) = await formatStandardizer.standardizeCurrency(trimmed)
                            if let amt = amount, let cur = currency {
                                issues.append(DataIssue(
                                    issueType: IssueType.inconsistentCurrency.rawValue,
                                    severity: IssueSeverity.warning.rawValue,
                                    sheetName: sheet.name,
                                    rowIndex: rowIdx,
                                    columnIndex: colIdx,
                                    originalValue: trimmed,
                                    suggestedFix: "\(cur) \(String(format: "%.2f", amt))"
                                ))
                            }
                        }
                    }
                }
            }

            let mappings = await columnNormalizer.normalizeColumnNames(sheet.headers)
            for mapping in mappings where mapping.confidence >= 0.7 && mapping.originalName != mapping.standardName {
                issues.append(DataIssue(
                    issueType: IssueType.inconsistentColumnName.rawValue,
                    severity: IssueSeverity.warning.rawValue,
                    sheetName: sheet.name,
                    rowIndex: 0,
                    columnIndex: sheet.headers.firstIndex(of: mapping.originalName) ?? 0,
                    originalValue: mapping.originalName,
                    suggestedFix: mapping.standardName
                ))
            }
        }

        return issues
    }
}
