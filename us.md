# SheetSweep - iOS Development Guide

## Executive Summary

SheetSweep is the only iOS-native spreadsheet cleaning app that transforms messy vendor Excel/CSV files into clean, standardized data in seconds. Targeting procurement teams, finance departments, and small businesses, SheetSweep eliminates the 2-4 hours typically wasted cleaning each supplier file. All processing happens locally on-device — no cloud uploads, no data collection, complete privacy.

**Key Differentiators**:
- Only iOS-native spreadsheet cleaner on the App Store (zero direct competitors)
- 100% on-device processing — privacy-first, works offline
- JaroWinkler fuzzy duplicate detection — finds duplicates even with typos
- Supplier template memory — auto-applies rules for repeat vendors
- Price at 1/3 of web competitor RowTidy ($4.99/mo vs $15/mo)

## Competitive Analysis

| App | Strengths | Weaknesses | Our Advantage |
|-----|-----------|------------|---------------|
| RowTidy (Web) | AI-powered cleaning, batch processing, schema mapping | No iOS app, requires internet, cloud processing ($15/mo), no offline use | iOS native, offline, 1/3 price, local processing |
| Power Query (Desktop) | Free with Excel, powerful transformations, reusable queries | No mobile app, steep learning curve, requires Office 365, no AI | Mobile-first, zero learning curve, no Office dependency |
| OpenRefine (Desktop) | Free open-source, powerful, extensible, faceted browsing | No mobile app, complex UI, steep learning curve, outdated interface | Simple UI, 1-minute onboarding, iOS native |
| Clean Merge Contacts (iOS) | iOS native, duplicate detection, contact merging | Only cleans contacts, not spreadsheets, $8.99/week expensive | Full spreadsheet cleaning, much cheaper, more features |

## Apple Design Guidelines Compliance

- **Hierarchy**: Clear visual hierarchy — primary actions (Import, Fix, Export) prominent; secondary details (issue counts, settings) discoverable
- **Harmony**: Native iOS components — NavigationStack, List, Sheet, SF Symbols, system fonts
- **Consistency**: Standard iOS patterns — pull-to-refresh, swipe actions, share sheet, document picker
- **Dark Mode**: Full support using semantic colors (system blue, system background)
- **Accessibility**: Dynamic Type support, VoiceOver labels, minimum touch target 44pt
- **Privacy**: No data leaves device; App Store privacy label: "Data Not Collected"
- **Apple IAP Guidelines**: Auto-renewal disclosure, restore purchases, no dark patterns

## Technical Architecture

- **Language**: Swift 5.9+
- **Framework**: SwiftUI (primary), SwiftData for persistence
- **Data**: SwiftData (local only, no CloudKit for MVP)
- **File Parsing**: CoreXLSX (XLSX), SwiftCSV (CSV), ZIPFoundation (XLSX write)
- **Date Processing**: Native DateFormatter (no SwiftDate dependency to reduce binary size)
- **Concurrency**: Swift Concurrency (async/await, actor)
- **Observation**: @Observable macro (iOS 17+)
- **Architecture**: MVVM pattern

## Module Structure

```
SheetSweep/
├── SheetSweepApp.swift
├── Views/
│   ├── Home/
│   │   ├── HomeView.swift
│   │   └── HomeViewModel.swift
│   ├── Import/
│   │   ├── ImportView.swift
│   │   └── ImportViewModel.swift
│   ├── ScanResults/
│   │   ├── ScanResultsView.swift
│   │   ├── ScanResultsViewModel.swift
│   │   └── IssueRowView.swift
│   ├── IssueDetail/
│   │   ├── IssueDetailView.swift
│   │   └── DuplicateGroupView.swift
│   ├── FixPreview/
│   │   ├── FixPreviewView.swift
│   │   └── FixPreviewViewModel.swift
│   ├── Export/
│   │   ├── ExportView.swift
│   │   └── ExportViewModel.swift
│   ├── Settings/
│   │   ├── SettingsView.swift
│   │   └── ContactSupportView.swift
│   └── Paywall/
│       ├── PaywallView.swift
│       └── PurchaseManager.swift
├── Models/
│   ├── CleaningSession.swift
│   ├── DataIssue.swift
│   ├── CleaningRule.swift
│   ├── ColumnMapping.swift
│   └── SupplierTemplate.swift
├── Services/
│   ├── FileParser/
│   │   ├── ExcelParser.swift
│   │   ├── CSVParser.swift
│   │   └── SpreadsheetData.swift
│   ├── Processing/
│   │   ├── IssueScanner.swift
│   │   ├── DeduplicationEngine.swift
│   │   ├── FormatStandardizer.swift
│   │   └── ColumnNameNormalizer.swift
│   ├── Export/
│   │   ├── XLSXWriter.swift
│   │   └── CSVWriter.swift
│   └── PurchaseManager.swift
├── Extensions/
│   ├── String+Cleaning.swift
│   └── Color+Theme.swift
└── Resources/
    └── Assets.xcassets/
```

## Implementation Flow

1. Create Xcode project with SwiftUI, SwiftData, iOS 17.0 target
2. Add SPM dependencies: CoreXLSX, SwiftCSV, ZIPFoundation
3. Implement data models (SwiftData @Model classes)
4. Implement file parsing layer (ExcelParser, CSVParser)
5. Implement processing engines (DeduplicationEngine, FormatStandardizer, ColumnNameNormalizer, IssueScanner)
6. Implement export layer (XLSXWriter, CSVWriter)
7. Build UI: HomeView → ImportView → ScanResultsView → FixPreviewView → ExportView
8. Implement SettingsView with policy links and contact support
9. Implement PurchaseManager with StoreKit 2
10. Implement PaywallView
11. Test on iPhone and iPad simulators
12. Push to GitHub and deploy policy pages

## UI/UX Design Specifications

- **Color Scheme**:
  - Primary: Blue #007AFF (system blue — trust, professional, efficiency)
  - Success/Fixed: Green #34C759
  - Warning/Review: Orange #FF9500
  - Error/Duplicate: Red #FF3B30
  - Info: Blue #5AC8FA
  - Background Light: #F2F2F7, Dark: #1C1C1E

- **Typography**: SF Pro (system default), headline for titles, body for content, caption for metadata

- **Layout**:
  - NavigationStack with toolbar actions
  - List-based issue display with swipe actions
  - Max content width 720pt on iPad
  - Bottom toolbar for primary actions (Fix All, Export)

- **Animations**: Subtle transitions between views, progress indicators during scanning, haptic feedback on fix actions

## Code Generation Rules

- All data processing uses `actor` for thread safety
- Use Swift Concurrency (async/await) for file operations
- SwiftData for local persistence
- All file parsing on background thread (Task.detached)
- Privacy-first: no network requests for data processing
- Use @Observable macro (not ObservableObject)
- SwiftUI + NavigationStack for all UI
- Error handling with Swift native Error protocol
- No comments in code unless asked
- All SwiftData attributes must be optional or have default values
- All relationships must have inverse relationships
- iPad: always add .frame(maxWidth: 720).frame(maxWidth: .infinity) for main ScrollView content

## Build & Deployment Checklist

1. Verify Bundle ID: com.zzoutuo.SheetSweep
2. Verify Deployment Target: iOS 17.0
3. Add SPM dependencies (CoreXLSX, SwiftCSV, ZIPFoundation)
4. Configure App Icon
5. Configure IAP capabilities
6. Build and test on iPhone XS Max simulator
7. Build and test on iPad Pro 13-inch (M4) simulator
8. Push to GitHub (asunnyboy861/SheetSweep)
9. Deploy policy pages to GitHub Pages
10. Generate App Store metadata (keytext.md)
11. Generate App Store screenshots
