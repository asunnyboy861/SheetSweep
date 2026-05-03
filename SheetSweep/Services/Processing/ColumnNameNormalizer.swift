import Foundation

actor ColumnNameNormalizer {

    private let standardSchema: [String: [String]] = [
        "SKU": ["Product ID", "Item Code", "Part Number", "Product Code", "Item No", "SKU Code", "Product No", "Item Number"],
        "Product_Name": ["Product Name", "Item Description", "Description", "Product Description", "Item Name", "Product Title"],
        "Unit_Price": ["Price", "Unit Price", "Unit Cost", "Price/Unit", "Cost", "Unit Rate"],
        "Currency": ["Currency", "Curr", "CCY"],
        "Quantity": ["Qty", "Quantity", "Amount", "Units"],
        "Category": ["Category", "Product Category", "Product Type", "Class", "Group"],
        "Supplier": ["Supplier", "Vendor", "Supplier Name", "Vendor Name"],
        "Date": ["Date", "Order Date", "Delivery Date", "Invoice Date"],
        "Total": ["Total", "Total Price", "Line Total", "Amount"],
        "Stock": ["Stock", "Inventory", "Qty Available", "On Hand"]
    ]

    func normalizeColumnNames(_ headers: [String]) -> [ColumnMapping] {
        headers.map { header in
            let cleaned = header
                .trimmingCharacters(in: .whitespaces)
                .lowercased()
                .replacingOccurrences(of: "_", with: " ")
                .replacingOccurrences(of: "-", with: " ")

            var bestMatch = header
            var bestConfidence = 0.0

            for (standard, variants) in standardSchema {
                for variant in variants {
                    let variantCleaned = variant.lowercased()
                    let similarity = stringSimilarity(cleaned, variantCleaned)

                    if similarity > bestConfidence {
                        bestConfidence = similarity
                        bestMatch = standard
                    }
                }
            }

            return ColumnMapping(
                originalName: header,
                standardName: bestConfidence >= 0.7 ? bestMatch : header,
                confidence: bestConfidence
            )
        }
    }

    private func stringSimilarity(_ s1: String, _ s2: String) -> Double {
        guard !s1.isEmpty && !s2.isEmpty else { return 0 }
        if s1 == s2 { return 1.0 }

        let set1 = Set(s1.map { $0 })
        let set2 = Set(s2.map { $0 })
        let intersection = set1.intersection(set2)
        let union = set1.union(set2)

        return Double(intersection.count) / Double(union.count)
    }
}
