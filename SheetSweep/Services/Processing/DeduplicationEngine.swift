import Foundation

struct DuplicateGroup: Identifiable {
    let id = UUID()
    let rowIndices: [Int]
    let similarity: Double
    let suggestedKeep: Int
}

actor DeduplicationEngine {

    func findExactDuplicates(in data: [[String?]], columns: [Int]) -> [DuplicateGroup] {
        var groups: [String: [Int]] = [:]

        for (rowIdx, row) in data.enumerated() {
            let key = columns.map { colIdx in
                (colIdx < row.count ? (row[colIdx] ?? "") : "").lowercased().trimmingCharacters(in: .whitespaces)
            }.joined(separator: "|")

            groups[key, default: []].append(rowIdx)
        }

        return groups.filter { $0.value.count > 1 }.map { _, indices in
            DuplicateGroup(
                rowIndices: indices,
                similarity: 1.0,
                suggestedKeep: findMostCompleteRow(data: data, indices: indices)
            )
        }
    }

    func findFuzzyDuplicates(
        in data: [[String?]],
        columns: [Int],
        threshold: Double = 0.85
    ) -> [DuplicateGroup] {
        var groups: [DuplicateGroup] = []
        var processed = Set<Int>()

        for i in 0..<data.count {
            if processed.contains(i) { continue }

            var similarRows = [i]

            for j in (i + 1)..<data.count {
                if processed.contains(j) { continue }

                let similarity = calculateRowSimilarity(
                    row1: data[i],
                    row2: data[j],
                    columns: columns
                )

                if similarity >= threshold {
                    similarRows.append(j)
                    processed.insert(j)
                }
            }

            if similarRows.count > 1 {
                processed.insert(i)
                groups.append(DuplicateGroup(
                    rowIndices: similarRows,
                    similarity: threshold,
                    suggestedKeep: findMostCompleteRow(data: data, indices: similarRows)
                ))
            }
        }

        return groups
    }

    private func calculateRowSimilarity(
        row1: [String?],
        row2: [String?],
        columns: [Int]
    ) -> Double {
        var totalSimilarity = 0.0
        var validComparisons = 0

        for col in columns {
            let val1 = (col < row1.count ? (row1[col] ?? "") : "").trimmingCharacters(in: .whitespaces).lowercased()
            let val2 = (col < row2.count ? (row2[col] ?? "") : "").trimmingCharacters(in: .whitespaces).lowercased()

            guard !val1.isEmpty && !val2.isEmpty else { continue }

            totalSimilarity += jaroWinklerSimilarity(val1, val2)
            validComparisons += 1
        }

        return validComparisons > 0 ? totalSimilarity / Double(validComparisons) : 0
    }

    private func jaroWinklerSimilarity(_ s1: String, _ s2: String) -> Double {
        guard !s1.isEmpty && !s2.isEmpty else { return 0.0 }
        if s1 == s2 { return 1.0 }

        let searchRange = max(s1.count, s2.count) / 2 - 1
        let searchRangeClamped = max(0, searchRange)

        var s1Matches = Array(repeating: false, count: s1.count)
        var s2Matches = Array(repeating: false, count: s2.count)

        var matches = 0
        var transpositions = 0

        for (i, c1) in s1.enumerated() {
            let start = max(0, i - searchRangeClamped)
            let end = min(i + searchRangeClamped + 1, s2.count)

            for j in start..<end {
                guard !s2Matches[j] else { continue }
                let c2 = s2[s2.index(s2.startIndex, offsetBy: j)]
                if c1 == c2 {
                    s1Matches[i] = true
                    s2Matches[j] = true
                    matches += 1
                    break
                }
            }
        }

        guard matches > 0 else { return 0.0 }

        var k = 0
        for (i, matched) in s1Matches.enumerated() {
            guard matched else { continue }
            while !s2Matches[k] { k += 1 }
            let c1 = s1[s1.index(s1.startIndex, offsetBy: i)]
            let c2 = s2[s2.index(s2.startIndex, offsetBy: k)]
            if c1 != c2 { transpositions += 1 }
            k += 1
        }

        let jaro = (Double(matches) / Double(s1.count) +
                    Double(matches) / Double(s2.count) +
                    Double(matches - transpositions / 2) / Double(matches)) / 3.0

        let prefix = min(4, zip(s1, s2).prefix(while: { $0.0 == $0.1 }).count)
        let winkler = jaro + Double(prefix) * 0.1 * (1.0 - jaro)

        return winkler
    }

    private func findMostCompleteRow(data: [[String?]], indices: [Int]) -> Int {
        if let best = indices.max(by: { a, b in
            let countA = data[a].filter { ($0 ?? "").isEmpty == false }.count
            let countB = data[b].filter { ($0 ?? "").isEmpty == false }.count
            return countA < countB
        }) {
            return best
        }
        return indices[0]
    }
}
