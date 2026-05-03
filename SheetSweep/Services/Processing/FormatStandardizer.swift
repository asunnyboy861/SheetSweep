import Foundation

actor FormatStandardizer {

    private let dateFormats = [
        "MM/dd/yyyy", "dd/MM/yyyy", "yyyy-MM-dd",
        "MM-dd-yyyy", "dd-MM-yyyy", "MMM dd, yyyy",
        "dd MMM yyyy", "MM/dd/yy", "dd/MM/yy",
        "yyyyMMdd", "MM.dd.yyyy", "dd.MM.yyyy",
        "yyyy/MM/dd", "M/d/yyyy", "d/M/yyyy",
        "M/d/yy", "d/M/yy"
    ]

    func standardizeDate(_ value: String, targetFormat: String = "yyyy-MM-dd") -> String? {
        let trimmed = value.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return nil }

        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")

        for format in dateFormats {
            dateFormatter.dateFormat = format
            if let date = dateFormatter.date(from: trimmed) {
                dateFormatter.dateFormat = targetFormat
                return dateFormatter.string(from: date)
            }
        }

        if let date = dateFormatter.date(from: trimmed) {
            dateFormatter.dateFormat = targetFormat
            return dateFormatter.string(from: date)
        }

        return nil
    }

    func standardizeCurrency(_ value: String) -> (amount: Double?, currency: String?) {
        let trimmed = value.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return (nil, nil) }

        let currencySymbols: [String: String] = [
            "$": "USD", "\u{20AC}": "EUR", "\u{00A3}": "GBP",
            "\u{00A5}": "JPY", "\u{20B9}": "INR", "CHF": "CHF",
            "A$": "AUD", "C$": "CAD"
        ]

        var detectedCurrency: String?
        var numericString = trimmed

        for (symbol, code) in currencySymbols.sorted(by: { $0.key.count > $1.key.count }) {
            if numericString.contains(symbol) {
                detectedCurrency = code
                numericString = numericString.replacingOccurrences(of: symbol, with: "")
                break
            }
        }

        let codePattern = "\\b(USD|EUR|GBP|JPY|INR|CHF|AUD|CAD)\\b"
        if detectedCurrency == nil,
           let regex = try? NSRegularExpression(pattern: codePattern),
           let match = regex.firstMatch(in: numericString, range: NSRange(numericString.startIndex..., in: numericString)),
           let range = Range(match.range, in: numericString) {
            detectedCurrency = String(numericString[range])
            numericString = numericString.replacingCharacters(in: range, with: "")
        }

        numericString = numericString
            .replacingOccurrences(of: ",", with: "")
            .replacingOccurrences(of: " ", with: "")
            .trimmingCharacters(in: .whitespaces)

        let amount = Double(numericString)
        return (amount, detectedCurrency)
    }

    func trimExtraSpaces(_ value: String) -> String {
        let components = value.components(separatedBy: .whitespaces)
        return components.filter { !$0.isEmpty }.joined(separator: " ")
    }

    func removeHiddenCharacters(_ value: String) -> String {
        value.unicodeScalars.filter { scalar in
            CharacterSet.whitespacesAndNewlines.contains(scalar) ||
            CharacterSet.alphanumerics.contains(scalar) ||
            CharacterSet.punctuationCharacters.contains(scalar) ||
            CharacterSet.symbols.contains(scalar)
        }.map(String.init).joined()
    }
}
