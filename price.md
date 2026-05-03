# SheetSweep - Pricing Strategy

## IAP Product IDs

| Product ID | Type | Price | Display Name |
|---|---|---|---|
| com.zzoutuo.SheetSweep.monthly | Auto-Renewable Subscription | $4.99/mo | Pro Monthly |
| com.zzoutuo.SheetSweep.yearly | Auto-Renewable Subscription | $39.99/yr | Pro Yearly |
| com.zzoutuo.SheetSweep.lifetime | Non-Consumable | $79.99 | Lifetime Pro |

## Free Tier

- 3 file cleanings per month
- Basic duplicate detection (exact match only)
- CSV export only
- No supplier template memory

## Pro Tier (Monthly/Yearly)

- Unlimited file cleanings
- Fuzzy duplicate detection (JaroWinkler)
- Date format standardization
- Currency format unification
- Column name normalization
- XLSX + CSV export
- Supplier template memory
- Priority support

## Lifetime Tier

- All Pro features
- One-time purchase
- All future updates included

## Competitive Pricing Analysis

| Competitor | Price | Platform | Key Limitation |
|---|---|---|---|
| RowTidy | $15/mo | Web only | No iOS app, requires internet |
| Clean Merge Contacts | $8.99/wk | iOS | Only contacts, not spreadsheets |
| Power Query | Free (Office 365) | Desktop | No mobile, steep learning curve |
| SheetSweep Pro | $4.99/mo | iOS | - |

## Subscription Details

- Monthly: $4.99/month, auto-renewal
- Yearly: $39.99/year (save 33% vs monthly), auto-renewal
- Lifetime: $79.99 one-time purchase
- Free trial: None (free tier instead)
- Family Sharing: Supported
- Refund Policy: Apple standard refund policy applies

## Paywall Triggers

- User exceeds 3 free cleanings per month
- User attempts to use Pro-only features (fuzzy dedup, XLSX export, template memory)

## App Store Connect Configuration

1. Create app in App Store Connect with bundle ID com.zzoutuo.SheetSweep
2. Create 3 IAP products with IDs above
3. Set subscription group for monthly + yearly
4. Add localized display names and descriptions
5. Submit for review alongside app
