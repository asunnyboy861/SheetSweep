# Git Repositories

## Main App (iOS Application)

| Item | Value |
|------|-------|
| **Repository Name** | SheetSweep |
| **Git URL** | git@github.com:asunnyboy861/SheetSweep.git |
| **Repo URL** | https://github.com/asunnyboy861/SheetSweep |
| **Visibility** | Public |
| **Primary Language** | Swift |
| **GitHub Pages** | ✅ **ENABLED** (from `/docs` folder) |

## Policy Pages (Deployed from Main Repository /docs)

| Page | URL | Status |
|------|-----|--------|
| Privacy Policy | https://asunnyboy861.github.io/SheetSweep/privacy.html | ✅ Active |
| Support | https://asunnyboy861.github.io/SheetSweep/support.html | ✅ Active |
| Terms of Use | https://asunnyboy861.github.io/SheetSweep/terms.html | ✅ Active |

## Repository Structure

### Main App Repository
```
SheetSweep/
├── SheetSweep.xcodeproj/          # Xcode Project
├── SheetSweep/                    # iOS App Source Code
│   ├── SheetSweepApp.swift        # App Entry Point
│   ├── Models/                    # Data Models (SwiftData)
│   ├── Views/                     # SwiftUI Views
│   │   ├── HomeView.swift
│   │   ├── ImportView.swift
│   │   ├── CleaningView.swift
│   │   ├── ResultView.swift
│   │   ├── SettingsView.swift
│   │   └── PaywallView.swift
│   ├── ViewModels/                # View Models (MVVM)
│   ├── Services/                  # Business Logic
│   │   ├── FileParser/            # Excel/CSV Parsing
│   │   ├── Processing/            # Data Cleaning Engine
│   │   ├── Export/                # XLSX/CSV Export
│   │   └── PurchaseManager.swift  # StoreKit 2 IAP
│   └── Resources/
│       └── Assets.xcassets/       # App Icon & Assets
├── docs/                          # Policy Pages (GitHub Pages)
│   ├── privacy.html
│   ├── support.html
│   └── terms.html
├── us.md                          # English Development Guide
├── keytext.md                     # App Store Metadata
├── price.md                       # Pricing Configuration
└── nowgit.md                      # This File
```

## App Store Connect

| Item | Value |
|------|-------|
| **App Name** | SheetSweep - Clean Sheets |
| **Bundle ID** | com.zzoutuo.SheetSweep |
| **Primary Category** | Business |
| **Secondary Category** | Productivity |
| **Age Rating** | 4+ |

## In-App Purchases

| Product ID | Type | Price |
|------------|------|-------|
| com.zzoutuo.SheetSweep.monthly | Auto-Renewable Subscription | $4.99/mo |
| com.zzoutuo.SheetSweep.yearly | Auto-Renewable Subscription | $39.99/yr |
| com.zzoutuo.SheetSweep.lifetime | Non-Consumable | $79.99 |

## Deployment History

| Date | Action | Status |
|------|--------|--------|
| 2026-05-03 | Initial commit to GitHub | ✅ Completed |
| 2026-05-03 | GitHub Pages enabled | ✅ Active |
| 2026-05-03 | Policy pages deployed | ✅ Active |
| 2026-05-03 | App Icon generated | ✅ Completed |

## Contact

- **Email**: iocompile67692@gmail.com
- **GitHub**: https://github.com/asunnyboy861
