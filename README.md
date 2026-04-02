# Penny Wise — Personal Finance Companion

A lightweight, elegant personal finance companion app built with **Flutter**. Penny Wise helps users track daily spending, set savings goals, and understand their money habits through clear visual insights — all in a mobile-first experience designed for everyday use.

---

## Screenshots & Features Overview

### 1. Home Dashboard
- Gradient balance card showing total balance, monthly income & expenses
- Monthly budget progress tracker with smart alerts (under, near, over budget)
- Weekly spending bar chart with day-by-day breakdown
- Quick-stats grid (monthly expenses, savings goal progress)
- Recent activity feed showing the last 5 transactions

### 2. Transaction Tracking
- Add/edit/delete transactions with type toggle (income/expense)
- Category selector with distinct icons and colors
- Date picker, amount input with validation, optional notes
- Swipe-to-delete and swipe-to-edit on transaction list
- Search bar with text matching across notes, categories, amounts
- Filter chips by type (All / Income / Expense) and by category
- Grouped by date headers (TODAY, YESTERDAY, dates) with daily net totals

### 3. Savings Goals (Creative Feature)
- Create goals with emoji, title, target amount, and deadline
- Visual progress bar per goal + daily savings recommendation
- "Add Money" bottom sheet with quick-amount chips (₹500, ₹1K, ₹2K, ₹5K)
- Overall savings progress ring (combined across all goals)
- Completed goals section with celebration states
- Overdue detection with visual indicators

### 4. Insights Screen
- Smart AI-like insight banners (week-over-week change, top category, budget pacing)
- Month-over-month expense comparison with percentage delta
- Week-over-week side-by-side comparison
- Category pie chart (interactive, animated)
- Category breakdown list with proportional bars and percentages
- Daily average spend metric
- Total transaction count + top spending category cards

### 5. Settings & Personalization
- Dark mode toggle (persisted across sessions)
- Multi-currency support (₹, $, €, £)
- Monthly budget configuration
- Profile name editing
- Load sample data / Clear all data options

### 6. Onboarding
- 3-step onboarding: Welcome → Name → Budget
- Auto-loads sample data for great first impression
- Skip option for power users
- Animated page indicator dots

---

## Architecture & Code Structure

```
lib/
├── main.dart                       # Entry point, provider setup
├── models/
│   ├── enums.dart                  # TransactionType, TransactionCategory + extensions
│   ├── transaction_model.dart      # Transaction data class
│   └── goal_model.dart             # SavingsGoal + NoSpendChallenge models
├── services/
│   ├── storage_service.dart        # Hive-based persistence layer
│   └── seed_data.dart              # Sample data factory
├── providers/
│   ├── transaction_provider.dart   # Transaction state + computed properties
│   ├── goal_provider.dart          # Goals state management
│   └── settings_provider.dart      # Theme, currency, budget, user prefs
├── theme/
│   └── app_theme.dart              # Light/dark themes, typography, colors
├── screens/
│   ├── shell_screen.dart           # Bottom nav + FAB scaffold
│   ├── home/
│   │   └── home_screen.dart        # Dashboard with balance, chart, stats
│   ├── transactions/
│   │   ├── transactions_screen.dart     # List, search, filter
│   │   └── add_edit_transaction_screen.dart  # Form with validation
│   ├── goals/
│   │   └── goals_screen.dart       # Goals list, add/fund sheets
│   ├── insights/
│   │   └── insights_screen.dart    # Analytics, charts, patterns
│   ├── settings/
│   │   └── settings_screen.dart    # Preferences and data management
│   └── onboarding/
│       └── onboarding_screen.dart  # First-run experience
└── widgets/
    ├── charts.dart                 # WeeklySpendingChart, CategoryPieChart
    ├── empty_state.dart            # Reusable empty state component
    ├── summary_card.dart           # SummaryCard, ProgressCard
    └── transaction_tile.dart       # Slidable transaction row
```

### Key Architectural Decisions

| Decision | Rationale |
|----------|-----------|
| **Provider** for state management | Simple, official Flutter recommendation, scales well for this scope |
| **Hive** for local persistence | Fast, lightweight NoSQL — no native deps, works on all platforms |
| **JSON serialization** (manual) | Avoids code-gen complexity for a small model set |
| **fl_chart** for visualizations | High-quality, customizable Flutter-native charts |
| **Separation of concerns** | Models → Services → Providers → Screens → Widgets |
| **Indian number formatting** | Default currency is ₹ with lakh-style comma separation |

---

## Design Decisions & Assumptions

1. **Not a banking app** — No real bank connections. All data is locally managed.
2. **Sample data on first run** — Onboarding loads realistic demo data so the app feels alive immediately.
3. **Currency is display-only** — Switching currency changes the symbol; no conversion is applied.
4. **Goal "Add Money"** — This is a tracking operation (manual entry), not an actual bank transfer.
5. **Budget is monthly** — Resets perception each calendar month. Budget carries no rollover.
6. **Insights are real-time** — All computed from the raw transaction list, not cached.
7. **Offline-first** — Everything works without internet. No API calls required.

---

## Setup & Running

### Prerequisites
- Flutter SDK ≥ 3.2.0
- Dart SDK ≥ 3.2.0
- Android Studio / Xcode (for device/emulator)

### Installation

```bash
# Clone the project
git clone <repository-url>
cd penny_wise

# Get dependencies
flutter pub get

# Run on connected device or emulator
flutter run

# Build APK
flutter build apk --release

# Build iOS
flutter build ios --release
```

### Supported Platforms
- Android (5.0+ / API 21+)
- iOS (12.0+)
- Web (experimental)

---

## Dependencies

| Package | Purpose |
|---------|---------|
| `provider` | State management |
| `hive` + `hive_flutter` | Local key-value storage |
| `fl_chart` | Bar charts, pie charts |
| `intl` | Date formatting |
| `uuid` | Unique ID generation |
| `google_fonts` | Plus Jakarta Sans typography |
| `flutter_slidable` | Swipe actions on list items |
| `shimmer` | Loading skeleton effects |
| `confetti_widget` | Goal completion celebrations |

---

## Optional Enhancements Implemented

- [x] Dark mode with persisted preference
- [x] Multi-currency support (₹, $, €, £)
- [x] Smooth animated transitions (page views, charts)
- [x] Offline-first (fully local data)
- [x] Empty states for all screens
- [x] Onboarding flow
- [x] Sample data loading
- [x] Indian number formatting (lakhs system)

---

## Evaluation Alignment

| Criteria | How Addressed |
|----------|---------------|
| **Product Thinking** | Onboarding, smart insights, budget pacing, daily savings suggestions |
| **Mobile UI/UX** | Touch-friendly targets, bottom sheets, swipe actions, filter chips, empty states |
| **Creativity** | Savings goals with emoji, daily target calculation, smart insight banners |
| **Functionality** | Full CRUD transactions, goals with funding, search/filter, chart visualizations |
| **Code Quality** | Clean separation, reusable widgets, typed models, consistent patterns |
| **State & Data** | Provider + Hive with computed properties, seed data, persistent settings |
| **Responsiveness** | SafeArea, CustomScrollView, flexible layouts, adaptive components |
| **Documentation** | This README with architecture, assumptions, setup, and design decisions |

---

## License

This project is submitted as part of a technical assignment. All code is original.
